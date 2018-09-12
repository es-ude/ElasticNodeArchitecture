----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:20:33 07/27/2015 
-- Design Name: 
-- Module Name:    SimulateNetwork - Behavioral 
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
use ieee.numeric_std.all;

library fpgamiddlewarelibs;
-- use fpgamiddlewarelibs.Common.all;
use fpgamiddlewarelibs.userlogicinterface.all;


library neuralnetwork;
use neuralnetwork.all;
use neuralnetwork.Common.all;

entity TestFixedPointANN is
end TestFixedPointANN;

architecture Behavioral of TestFixedPointANN is
	signal clk_s : std_logic := '0';	
	signal learn, data_rdy, calculate, ul_busy : std_logic := 'Z';
	signal reset : std_logic := '1';
	constant period : time := 10 ps;
	--constant repeat : integer := 10;
	constant NUM_LOOPS : integer := 2500; -- (2x 1000)

	signal wanted				: 	fixed_point_vector;
	signal conn_in, conn_out 	: 	fixed_point_vector;

	signal weights_wr : std_logic := '0';
	signal weights : weights_vector;
	
	signal busy 	: boolean := true;
	signal repeatCount : integer;
	
	signal debug : uint8_t;

begin
--	data_in(maxWidth-1 downto 0) <= conn_in;
--	data_in(2*maxWidth-1 downto w) <= wanted;
--	data_in(2*w) <= learn;
--	data_in(2*w + 1) <= enable;
--
--	data_rdy <= data_out(2*w+2);
--	conn_out <= data_out(3*w+2 downto 2*w+3);
	
	process
	begin
		if busy then
			wait for period/2;
			clk_s <= not clk_s;
		else 
			wait;
		end if;
	end process;

uut: entity neuralnetwork.FixedPointANN(Behavioral) port map 
	(
		clk => clk_s, 
		reset => reset, 
		learn => learn, 
		data_rdy => data_rdy, 
		busy => ul_busy, 
		calculate => calculate, 
		connections_in_fp => conn_in, 
		connections_out_fp => conn_out, 
		wanted_fp => wanted, 
		weights_wr_en => weights_wr,
		weights => weights,
		debug => debug
	);

	process 
		--variable i: integer range 0 to 1000;
	begin
		wait for period * 16;
		reset <= '0';

	learn <= '1';
	-- train XOR (only using second output)
	for i in 0 to NUM_LOOPS loop 

		-- 11 00
		conn_in <= (zero, zero, factor, factor);
		wanted <= (others => zero);
		calculate <= '1';
		wait for period;
		calculate <= '0';
		wait until ul_busy = '0';
		wait for period;

		-- 10 01
		conn_in <= (zero, zero, zero, factor);
		wanted <= (zero, zero, zero, factor);
		calculate <= '1';
		wait for period;
		calculate <= '0';
		wait until ul_busy = '0';
		wait for period;

		-- 01 01
		conn_in <= (zero, zero, factor, zero);
		wanted <= (zero, zero, zero, factor);
		calculate <= '1';
		wait for period;
		calculate <= '0';
		wait until ul_busy = '0';
		wait for period;

		-- 00 00
		conn_in <= (others => zero);
		wanted <= (others => zero);
		calculate <= '1';
		wait for period;
		calculate <= '0';
		wait until ul_busy = '0';
		wait for period;

		repeatCount <= i;
		
	end loop;

	-- query results
	learn <= '0';

	conn_in <= (zero, zero, zero, factor);
	wanted <= (zero, zero, zero, factor);
	calculate <= '1';
	wait for period;
	calculate <= '0';
	wait until ul_busy = '0';
	wait for period;
	assert conn_out(0) > factor_2 report "Result incorrect for 10";

	conn_in <= (zero, zero, zero, factor);
	wanted <= (zero, zero, zero, factor);
	calculate <= '1';
	wait for period;
	calculate <= '0';
	wait until ul_busy = '0';
	wait for period;
	assert conn_out(0) > factor_2 report "Result incorrect for 10";

	conn_in <= (others => zero);
	wanted <= (others => zero);
	calculate <= '1';
	wait for period;
	calculate <= '0';
	wait until ul_busy = '0';
	wait for period;
	assert conn_out(0) < factor_2 report "Result incorrect for 00";

	conn_in <= (zero, zero, factor, factor);
	wanted <= (others => zero);
	calculate <= '1';
	wait for period;
	calculate <= '0';
	wait until ul_busy = '0';
	wait for period;
	assert conn_out(0) < factor_2 report "Result incorrect for 11";

	conn_in <= (zero, zero, factor, zero);
	wanted <= (zero, zero, zero, factor);
	calculate <= '1';
	wait for period;
	calculate <= '0';
	wait until ul_busy = '0';
	wait for period;
	assert conn_out(0) > factor_2 report "Result incorrect for 01";

	conn_in <= (zero, zero, zero, factor);
	wanted <= (zero, zero, zero, factor);
	calculate <= '1';
	wait for period;
	calculate <= '0';
	wait until ul_busy = '0';
	wait for period;
	assert conn_out(0) < factor_2 report "Result incorrect for 10";

	wait for period * 4;
	busy <= false;
	wait;


--L: loop
--	exit L when I = 2;
--		--n_feedback <= 'Z';

--		learn <= '1';
--		conn_in <= to_unsigned(5, w); -- (real_to_fixed_point(1.0), real_to_fixed_point(0.0), real_to_fixed_point(1.0));
--		wanted <= to_unsigned(10, w); -- (real_to_fixed_point(1.0), real_to_fixed_point(1.0), real_to_fixed_point(0.0));
--		calculate <= '1';
		
--		wait for period;
--		calculate <= '0';
--		wait until data_rdy = '1';
--		wait for period*4; 
		
--		learn <= '1';
--		calculate <= '1';
--		wait for period;
--		calculate <= '0';
		
--		--learn <= '1';
--		----n_feedback <= '1';
--		wait until data_rdy = '1';
--		wait for period * 4; 
		
--		I := I + 1;
		
--		end loop;
		

--		busy <= false;
--		wait;
	end process;
end Behavioral;

