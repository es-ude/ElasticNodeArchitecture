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
use IEEE.NUMERIC_STD.ALL;

library neuralnetwork;
use neuralnetwork.Common.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

entity Neuron is
	--generic	(
	--	input_number 		: 	integer := input_number;
	--	output_number		:	integer := output_number
	--	);
--	generic (
--		index					:	integer range 0 to maxWidth-1
--		);
	port (
		clk						:	in std_logic;

		n_feedback				:	in integer range 0 to 2;

		current_layer			:	in uint8_t;
		current_neuron			: 	in uint8_t;
		--index					:	in integer range 0 to maxWidth-1;

		input_connections 		: 	in fixed_point_vector;
		input_errors			:	in fixed_point_vector;

		output_connection		:	out fixed_point := zero;
		output_previous			:	in fixed_point;
		output_errors			: 	out fixed_point_vector := (others => zero);
		
		weights_in				: 	in fixed_point_vector;
		weights_out				: 	out fixed_point_vector := (others => factor_2);
		
		bias_in					: 	in fixed_point;
		bias_out				: 	out fixed_point
		);
end Neuron;

architecture Behavioral_Neuron of Neuron is
	signal delta_signal				:	fixed_point := real_to_fixed_point(0.0);
	signal error_factor				:	fixed_point;
	signal tf_signal 				:	fixed_point;
	signal output_connection_signal	:	fixed_point;
	signal output_layer				:	std_logic; -- tell neuron to only consider own error
	signal index 					: integer range 0 to maxWidth;
	signal first_hidden_layer_s		: boolean;
begin
	output_layer <= '1' when current_layer = totalLayers-1 else '0';
	index <= to_integer(current_neuron);

	process (input_errors, output_layer, current_neuron)
	begin
		-- if falling_edge(clk) then 
		if output_layer = '1' then
			error_factor <= input_errors(index);
		else
			error_factor <= sum(input_errors);
		end if;
		-- end if;
	end process;
	output_connection <= output_connection_signal;
	
sig: 
	entity neuralnetwork.sigmoid(Behavioral) port map (tf_signal, output_connection_signal);

	process (clk, n_feedback)
		variable bias				:	fixed_point := zero;
		variable tf					: 	fixed_point := zero;
		variable output_factor 		: 	fixed_point;
		variable out_prev			: 	fixed_point;
		variable delta				:	fixed_point := zero;
		variable weights			: 	fixed_point;
		variable first_hidden_layer	: 	boolean;
	begin
		if rising_edge(clk) then
			if n_feedback = 1 then
				-- indicate to ignore larger indexes of when input smaller than hidden
				first_hidden_layer := current_layer = 1;
				first_hidden_layer_s <= first_hidden_layer;

				if current_layer = 0 then
					-- first layer only passes through 
					if input_connections(index) = factor then
						-- max tf for output = '1'
						tf_signal <= maxValue;
					else
						tf_signal <= zero;
					end if;
				else
					--calculate output values
					tf := weighted_sum(weights_in, input_connections, first_hidden_layer) + bias_in;
					tf_signal <= tf;
				end if;
				
				weights_out <= weights_in;
			elsif n_feedback = 0 then
				output_factor := multiply(output_previous, factor - output_previous);
				-- TODO output_previous being set up with output, need to add earlier
				delta := multiply(output_factor, error_factor); -- input connection is output of previous cycle
				delta_signal <= delta;

				bias := bias_in + delta;
				bias_out <= bias;

				-- correct weight
				for i in 0 to weights_in'length - 1 loop 
					output_errors(i) <= multiply(weights_in(i), delta);
				
					weights :=  weights_in(i) + multiply(delta, input_connections(i));
					weights_out(i) <= weights;
				end loop;
			end if;
		end if;
	end process;
end Behavioral_Neuron;

