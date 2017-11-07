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

entity SimulateNeuralNetwork is
end SimulateNeuralNetwork;

architecture Behavioral of SimulateNeuralNetwork is
	component NeuralNetwork is
    Port (
		clk             :  in std_logic;
		reset				:  in std_logic;
		
		learn           :  in std_logic;
		data_rdy        :  out std_logic;
		busy				 :  out std_logic;
		calculate       :  in std_logic;
		
		connections_in  :  in uintw_t;
		wanted          :  in uintw_t;
		connections_out :  out uintw_t;
		
		debug				 :  out uint8_t
        );
	end component;

	signal clk_s : std_logic := '0';	
	signal learn, data_rdy, calculate, ul_busy : std_logic := 'Z';
	signal reset : std_logic := '1';
	constant period : time := 40 ns;
	constant repeat : integer := 10;

	signal wanted					: 	uintw_t := (others => '0');
	signal conn_in, conn_out 	: uintw_t := (others => '0');
	
	signal busy 	: boolean := true;
	
	signal debug : uint8_t;

begin
--	data_in(w-1 downto 0) <= conn_in;
--	data_in(2*w-1 downto w) <= wanted;
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

	uut: NeuralNetwork port map (clk_s, reset, learn, data_rdy, ul_busy, calculate, conn_in, wanted, conn_out, debug);
	process 
		variable I: integer range 0 to 1000;
	begin
		wait for period * 16;
		reset <= '0';

L: loop
	exit L when I = 2;
		--n_feedback <= 'Z';
		learn <= '1';
		conn_in <= to_unsigned(5, w); -- (real_to_fixed_point(1.0), real_to_fixed_point(0.0), real_to_fixed_point(1.0));
		wanted <= to_unsigned(10, w); -- (real_to_fixed_point(1.0), real_to_fixed_point(1.0), real_to_fixed_point(0.0));
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

