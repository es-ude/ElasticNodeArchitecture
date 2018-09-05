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
use neuralnetwork.Common.all;

entity SimulateNetwork is
end SimulateNetwork;

architecture Behavioral of SimulateNetwork is
	component Network is
	port (
		clk						: 	in std_logic;
		reset					:	in std_logic;
		
		learn					:	in std_logic;
		data_rdy				:	out std_logic := '0';
		busy				 	:  out std_logic;
		calculate				:   in std_logic;
	
		connections_in			:	in fixed_point_vector;
		connections_out			:	out fixed_point_vector;
		
		-- wanted				:	in fixed_point_vector
		wanted					:	in fixed_point_vector

		weights_wr_en 			:	in std_logic;
		weights_vector			:	buffer weights_vector;
		debug		       		:  out uint8_t
	);
	end component;

	signal clk_s : std_logic := '0';	
	signal learn, data_rdy, calculate, ul_busy : std_logic := 'Z';
	signal reset : std_logic := '1';
	constant period : time := 40 ns;
	constant repeat : integer := 10;

	signal wanted					: 	fixed_point_vector := (others => zero);
	signal conn_in, conn_out 	: fixed_point_vector := (others => zero);
	
	signal busy 	: boolean := true;
	
	signal weights_en : std_logic;
	signal weights_vector : weights_vector;
	
	signal debug : uint8_t;
	
	signal multiply_result : fixed_point;	-- 16
	signal multiply_test : fixed_point;		-- 16
	signal A : fixed_point := factor_2; -- 16
	signal B : fixed_point := factor_2; -- 16
	signal TMP, TMP2 : signed(7 downto 0); -- 8
	signal TMP3 : signed(15 downto 0); -- 16
		
begin

	multiply_result <= multiply(A, B);
	TMP <= A(12 downto 5);
	TMP2 <= B(12 downto 5);
	TMP3 <= TMP * TMP2;
	multiply_test <= TMP3(15 downto 0);

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

	uut: Network port map (clk_s, reset, learn, data_rdy, ul_busy, calculate, conn_in, wanted, conn_out, debug);
	process 
		variable I: integer range 0 to 1000;
	begin
		wait for period * 16;
		reset <= '0';

		-- set weights of network


L: loop
	exit L when I = 2;
		--n_feedback <= 'Z';
		learn <= '1';
		conn_in <= (real_to_fixed_point(1.0), real_to_fixed_point(0.0), real_to_fixed_point(1.0));
		wanted <= (real_to_fixed_point(1.0), real_to_fixed_point(1.0), real_to_fixed_point(0.0));
		calculate <= '1';
		
		wait for period;
		calculate <= '0';
		wait until data_rdy = '1';
		wait for period*4; 
		
		learn <= '1';
		calculate <= '1';
		wait for period;
		calculate <= '0';
		
		--learn <= '1';
		----n_feedback <= '1';
		wait until data_rdy = '1';
		wait for period * 4; 
		
		I := I + 1;
		
		end loop;
		

		busy <= false;
		wait;
	end process;
end Behavioral;

