library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.numeric_std.all;


library work;
use work.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

--!
--! @brief      Main class for connecting all the components involved in the
--!             middleware
--!
entity genericProject is
	port (
		status_out		: out std_ulogic; 	--! Output to indicate activity

		config_sleep	: out std_logic := '0'; 	--! Configuration control to cause sleep for energy saving
		task_complete	: out std_logic := '0';		--! Feedback from configuration about task completion
		
		userlogic_rdy	: out std_logic;
		userlogic_done	: out std_logic;
		
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
		icap_clk		: in std_ulogic;  --! Clock 20 MHz
		rx				: in std_logic;
		tx 			: out std_logic;
		button		: in std_logic	
	);
end genericProject;


architecture Behavioral of genericProject is

-- signal clk_icap 				: std_logic := '0';
-- signal icap_en					: std_logic := '0';
-- signal multiboot_address	: std_logic_vector(23 downto 0);

---- 8 bit interface
--signal incoming_data	 			: std_logic_vector(7 downto 0);
--signal outgoing_data				: std_logic_vector(7 downto 0);
--signal incoming_data_rdy		: std_logic;
--signal outgoing_data_rdy		: std_logic := '0';
--signal outgoing_data_done 		: std_logic := '0';
-- 32 bit data interface
signal incoming_data_32			: uint32_t_interface; -- std_logic_vector(31 downto 0);
-- signal incoming_data_32_rdy	: std_logic;
signal incoming_data_32_done	: std_logic;
signal outgoing_data_32			: uint32_t_interface;
-- signal outgoing_data_32_rdy	: std_logic := '0';
signal outgoing_data_32_done	: std_logic := '0';

---- uart variables
--signal uart_en_s					: std_logic := '0';
--signal uart_data_in				: std_logic_vector(7 downto 0);
--signal uart_data_in_rdy			: std_logic := '0';
--signal uart_data_out				: std_logic_vector(7 downto 0);
--signal uart_data_out_rdy		: std_logic := '0';
--signal uart_data_in_done		: std_logic;
--signal uart_tx_active			: std_logic;

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

-- userlogic variables
signal userlogic_en				: std_logic;
signal userlogic_sleep			: std_logic;
signal userlogic_done_s			: std_logic;
signal userlogic_rdy_s			: std_logic;
--signal userlogic_data_in_rdy	: std_logic;
--signal userlogic_data_out_rdy	: std_logic;
--signal userlogic_data_out_done: std_logic;
--signal userlogic_calculating	: std_logic;

signal reset 						: std_logic := '1';

begin

-- todo add to mw the async -> sync comm part, and decode incoming data not meant for ul
mw: entity work.middleware(Behavioral)
	port map(
		status_out,

		-- spi_en => arduino_13, 
		-- uart_en,
		
		config_sleep, 
		task_complete,
		
		userlogic_en,
		userlogic_rdy_s,
		userlogic_done_s,
		userlogic_sleep,
		
		-- outgoing_data_32_rdy,
		outgoing_data_32,
		-- incoming_data_32_rdy,
		incoming_data_32,
		incoming_data_32_done,
		
--		spi_switch => user_reset,
--		flash_cs => spi_cs, 
--		flash_sck => spi_sck, 
--		flash_mosi => spi_mosi, 
--		flash_miso => spi_miso, 
--				
--		ext_cs => Arduino_0, 
--		ext_sck => Arduino_1, 
--		ext_mosi => arduino_2, 
--		ext_miso => arduino_3, 
		
		rec_state_leds,
		send_state_leds,
		
		clk, 

		rx,
		tx, 
		button
	);
-- process to delay reset for fsm
	process (clk, reset)
		variable count : integer range 0 to 10 := 0;
	begin
		if reset = '1' then	
			
			if rising_edge(clk) then
			if count < 10 then
				count := count + 1;
				reset <= '1';
			else
				reset <= '0';
			end if;
		end if;
	end process;
	-- initialise user logic
	-- ul: entity work.Dummy(Behavioral) port map
	-- ul: entity work.VectorDotproductSkeleton(Behavioral) port map
	ul: entity work.MatrixMultiplicationSkeleton(Behavioral) port map
		(
			clk, userlogic_en, userlogic_rdy_s, userlogic_done_s, outgoing_data_32, incoming_data_32, incoming_data_32_done
		);
	-- userlogic_data_in_rdy <= outgoing_data_32_rdy and userlogic_en;
	-- incoming_data_32 <= userlogic_data_out;
	-- userlogic_data_out_done <= incoming_data_32_done;
	userlogic_rdy <= userlogic_rdy_s;
	userlogic_done <= userlogic_done_s;
	-- config_sleep <= userlogic_sleep;

end Behavioral;
