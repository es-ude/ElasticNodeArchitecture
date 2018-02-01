library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.std_logic_arith.all;
use ieee.numeric_std.all;


library work;
use work.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

library matrixMultiplication;
--library vectordotproduct;
library neuralnetwork;

--!
--! @brief      Main class for connecting all the components involved in the
--!             middleware
--!
entity genericProject is
	port (
		--userlogic_busy	: out std_logic;
		--userlogic_sleep: out std_logic;

		-- ARD_RESET 	: out std_logic;
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
		
		clk_32		: in std_ulogic;	--! Clock 32 MHz
		clk_50		: in std_ulogic;
		
		--rx				: in std_logic;
		--tx 			: out std_logic;
		
		-- reconfiguration ports
		-- selectmap 	: in std_logic_vector(7 downto 0);
		cclk			: in std_logic;
		
		-- xmem
		mcu_ad		: inout std_logic_vector(7 downto 0) := (others => 'Z');
		mcu_ale		: in std_logic;
		mcu_a			: in std_logic_vector(15 downto 8);
		mcu_rd		: in std_logic;
		mcu_wr		: in std_logic;
		
		-- gpio
		gpio			: out std_logic_vector(19 downto 0) := (others => '0')
		-- kb_leds		: out kb_led_vector
	);
	attribute IOB 	: String;
end genericProject;


architecture Behavioral of genericProject is

signal invert_clk				: std_logic;
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
signal userlogic_busy_s			: std_logic;
signal userlogic_data_in, userlogic_data_out : uint8_t;
signal userlogic_address		: uint16_t;
signal userlogic_rd, userlogic_wr: std_logic;
signal reset 						: std_logic := '1';

-- higher level ports
signal sram_address				: uint16_t;
signal sram_data_out				: uint8_t;
signal sram_data_in 				: uint8_t;

-- attribute IOB of ad : signal is "TRUE";
signal address_s 					: std_logic_vector(15 downto 0);

constant OFFSET					: unsigned(15 downto 0) := x"2000";
constant USERLOGIC_OFFSET 		: unsigned(15 downto 0) := x"2100";
		-- MULTIBOOT			: unsigned(23 downto 0) := x"000000"
	
signal clk							: std_ulogic;
-- attribute IOB of sram_data_in : signal is "TRUE";
signal mw_leds						: std_logic_vector(3 downto 0);
signal calculate					: std_logic;
signal debug						: uint8_t;

-- compatibility signals for mojo
signal rx, tx, ard_reset		: std_logic;

begin

ARD_RESET <= '0';

invert_clk <= not clk;

clk <= clk_32;

leds <= mw_leds;
--leds(0) <= calculate;
--leds(1) <= reset;
--leds(2) <= userlogic_reset;
--leds(3) <= userlogic_busy_s;

gpio(0) <= calculate;
gpio(1) <= invert_clk;
gpio(2) <= userlogic_reset;
gpio(3) <= userlogic_busy_s;
gpio(19 downto 14) <= (others => '0');



-- todo add to mw the async -> sync comm part, and decode incoming data not meant for ul
mw: entity work.middleware(Behavioral)
	port map(
		reset,
		clk,

		-- userlogic
		userlogic_reset,
		userlogic_busy_s,
		userlogic_data_in,
		userlogic_data_out,
		-- userlogic_address,
		userlogic_rd,
		userlogic_wr,
		
		-- debug
		mw_leds,
		
		-- uart
		rx,
		tx,
		
		-- sram
		sram_address,
		sram_data_out,
		sram_data_in,
		mcu_rd,
		mcu_wr
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
		end if;
	end process;
	
	-- initialise user logic
	-- ul: entity work.Dummy(Behavioral) port map
	-- ul: entity vectordotproduct.VectorDotproductSkeleton(Behavioral) port map
	-- ul: entity matrixmultiplication.MatrixMultiplicationSkeleton(Behavioral) port map
	-- ul: entity neuralnetwork.NeuralNetworkSkeleton(Behavioral) generic map (1) port map
	ul: entity neuralnetwork.NetworkSkeleton(Behavioral) generic map (1) port map
	-- ul: entity work.KeyboardSkeleton(Behavioral) port map
		(
			invert_clk, userlogic_reset, userlogic_busy_s, userlogic_rd, userlogic_wr, userlogic_data_in, userlogic_address, userlogic_data_out, calculate, debug --, kb_leds
		);
	--userlogic_busy <= userlogic_busy_s;
	--userlogic_sleep <= userlogic_reset;
	gpio(12 downto 10) <= std_logic_vector(debug(2 downto 0));
	gpio(13) <= debug(3);
	-- leds <= std_logic_vector(debug(7 downto 4));
	
	-- inout of mcu_ad
	mcu_ad <= std_logic_vector(sram_data_out) when mcu_rd = '0' else (others => 'Z');
	sram_data_in <= unsigned(mcu_ad);
	
	--sram interface
	-- lower address latch
	process (reset, clk, mcu_ale) is 
		variable address_concat_var : uint16_t;
		variable address_var : uint16_t;
		variable userlogic_address_var : uint16_t;
		variable old_mcu_ale : std_logic;
	begin
		if reset = '1' then
			old_mcu_ale := '0';
		else 
			-- find falling edge of mcu_ale
			if rising_edge(clk) then
				if mcu_ale = '1' then
					address_concat_var := unsigned(mcu_a & mcu_ad);
					address_var := address_concat_var - OFFSET;
					userlogic_address_var := address_concat_var - USERLOGIC_OFFSET;
					address_s <= std_logic_vector(address_var);
					userlogic_address <= userlogic_address_var;
				end if;
--				-- see if ale has changed
--				if mcu_ale /= old_mcu_ale then
--					if mcu_ale = '0' then -- was '1'
--						address_var := unsigned(mcu_a & mcu_ad) - OFFSET;
--						userlogic_address_var := unsigned(mcu_a & mcu_ad) - USERLOGIC_OFFSET;
--						address_s <= std_logic_vector(address_var);
--						userlogic_address <= userlogic_address_var;
--					end if;
--					old_mcu_ale := mcu_ale;
--				end if;
			--if falling_edge(mcu_ale) then
				
			end if;
		end if;
	end process;
	sram_address <= unsigned(address_s);
	-- userlogic_done <= '1' when (mcu_wr = '0' and sram_address = x"0004") or mcu_wr = '1' else '0';

end Behavioral;
