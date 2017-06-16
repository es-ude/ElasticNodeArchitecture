----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:54:44 07/07/2015 
-- Design Name: 
-- Module Name:    Layer - Behavioral 
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

entity InputLayer is
	port (
			clk				:	in std_logic;

			n_feedback		:	in std_logic;

			connections_in	:	in uintw_t;
			connections_out	:	out fixed_point_vector;

			errors_in		:	in fixed_point_vector;
			errors_out		:	out fixed_point_vector
		);
end InputLayer;

architecture Behavioral of InputLayer is
	signal errors_matrix : fixed_point_matrix;
	component sumMux
		port (
			--clk			:	in std_logic;
			errors 		:	in fixed_point_matrix;
			errors_out	: 	out fixed_point_vector
			);
	end component;

	component InputNeuron
		port (
			clk					:	in std_logic;

			n_feedback			:	in std_logic;

			input_connections : 	in uintw_t;
			input_errors		:	in fixed_point_vector;

			output_connection	:	out fixed_point;
			output_errors		: 	out fixed_point_vector
			);
	end component;


begin

	mux : sumMux port map
		(
			--clk => clk,
			errors => errors_matrix,
			errors_out => errors_out
		);

	gen_neutrons:
	for i in 0 to w-1 generate neuron_x : InputNeuron port map 
		(
			clk => clk, 
			n_feedback => n_feedback,
			input_connections => connections_in, 
			input_errors => errors_in,
			output_connection => connections_out(i),
			output_errors => errors_matrix(i)
		);
	end generate;
end Behavioral;

