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

entity OutputLayer is
	port (
			clk				:	in std_logic;

			n_feedback		:	in std_logic;

			connections_in	:	in fixed_point_vector;
			connections_out	:	out fixed_point_vector;

			errors_in		:	in fixed_point_vector;
			errors_out		:	out fixed_point_vector
		);
end OutputLayer;

architecture Behavioral of OutputLayer is
	signal errors_matrix : fixed_point_matrix;

	component OutputNeuron
		port (
			clk					:	in std_logic;

			n_feedback			:	in std_logic;

			input_connections 	: 	in fixed_point_vector;
			input_error			:	in fixed_point;

			output_connection	:	out fixed_point;
			output_errors		: 	out fixed_point_vector
			);
	end component;


begin

--	out_neutron: OutputNeuron port map 
--        (
--            clk => clk,
--            n_feedback => n_feedback,
--            input_connections => connections_in,
--            input_error => errors_in,
--            output_connection => connection_out,
--            output_errors => errors_out -- not sure if this is correct
--        );
       
	gen_neutrons:
	for i in 0 to w-1 generate neuron_x : OutputNeuron port map 
		(
			clk => clk, 
			n_feedback => n_feedback,
			input_connections => connections_in, 
			input_error => errors_in(i), -- each neuron only gets its own error
			output_connection => connections_out(i),
			output_errors => errors_matrix(i)
		);
	end generate;
end Behavioral;

