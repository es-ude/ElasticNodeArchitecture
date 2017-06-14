----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:51:33 07/06/2015 
-- Design Name: 
-- Module Name:    Neuron - Behavioral 
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
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- use ieee.math_real.all;

library neuralnetwork;
-- use DesignLab.ALL;
use neuralnetwork.Common.ALL;
use neuralnetwork.Sigmoid.all;

library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Neuron is
	--generic	(
	--	input_number 		: 	integer := input_number;
	--	output_number		:	integer := output_number
	--	);
	generic (
		index					:	integer range 0 to w-1
		);
	port (
		clk					:	in std_logic;

		n_feedback			:	in std_logic;

		input_connections : 	in fixed_point_vector;
		input_errors		:	in fixed_point_vector;

		output_connection	:	out fixed_point := real_to_fixed_point(0.0);
		output_errors		: 	out fixed_point_vector := (others => zero);
		
		weights_in			: 	in fixed_point_vector;
		weights_out			: 	out fixed_point_vector := (others => factor_2)
		);
end Neuron;

architecture Behavioral_Neuron of Neuron is
	signal weights			: 	fixed_point_vector := (others => real_to_fixed_point(0.5));
	signal delta_signal		:	fixed_point := real_to_fixed_point(0.0);
	signal error_factor		:	fixed_point;
	signal tf_signal 			:	fixed_point;
	signal output_connection_signal	:	fixed_point;
begin
	process (clk, input_errors)
	begin
		if falling_edge(clk) then 
			error_factor <= sum(input_errors);
		end if;
	end process;
	output_connection <= output_connection_signal;

	process (clk, n_feedback)
		variable bias			:	fixed_point := zero;
		variable tf				: 	fixed_point := zero;
		variable delta			:	fixed_point := zero;
		variable weights		: 	fixed_point;
	begin
		if rising_edge(clk) then
			if n_feedback = '1' then
				--calculate output values
				tf := weighted_sum(weights_in, input_connections) + bias;
				tf_signal <= tf;
				--output_connection_signal <= resize_fixed_point(real_to_fixed_point(1.0) / resize_fixed_point(1.0 + exp(resize_fixed_point(-tf))));
				output_connection_signal <= sigmoid(tf);
				
				weights_out <= weights_in;
			elsif n_feedback = '0' then
				-- delta := resize_fixed_point(resize_fixed_point(output_connection_signal * (factor - (output_connection_signal))) * error_factor);
				-- delta := multiply(multiply(output_connection_signal, factor - output_connection_signal), error_factor);
				delta := multiply(multiply(input_connections(index), factor - input_connections(index)), error_factor); -- input connection is output of previous cycle
				--delta_signal <= delta;
				bias := bias + delta;

				-- correct weight
				for i in 0 to weights_in'length - 1 loop 
					-- weights(i) <= resize_fixed_point(delta * input_connections(i)) + weights(i);
					weights := multiply(delta, input_connections(i)) + weights_in(i);
					output_errors(i) <= multiply(weights, delta);
					weights_out(i) <= weights;
				end loop;
			else
				weights_out <= weights_in;
			end if;
		else
			-- weights_out <= weights_in;
		end if;
	end process;
end Behavioral_Neuron;

