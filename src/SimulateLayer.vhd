----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:18:31 07/08/2015 
-- Design Name: 
-- Module Name:    SimulateLayer - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library neuralnetwork;
use neuralnetwork.Common.all;

entity SimulateLayer is
end SimulateLayer;

architecture Behavioral of SimulateLayer is	
	component Layer 
		port (
			clk				:	in std_logic;

			n_feedback		:	in std_logic;

			connections_in	:	in fixed_point_vector;
			connections_out	:	out fixed_point_vector;

			errors_in		:	in fixed_point_vector;
			errors_out		:	out fixed_point_vector;
			
			weights_in			: 	in fixed_point_matrix; -- one fpv per neuron
			weights_out			: 	out fixed_point_matrix
		);
	end component;

	signal clk : std_logic := '0';
	constant period : time := 100 ns;

	signal conn_in, conn_out : fixed_point_vector := (others => (others => '0'));
	signal err_in, err_out : fixed_point_vector := (others => (others => '0'));
	signal n_feedback : std_logic := 'Z';

	signal errors_in		:	fixed_point_vector;
	signal connections_out	: 	fixed_point_vector;
	signal busy 	: boolean := true;
	signal weights : fixed_point_matrix := (others => (others => real_to_fixed_point(0.5)));
	-- signal weights : fixed_point_vector := (others => real_to_fixed_point(0.5));
	
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

	uut : Layer port map (clk, n_feedback, conn_in, conn_out, err_in, err_out, weights, weights);
	process begin
		n_feedback <= 'Z';
		
		conn_in(0) <= real_to_fixed_point(1.0);
		conn_in(2) <= real_to_fixed_point(1.0);
		
		wait for period;
		n_feedback <= '1';
		wait for period;
		
		err_in(0) <= real_to_fixed_point(1.0);
		err_in(2) <= real_to_fixed_point(1.0);

		n_feedback <= '0';
		wait for period*4;
		n_feedback <= 'Z';
		wait for period*4;
		busy <= false;
		wait;
	end process;
end Behavioral;

