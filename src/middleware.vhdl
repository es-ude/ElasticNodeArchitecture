library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.numeric_std.all;


library work;
use work.all;
--!
--! @brief      Main class for connecting all the components involved in the
--!             middleware
--!
entity middleware is
	port (
		status_out		: out std_ulogic; 	--! Output to indicate activity

		config_sleep	: out std_logic := '0'; 	--! Configuration control to cause sleep for energy saving
		task_complete	: in std_logic;		--! Feedback from configuration about task completion
		
		spi_cs		: out std_logic;
		spi_clk		: out std_logic;
		spi_mosi	: out std_logic;
		spi_miso	: in std_logic;


		clk 			: in std_ulogic;	--! Clock 32 MHz
		rx				: in std_logic;
		tx 				: out std_logic;
		button			: in std_logic
	);
end middleware;


architecture Behavioral of middleware is

signal clk_icap 			: std_logic := '0';
signal icap_rdy				: std_logic := '0';
signal multiboot_address	: std_logic_vector(23 downto 0);

--!
--! @brief      Component that interfaces with the Spartan 6 ICAP
--!
component icapInterface is
	generic
	(
		goldenboot_address	:	std_logic_vector(23 downto 0) := (others => '0')
	);
	port
	(
		clk,areset			:	in std_ulogic;
		status_running 		:	out std_ulogic;
		multiboot_address	:	in std_logic_vector(23 downto 0)
	);
end component icapInterface;

component uartInterface is
	port
	(
	  	rx_data		: out  std_logic_vector(7 downto 0);						--! 8-bit data received
	  	rx_rdy		: out std_logic;											--! received data ready
	  	tx_data		: in std_logic_vector(7 downto 0);							--! 8-bit data to be sent	
	    tx_rdy		: in std_logic;												--! triggers data sending, max speed interface dependent (i.e. 9600 baud / 8)
	    --! physical interfaces
	    i_uart_rx 	: in std_logic;												--! physical UART RX pin
	  	o_uart_tx 	: out std_logic;											--! physical UART TX pin
	  	clk 		: in std_logic 												--! 32 MHz clock	
	);
end component uartInterface;

signal incoming_data	 	: std_logic_vector(7 downto 0);
signal outgoing_data		: std_logic_vector(7 downto 0);
signal incoming_data_rdy	: std_logic;
signal outgoing_data_rdy	: std_logic := '0';

-- receiving fsm
type receive_state is (idle, receiving_next_config);
signal current_receive_state: receive_state := idle;
signal state_count 			: integer range 0 to 2; --! count how many times this state has happened

signal byte_count			: integer range 0 to 10 := 0;

-- spi variables
signal spi_en	 	: std_logic := '0'; -- general enable to allow sending data
signal spi_data_rdy	: std_logic := '0'; -- stretched strobe to send a byte 
signal spi_strobe	: std_logic := '0'; -- a byte is available, toggle to show activity
signal spi_data 	: std_logic_vector(7 downto 0);
 
begin
	--! Communication interface initialisation
	uart : uartInterface 
		port map (incoming_data, incoming_data_rdy, outgoing_data, outgoing_data_rdy, rx, tx, clk);

	--! React to availability of new byte incoming
	process (incoming_data_rdy)
	begin
		if incoming_data_rdy'event and incoming_data_rdy = '1' then
			byte_count <= byte_count + 1;

			--! Respond based on what state the middleware is in 
			case current_receive_state is
				--! different states 
				when idle =>
					--! see if new command is being received
					case incoming_data is
						--! Set next Configuration Address
						when x"30" =>
							current_receive_state <= receiving_next_config;
							state_count <= 0;
						--! Set configuration to sleep
						--when x"45" =>
						--	config_sleep <= '1';
						when x"31" =>
							spi_en <= '1';
						when x"32" =>
							spi_en <= '0';
						when others => 
							spi_strobe <= not spi_strobe;
							spi_data <= incoming_data;
					end case;
					--! none of previous cases, 
					outgoing_data_rdy <= '1';
				when receiving_next_config =>
					--! receive a byte of config
					case state_count is
						when 0 =>
							multiboot_address(23 downto 16) <= incoming_data;
							state_count <= 1;
						when 1 =>
							multiboot_address(15 downto 8) <= incoming_data;
							state_count <= 2;
						when 2 =>
							multiboot_address(7 downto 0) <= incoming_data;
							current_receive_state <= idle;
							icap_rdy <= '1';
							state_count <= 0;
					end case;
			end case;
		end if;
	end process;

	outgoing_data <= multiboot_address(23 downto 16);
	config_sleep <= spi_en;

	--! Probe stretching to send a SPI byte
	process (clk, spi_strobe, spi_en)
	variable handled_strobe : std_logic := '0';
	variable old_strobe		: std_logic := '0';
	begin
		if spi_en = '0' then
			spi_data_rdy <= '0';
		elsif falling_edge(clk) then
			if old_strobe /= spi_strobe then
				old_strobe := spi_strobe;
				spi_data_rdy <= '1';
				handled_strobe := '0';
			else 
				spi_data_rdy <= '0';
			end if;
		end if;
	end process;

	--! ICAP interface initialisation
	process(clk)
	begin
		if clk'event and clk = '1' then
			clk_icap <= not clk_icap;
		end if;
	end process;
	
	status_out <= icap_rdy;
	--status_out <= '1' when multiboot_address = x"060000" else '0';

	ic : icapInterface 
		generic map (goldenboot_address => (others => '0')) 
		port map (clk => clk_icap, areset => button, status_running => open, multiboot_address => multiboot_address);

	--! SPI communication interface
	spi: entity work.spiInterface(arch)
		port map(
		data_in => spi_data,
		data_out => open,
		data_i_rdy => incoming_data_rdy,
		address_in => (others => '0'),
		data_o_rdy => open,
		clk => clk,

		--! SPI physical interfaces 
		spi_cs => spi_cs,
		spi_clk => spi_clk,
		spi_mosi => spi_mosi,
		spi_miso => spi_miso);

end Behavioral;
