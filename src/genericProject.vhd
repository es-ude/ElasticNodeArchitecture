library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.std_logic_arith.all;
use ieee.numeric_std.all;


library work;
use work.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

library matrixmultiplication;
library vectordotproduct;
library neuralnetwork;

--!
--! @brief      Main class for connecting all the components involved in the
--!             middleware
--!
entity genericProject is
	port (
		userlogic_done	: out std_logic;
		userlogic_sleep: out std_logic;

		ARD_RESET 	: out std_logic;
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
		mcu_wr		: in std_logic--;
		
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
signal userlogic_done_s			: std_logic;
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

constant OFFSET					: unsigned(15 downto 0) := x"2200";
constant USERLOGIC_OFFSET 		: unsigned(15 downto 0) := x"2300";
		-- MULTIBOOT			: unsigned(23 downto 0) := x"000000"
	
-- attribute IOB of sram_data_in : signal is "TRUE";


begin

ARD_RESET <= '0';

invert_clk <= not clk;

-- todo add to mw the async -> sync comm part, and decode incoming data not meant for ul
mw: entity work.middleware(Behavioral)
	port map(
		reset,
		clk,

		-- userlogic
		userlogic_reset,
		userlogic_done_s,
		userlogic_data_in,
		userlogic_data_out,
		-- userlogic_address,
		userlogic_rd,
		userlogic_wr,
		
		-- debug
		leds,
		
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
	ul: entity neuralnetwork.NeuralNetworkSkeleton(Behavioral) port map
	-- ul: entity work.KeyboardSkeleton(Behavioral) port map
		(
			invert_clk, userlogic_reset, userlogic_done_s, userlogic_rd, userlogic_wr, userlogic_data_in, userlogic_address, userlogic_data_out --, kb_leds
		);
	userlogic_done <= userlogic_done_s;
	userlogic_sleep <= userlogic_reset;
	
	-- inout of mcu_ad
	mcu_ad <= std_logic_vector(sram_data_out) when mcu_rd = '0' else (others => 'Z');
	sram_data_in <= unsigned(mcu_ad);
	
	--sram interface
	-- lower address latch
	process (mcu_ale) is 
		variable address_var : uint16_t;
		variable userlogic_address_var : uint16_t;
	begin
		if falling_edge(mcu_ale) then
			address_var := unsigned(mcu_a & mcu_ad) - OFFSET;
			userlogic_address_var := unsigned(mcu_a & mcu_ad) - USERLOGIC_OFFSET;
			address_s <= std_logic_vector(address_var);
			userlogic_address <= userlogic_address_var;
		end if;
	end process;
	sram_address <= unsigned(address_s);
	-- userlogic_done <= '1' when (mcu_wr = '0' and sram_address = x"0004") or mcu_wr = '1' else '0';
	
	--sram sync interface
--sram: entity work.sramSlave(Behavioral) generic map
--	(
--		x"2200"
--	)
--	port map
--	(
--		clk,
--		
--		mcu_ad_s,
--		mcu_ale,
--		mcu_a,
--		mcu_rd,
--		mcu_wr,
--		
--		-- higher level ports
--		sram_address,
--		sram_data_out,
--		sram_data_in,
--		sram_rd,
--		sram_wr
--	);
--		
end Behavioral;
