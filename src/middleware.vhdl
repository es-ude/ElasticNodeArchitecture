library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.numeric_std.all;


library work;
use work.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

--!
--! @brief      Main class for connecting all the components involved in the
--!             middleware
--!
entity middleware is
	port (
		status_out		: out std_ulogic; 	--! Output to indicate activity

		config_sleep	: out std_logic := '0'; 	--! Configuration control to cause sleep for energy saving
		task_complete	: out std_logic := '0';		--! Feedback from configuration about task completion
		
		userlogic_en	: out std_logic;
		userlogic_rdy	: in std_logic;
		userlogic_done	: in std_logic;
		userlogic_sleep: out std_logic;
		
		data_out_32		: out uint32_t_interface;
		data_in_32		: in uint32_t_interface;
		data_in_32_done: out std_logic;
		
--		spi_switch	: in std_logic;
--		flash_cs		: out std_logic;
--		flash_sck	: out std_logic;
--		flash_mosi	: out std_logic;
--		flash_miso	: in std_logic;
--
--		ext_cs		: out std_logic;
--		ext_sck		: out std_logic;
--		ext_mosi		: out std_logic;
--		ext_miso		: in std_logic;

		rec_state_leds	: out std_logic_vector(3 downto 0);
		send_state_leds: out std_logic_vector(3 downto 0);
		
		-- spi_en		: out std_logic;
		-- uart_en		: out std_logic;
	
		clk 			: in std_ulogic;	--! Clock 32 MHz
		-- icap_clk		: in std_ulogic;  --! Clock 20 MHz
		rx				: in std_logic;
		tx 			: out std_logic;
		button		: in std_logic	
	);
end middleware;


architecture Behavioral of middleware is

signal clk_icap 				: std_logic := '0';
signal icap_en					: std_logic := '0';
signal multiboot_address	: uint24_t;

-- 8 bit interface
signal data_in_8, data_out_8	: uint8_t_interface;
signal data_out_8_done			: std_logic := '0';

-- uart variables
signal uart_en						: std_logic := '0';
signal uart_data_in				: uint8_t_interface; -- std_logic_vector(7 downto 0);
-- signal uart_data_in_rdy			: std_logic := '0';
signal uart_data_out				: uint8_t_interface; -- std_logic_vector(7 downto 0);
-- signal uart_data_out_rdy		: std_logic := '0';
signal uart_data_in_done		: std_logic;
signal uart_tx_active			: std_logic;

---- spi variables
--signal spi_en_s		 		: std_logic := '0'; -- general enable to allow sending data
--signal spi_data_in_rdy	: std_logic := '0'; -- stretched strobe to send a byte 
--signal spi_strobe			: std_logic := '0'; -- a byte is available, toggle to show activity
--signal spi_data_in 		: std_logic_vector(7 downto 0);
--signal spi_data_out 		: std_logic_vector(7 downto 0);
--signal spi_data_out_rdy 	: std_logic := '0';
--signal spi_data_in_done	: std_logic;
--signal spi_cs				: std_logic;
--signal spi_sck				: std_logic;
--signal spi_mosi				: std_logic;
--signal spi_miso				: std_logic; 


signal reset 						: std_logic := '1';

begin

	-- User interface
	process (



	--! Communication interface initialisation
	uart : entity fpgamiddlewarelibs.uartInterface(arch)
		generic map ( 64 )
		port map (
			rx_data => uart_data_out, --! 8-bit data received
			-- rx_rdy => uart_data_out_rdy,	--! received data ready
			tx_data => uart_data_in,	--! 8-bit data to be sent	
			-- tx_rdy => uart_data_in_rdy,
			tx_done => uart_data_in_done,
			--! physical interfaces
			i_uart_rx => rx,
			o_uart_tx => tx,
			clk => clk
		);
	uart_data_in.ready <= data_out_8.ready and uart_en;
	uart_data_in.data <= data_out_8.data;
	
	-- outgoing_data <= multiboot_address(23 downto 16);
	
	--! ICAP interface initialisation
	process(clk)
	begin
		if clk'event and clk = '1' then
			clk_icap <= not clk_icap;
		end if;
	end process;
	
	status_out <= '1';
	
	-- 8 bit interface
	-- incoming_data <= uart_data_out;
	-- incoming_data_rdy <= uart_data_out_rdy;
	-- outgoing_data_done <= uart_data_in_done;
	
	-- 32 bit interface
	-- incoming_data_32_rdy <= userlogic_data_out_rdy;
	
	
--	incoming_data <= spi_data_out when spi_en_s = '1' else uart_data_out;
--	incoming_data_rdy <= spi_data_out_rdy when spi_en_s = '1' else uart_data_out_rdy;
--	outgoing_data_done <= spi_data_in_done when spi_en_s = '1' else uart_data_in_done;

	ic : entity fpgamiddlewarelibs.icapInterface(Behavioral)
		generic map (goldenboot_address => (others => '0')) 
		port map (clk => clk_icap, enable => icap_en, status_running => open, multiboot_address => std_logic_vector(multiboot_address));


	
	-- process to delay reset for fsm
	process (clk)
		variable count : integer range 0 to 10 := 0;
	begin
		if rising_edge(clk) then
			if count < 10 then
				count := count + 1;
				reset <= '1';
			else
				reset <= '0';
			end if;
		end if;
	end process;
	
end Behavioral;


--	--! SPI communication interface
--	spi: entity fpgamiddlewarelibs.spiInterface(arch)
--		generic map (
--			prescaler => 4000000
--		)
--		port map(
--		enable => spi_en_s,
--		data_in => spi_data_in, -- data to be sent 
--		data_out => spi_data_out, -- data received
--		data_i_rdy => spi_data_in_rdy,
--		data_i_req => spi_data_in_done,
--		data_o_rdy => spi_data_out_rdy,
--		clk => clk,
--
--		--! SPI physical interfaces 
--		spi_cs => spi_cs,
--		spi_clk => spi_sck,
--		spi_mosi => spi_mosi,
--		spi_miso => spi_miso
--	);
--	
--	spi_data_in <= outgoing_data;
--	spi_data_in_rdy <= outgoing_data_rdy and spi_en_s;
--	spi_en <= spi_en_s;
--
--	-- both spi outputs synced
--	ext_sck <= spi_sck;
--	flash_sck <= spi_sck;
--	ext_mosi <= spi_mosi;
--	flash_mosi <= spi_mosi;
--	-- select spi based on switch
--	ext_cs <= spi_cs 				when spi_switch = '1' else '1'; -- active low
--	flash_cs <= spi_cs 			when spi_switch = '0' else '1';
--	spi_miso <= ext_miso 		when spi_switch = '1' else flash_miso;


--	fsm : entity work.CommunicationStateMachine(Behavioral)
--		port map (
--			clk => clk,
--			reset => reset,
--			
--			data_in_8 => data_in_8,
--			data_out_8 => data_out_8,
--			data_out_8_done => data_out_8_done,
--			data_in_32 => data_in_32,
--			data_in_32_done => data_in_32_done,
--			data_out_32 => data_out_32,
--			
--			-- spi_en => spi_en_s,
--			uart_en => uart_en,
--			icap_en => icap_en,
--			multiboot => multiboot_address,
--			fpga_sleep => userlogic_sleep,
--			userlogic_en => userlogic_en,
--			userlogic_rdy => userlogic_rdy,
--			userlogic_done => userlogic_done,
--			
--			--debug
--			ready => open,
--			receive_state_out	=> rec_state_leds,
--			send_state_out	=> send_state_leds
--		);
--	data_in_8 <= uart_data_out;
--	data_out_8_done <= uart_data_in_done;