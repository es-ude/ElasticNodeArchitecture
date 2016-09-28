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
		status_out	: out std_ulogic; 	--! Output to indicate activity
		clk 		: in std_ulogic;	--! Clock
		rx			: in std_logic;
		tx 			: out std_logic;
		button		: in std_logic
	);
end middleware;


architecture Behavioral of middleware is

signal clk_icap : std_logic := '0';
signal icap_rdy	: std_logic := '0';
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

component communicationInterface is
	port
	(
	  	rx_data		: out  std_logic_vector(7 downto 0);	--! 8-bit data received
	  	rx_rdy		:	out std_logic;											--! received data ready
	  	tx_data		: in std_logic_vector(7 downto 0);		--! 8-bit data to be sent	
	    tx_rdy		: in std_logic;												--! triggers data sending, max speed interface dependent (i.e. 9600 baud / 8)
	    --! physical interfaces
	    i_uart_rx 	:	in std_logic;												--! physical UART RX pin
	  	o_uart_tx 	:	out std_logic;											--! physical UART TX pin
	  	clk 		: in std_logic 												--! 32 MHz clock	
	);
end component communicationInterface;

signal incoming_data	 	: std_logic_vector(7 downto 0);
signal outgoing_data		: std_logic_vector(7 downto 0);
signal incoming_data_rdy	: std_logic;
signal outgoing_data_rdy	: std_logic := '0';

type receive_state is (idle, receiving_next_config);
signal current_receive_state: receive_state := idle;
signal state_count 			: integer range 0 to 2; --! count how many times this state has happened

signal multiboot_address	: std_logic_vector(23 downto 0);

signal byte_count			: integer range 0 to 10 := 0;

begin
	--! Communication interface initialisation
	comm : communicationInterface 
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
					if incoming_data = x"30" then
						current_receive_state <= receiving_next_config;
						state_count <= 0;
					end if;
					--! none of previous cases, 
					outgoing_data_rdy <= '1';
				when receiving_next_config =>
					--! receive a byte of config
					if state_count = 0 then
						multiboot_address(23 downto 16) <= incoming_data;
						state_count <= 1;
					elsif state_count = 1 then 
						multiboot_address(15 downto 8) <= incoming_data;
						state_count <= 2;
					else 
						multiboot_address(7 downto 0) <= incoming_data;
						current_receive_state <= idle;
						icap_rdy <= '1';
						state_count <= 0;
					end if;
			end case;
		end if;
	end process;

	outgoing_data <= multiboot_address(23 downto 16);

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

end Behavioral;
