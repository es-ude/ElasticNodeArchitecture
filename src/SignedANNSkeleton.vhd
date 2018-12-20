----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:00:45 12/20/2016 
-- Design Name: 
-- Module Name:    vector_dotproduct - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

library neuralnetwork;
use neuralnetwork.all;
use neuralnetwork.common.all;


entity SignedANNSkeleton is
	generic (
		clk_divider : integer := 5000000
		);
	port (
		-- control interface
		clock				: in std_logic;
		reset				: in std_logic; -- controls functionality (sleep)
		busy				: out std_logic; -- done with entire calculation
				
		-- indicate new data or request
		rd					: in std_logic;	-- request a variable
		wr 					: in std_logic; 	-- request changing a variable
		
		-- data interface
		data_in				: in uint8_t; -- std_logic_vector(31 downto 0);
		address_in			: in uint16_t;
		data_out			: out uint8_t; -- std_logic_vector(31 downto 0)
		
		-- spi interface
		flash_available		: in std_logic;
		spi_cs				: out std_logic;
		spi_clk				: out std_logic;
		spi_mosi			: out std_logic;
		spi_miso			: in std_logic
		--calculate_out		: out std_logic;
		--debug				: out uint8_t
	);
end SignedANNSkeleton;

architecture Behavioral of SignedANNSkeleton is

	signal learn			:  std_logic;
	signal data_rdy			:  std_logic;
	signal calculate		:  std_logic;
	
	signal connections_in	:  uintw_t;
	signal wanted			:  uintw_t;
	signal connections_out	:  uintw_t;
	signal run_counter		:  uint16_t;
	
	signal half_clock		: std_logic := '0';
	signal busy_signal		: std_logic;

	signal weights 			: weights_vector;
	signal weights_wr		: std_logic := '0';

	signal flash_address	: uint24_t;
	signal load_weights, load_weights_delayed, store_weights, store_weights_delayed, flash_ready, reset_weights : std_logic;

	signal debug			: uint8_t;
begin
	--calculate_out <= calculate;
	
-- half the clock
process (reset, clock) is
	variable val : std_logic := '0';
	variable counter : integer range 0 to clk_divider := 0;-- slow down to 5 Hz from 50 MHz: 50M/2 /5 = 5M
begin
	--if reset = '1' then
	--	val := '0';
	--	half_clock <= '0';
	--	counter := 0;
	if rising_edge(clock) then
		--counter := counter + 1;
		--if counter = clk_divider then
			counter := 0;
			val := not val;
			half_clock <= val;
		--end if;
	end if;
end process;
			

nn: entity neuralnetwork.SignedANN(Behavioral)
	port map 
	(
		clk => half_clock, 
		reset => reset, 
		learn => learn, 
		data_rdy => data_rdy, 
		busy => busy_signal, 
		calculate => calculate, 
		connections_in => connections_in, 
		connections_out => connections_out, 
		wanted => wanted,

		reset_weights => reset_weights,
		flash_address => flash_address,
		load_weights => load_weights_delayed,
		store_weights => store_weights_delayed,
		flash_ready => flash_ready,

		spi_cs => spi_cs,
		spi_clk => spi_clk,
		spi_mosi => spi_mosi,
		spi_miso => spi_miso,
		
		--weights_wr_en => weights_wr,
		--weights => weights,
		debug => debug
	);
	busy <= busy_signal;

	-- process data receive 
	process (clock, rd, wr, reset)
	begin
		
		if reset = '1' then
			data_out <= (others => '0');
			calculate <= '0';
			run_counter <= (others => '0');
			load_weights <= '0';
			store_weights <= '0';
			reset_weights <= '0';
			-- done <= '0';
		else
		-- beginning/end
			if rising_edge(clock) then
				-- process address of written value
				
				-- calculate <= '0'; -- set to not calculate (can be overwritten below)
				
				if wr = '0' or rd = '0' then
					-- variable being set
					-- reverse from big to little endian
					if wr = '0' then
						case to_integer(address_in) is
						
						when 0 =>
							connections_in(maxWidth-1 downto 0) <= data_in(maxWidth-1 downto 0);
						when 1 =>
							wanted(maxWidth-1 downto 0) <= data_in(maxWidth-1 downto 0);
						when 2 => 
							learn <= data_in(0);
						-- when 107 =>
							calculate  <= '1'; -- queue calculate to happen
						when 3 =>
							calculate <= '0'; -- starts calculation
							run_counter <= run_counter + to_unsigned(1, run_counter'length);
						when 4 =>
							flash_address(7 downto 0) <= data_in;
						when 5 =>
							flash_address(15 downto 8) <= data_in;
						when 6 =>
							flash_address(23 downto 16) <= data_in;
						when 7 => 
							load_weights <= data_in(0);
							store_weights <= data_in(1);
							reset_weights <= data_in(4);
						when others =>
						end case;
					elsif rd = '0' then
						-- calculate <= '0';
						case to_integer(address_in) is
						-- inputA
						-- row 1
						when 0 =>
							data_out(maxWidth-1 downto 0) <= connections_in(maxWidth-1 downto 0);
						when 1 =>
							data_out(maxWidth-1 downto 0) <= wanted(maxWidth-1 downto 0);
						when 2 => 
							data_out <= (others => '0');
							data_out(0) <= learn;
							data_out(1) <= data_rdy;
							data_out(2) <= busy_signal;
							data_out(3) <= calculate;
							data_out(4) <= half_clock;
						when 3 =>
							data_out(maxWidth-1 downto 0) <= connections_out(maxWidth-1 downto 0);
						when 4 =>
							data_out <= flash_address(7 downto 0);
						when 5 =>
							data_out <= flash_address(15 downto 8);
						when 6 =>
							data_out <= flash_address(23 downto 16);
						when 7 =>
							data_out <= (others => '0');
							data_out(0) <= load_weights;
							data_out(1) <= store_weights;
							data_out(2) <= flash_ready;
							data_out(3) <= store_weights_delayed;
							data_out(4) <= reset_weights;
							data_out(5) <= load_weights_delayed;
						when 8 =>
							data_out <= debug;
						when 200 => 
							data_out <= run_counter(7 downto 0);
						when 201 =>
							data_out <= run_counter(15 downto 8);
						when 255 =>
							data_out <= address_in(15 downto 8);
						when others =>
							data_out <= address_in(7 downto 0);
						end case;
--					else
--						calculate <= '0';
					end if;
				end if;
			end if;
		end if;
		-- intermediate_result_out <= intermediate_result;
	end process;

	-- delay store_weights until flash is available
	process (reset, clock, store_weights, load_weights, flash_available)
	begin
		if reset = '1' then
			store_weights_delayed <= '0';
			load_weights_delayed <= '0';
		elsif rising_edge(clock) then
			-- not loading weights
			if load_weights = '0' then
				load_weights_delayed <= '0';
			-- flash is available now and want to load
			elsif flash_available = '1' then
				load_weights_delayed <= '1';
			-- waiting for flash
			else 
				load_weights_delayed <= load_weights_delayed;
			end if;

			-- not storing weights
			if store_weights = '0' then
				store_weights_delayed <= '0';
			-- storing weights and flash is available
			elsif flash_available = '1' then
				store_weights_delayed <= '1';
			-- storing weights but flash is not available
			else
				store_weights_delayed <= store_weights_delayed; -- leave store_weights high after flash not available
			end if;
		end if;
	end process;

end Behavioral;

