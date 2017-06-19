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

entity Layer is
	port (
			clk						:	in std_logic;

			n_feedback				:	in std_logic;

			connections_in			:	in fixed_point_vector;
			connections_out		:	out fixed_point_vector;
			connections_out_prev	:	in fixed_point_vector;

			errors_in				:	in fixed_point_vector;
			errors_out				:	out fixed_point_vector;
			
			weights_in				: 	in fixed_point_matrix; -- one fpv per neuron
			weights_out				: 	out fixed_point_matrix
		);
end Layer;

architecture Behavioral of Layer is
	signal errors_matrix : fixed_point_matrix;
	
	-- signal errors_out, errors_in : fixed_point
	component sumMux
		port (
			--clk			:	in std_logic;
			errors 		:	in fixed_point_matrix;
			errors_out	: 	out fixed_point_vector
			);
	end component;

	component Neuron
		generic ( index		:	integer range 0 to w-1 );
		port (
			clk					:	in std_logic;

			n_feedback			:	in std_logic;

			input_connections : 	in fixed_point_vector;
			input_errors		:	in fixed_point_vector;

			output_connection	:	out fixed_point;
			output_previous	:	in fixed_point;
			output_errors		: 	out fixed_point_vector;
			
			weights_in			: 	in fixed_point_vector;
			weights_out			: 	out fixed_point_vector
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
	for i in 0 to w-1 generate neuron_x : Neuron generic map
	(
		index => i
	)
	port map 
	(
		clk => clk, 
		n_feedback => n_feedback,
		input_connections => connections_in, 
		input_errors => errors_in,
		output_connection => connections_out(i),
		output_previous => connections_out_prev(i),
		output_errors => errors_matrix(i),
		weights_in => weights_in(i),
		weights_out => weights_out(i)
	);
	end generate;
end Behavioral;

