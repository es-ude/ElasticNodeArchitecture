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

		leds			: out std_logic_vector(3 downto 0);
		
		clk 			: in std_ulogic;	--! Clock 32 MHz
		rx				: in std_logic;
		tx 			: out std_logic;
		
		-- sram
		mcu_ad		: inout std_logic_vector(7 downto 0) := (others => 'Z');
		mcu_ale		: in std_logic;
		mcu_a			: in std_logic_vector(15 downto 8);
		mcu_rd		: in std_logic;
		mcu_wr		: in std_logic
	);
end genericProject;


architecture Behavioral of genericProject is

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
signal userlogic_reset			: std_logic;
signal userlogic_done			: std_logic;
signal userlogic_data_in, userlogic_data_out : uint8_t;
signal userlogic_address		: uint16_t;
signal userlogic_rd, userlogic_wr: std_logic;
signal reset 						: std_logic := '1';

-- higher level ports
signal sram_address			: std_logic_vector(15 downto 0);
signal data_out				: std_logic_vector(7 downto 0); -- for reading from ext ram
signal data_in 				: std_logic_vector(7 downto 0); 	-- for writing to ext ram
signal rd						: std_logic;
signal wr						: std_logic

begin

-- todo add to mw the async -> sync comm part, and decode incoming data not meant for ul
mw: entity work.middleware(Behavioral)
	port map(
		reset,
		clk,

		-- userlogic
		userlogic_reset,
		userlogic_done,
		userlogic_data_in,
		userlogic_data_out,
		userlogic_address,
		userlogic_rd,
		userlogic_wr,
		
		-- debug
		interface_leds,
		
		-- uart
		rx,
		tx,
		
		-- sram
		sram_address,
		sram_data_out,
		sram_data_in,
		sram_rd,
		sram_wr
	);
	
---- process to delay reset for fsm
--	process (clk, reset)
--		variable count : integer range 0 to 10 := 0;
--	begin
--		if reset = '1' then	
--			
--			if rising_edge(clk) then
--				if count < 10 then
--					count := count + 1;
--					reset <= '1';
--				else
--					reset <= '0';
--				end if;
--			end if;
--		end if;
--	end process;
	
	-- initialise user logic
	-- ul: entity work.Dummy(Behavioral) port map
	ul: entity work.VectorDotproductSkeleton(Behavioral) port map
	-- ul: entity work.MatrixMultiplicationSkeleton(Behavioral) port map
		(
			clk, reset, userlogic_done, userlogic_rd, userlogic_wr, userlogic_data_in, userlogic_address, userlogic_data_out
		);
		
		--sram sync interface
		
		
end Behavioral;
