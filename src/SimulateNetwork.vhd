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
library neuralnetwork;
use neuralnetwork.Common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimulateNetwork is
end SimulateNetwork;

architecture Behavioral of SimulateNetwork is
	component Network is
	port (
			clk				: 	in std_logic;
			reset				: in std_logic;
			
			learn			:	in std_logic;
			data_rdy		:	out std_logic := '0';
			calculate          :   in std_logic;

			connections_in	:	in uintw_t;
			connections_out	:	out fixed_point_vector;
			
			wanted			:	in fixed_point_vector
		);
	end component;

	signal clk : std_logic := '0';	
	signal learn, data_rdy : std_logic := 'Z';
	constant period : time := 100 ns;
	constant repeat : integer := 10;

	signal wanted			: 	fixed_point_vector;
	signal calculate, reset          :   std_logic;
	signal conn_in			:	uintw_t := (others => '0');
	signal conn_out 		: fixed_point_vector := (others => real_to_fixed_point(0.0));
	
	signal busy : boolean := true;
begin
	
	process
	begin
		if busy then
			wait for period/2;
			clk <= not clk;
		else 
			wait;
		end if;
	end process;

	uut: Network port map (clk, reset, learn, data_rdy, calculate, conn_in, conn_out, wanted);
	process begin
		reset <= '1';
		wait for period;
		reset <= '0';
		--n_feedback <= 'Z';

		learn <= '0';
		conn_in <= ('1', '0', '1');
		wanted <= (real_to_fixed_point(1.0), real_to_fixed_point(1.0), real_to_fixed_point(0.0));
		
				calculate <= '0';
		wait for period;
		calculate <= '1';
		wait for period;
		calculate <= '0';
		
		wait for period;
		learn <= '1';
		--n_feedback <= '1';
		wait for period * 2 * (l * 2 + 1);
		calculate <= '0';
		wait for period;
		calculate <= '1';
		wait for period;
		calculate <= '0';
		wait for period * 2 * (l * 2 + 1);
		busy <= false;
		wait;
	end process;
end Behavioral;

