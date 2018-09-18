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


entity FixedPointANNSkeleton is
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
		data_out			: out uint8_t -- std_logic_vector(31 downto 0)
		
		--calculate_out		: out std_logic;
		--debug				: out uint8_t
	);
end FixedPointANNSkeleton;

architecture Behavioral of FixedPointANNSkeleton is

	signal learn			:  std_logic;
	signal data_rdy			:  std_logic;
	signal calculate		:  std_logic;
	
	signal connections_in	:  fixed_point_vector;
	signal wanted			:  fixed_point_vector;
	signal connections_out	:  fixed_point_vector;
	signal error_out		: fixed_point;
	signal run_counter		:  uint8_t;
	
	signal half_clock		: std_logic := '0';
	signal busy_signal		: std_logic;

	signal weights 			: weights_vector;
	signal weights_wr		: std_logic := '0';

begin
	--calculate_out <= calculate;
	
-- half the clock
process (reset, clock) is
	variable val : std_logic := '0';
	variable counter : integer range 0 to clk_divider := 0;-- slow down to 5 Hz from 50 MHz: 50M/2 /5 = 5M
begin
	--if reset = '1' then
	--	val := '0';
	--	--half_clock <= '0';
	--	counter := 0;
	if rising_edge(clock) then
		--counter := counter + 1;
		--if counter = clk_divider then
			--counter := 0;
			val := not val;
			half_clock <= val;
		--end if;
	end if;
end process;
			

nn: entity neuralnetwork.FixedPointANN(Behavioral)
	port map 
	(
		clk => half_clock, 
		reset => reset, 
		learn => learn, 
		data_rdy => data_rdy, 
		busy => busy_signal, 
		calculate => calculate, 
		connections_in_fp => connections_in, 
		connections_out_fp => connections_out, 
		wanted_fp => wanted,
		error_out => error_out,
		--weights_wr_en => weights_wr,
		--weights => weights,
		debug => open
	);
	busy <= busy_signal;

	-- process data receive 
	process (clock, rd, wr, reset)
		variable assembleFixedPoint : fixed_point;
	begin
		
		if reset = '1' then
			data_out <= (others => '0');
			calculate <= '0';
			run_counter <= (others => '0');
			wanted <= (others => zero);
			connections_in <= (others => zero);
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
						-- each value is 2 bytes
						-- connections_in
						when 0 =>
							assembleFixedPoint := connections_in(0);
							assembleFixedPoint(7 downto 0) := signed(data_in);
							connections_in(0) <= assembleFixedPoint;
						when 1 =>
							assembleFixedPoint := connections_in(0);
							assembleFixedPoint(15 downto 8) := signed(data_in);
							connections_in(0) <= assembleFixedPoint;
						when 2 =>
							assembleFixedPoint := connections_in(1);
							assembleFixedPoint(7 downto 0) := signed(data_in);
							connections_in(1) <= assembleFixedPoint;
						when 3 =>
							assembleFixedPoint := connections_in(1);
							assembleFixedPoint(15 downto 8) := signed(data_in);
							connections_in(1) <= assembleFixedPoint;
						-- wanted
						when 4 =>
							assembleFixedPoint := wanted(0);
							assembleFixedPoint(7 downto 0) := signed(data_in);
							wanted(0) <= assembleFixedPoint;
						when 5 =>
							assembleFixedPoint := wanted(0);
							assembleFixedPoint(15 downto 8) := signed(data_in);
							wanted(0) <= assembleFixedPoint; 
						-- config
						when 6 => 
							learn <= data_in(0);
							calculate  <= '1'; -- queue calculate to happen
							run_counter <= run_counter + to_unsigned(1, run_counter'length);
						-- start
						when 7 =>
							calculate <= '0'; -- starts calculation
						when others =>
						end case;
					elsif rd = '0' then
						-- calculate <= '0';
						case to_integer(address_in) is
						-- connections_out
						when 0 =>
							--data_out(maxWidth-1 downto 0) <= connections_in(maxWidth-1 downto 0);
							assembleFixedPoint := connections_out(0);
							data_out <= unsigned(assembleFixedPoint(7 downto 0));
						when 1 =>
							assembleFixedPoint := connections_out(0);
							data_out <= unsigned(assembleFixedPoint(15 downto 8));
						-- error out
						when 2 => 
							assembleFixedPoint := error_out;
							data_out <= unsigned(assembleFixedPoint(15 downto 8));
						when 3 =>
							assembleFixedPoint := error_out;
							data_out <= unsigned(assembleFixedPoint(15 downto 8));
						when 200 => 
							data_out <= run_counter;
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
end Behavioral;

