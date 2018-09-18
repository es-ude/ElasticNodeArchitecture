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
		reset					:	in std_logic;

		n_feedback				:	in integer range 0 to 2;

		current_layer			:	in uint8_t;
		current_neuron			: 	in uint8_t;
		--index					:	in integer range 0 to maxWidth-1;

		input_connections 		: 	in fixed_point_vector;
		input_error				:	in fixed_point;

		output_connection		:	out fixed_point := zero;
		output_previous			:	in fixed_point;
		output_errors			: 	out fixed_point_vector := (others => zero);
		
		weights_in				: 	in fixed_point_vector;
		weights_out				: 	out fixed_point_vector := (others => factor_2);
		
		bias_in					: 	in fixed_point;
		bias_out				: 	out fixed_point
		);
end Neuron;

architecture Behavioral of Neuron is
	signal delta_signal				:	fixed_point := real_to_fixed_point(0.0);
	signal output_factor_s			:	fixed_point;
	--signal error_factor				:	fixed_point;
	signal lastHidden_s				: 	boolean;
	signal tf_signal 				:	fixed_point;
	signal output_connection_signal	:	fixed_point;
	signal output_layer				:	std_logic; -- tell neuron to only consider own error
	signal index 					: integer range 0 to maxWidth;
	signal first_hidden_layer_s		: boolean;

	signal TEMP : double_fixed_point;
	signal TEMP2 : fixed_point;
	signal TEMP3 : signed(factor_shift-1 downto 0);

	begin
	output_layer <= '1' when current_layer = totalLayers-1 else '0';
	index <= to_integer(current_neuron);

	--process (reset, input_errors, output_layer, current_neuron)
	--	variable lastHidden : boolean;
	--begin
	--	if reset = '1' then
	--		lastHidden := false;
	--	else
	--		if output_layer = '1' then
	--			error_factor <= input_errors(index);
	--			lastHidden := true;
	--		else
	--			error_factor <= sum(input_errors, lastHidden);
	--			lastHidden := false;
	--		end if;
	--	end if;
	--	lastHidden_s <= lastHidden;
	--end process;
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

	variable TEMPv : double_fixed_point;
	variable TEMP2v : fixed_point;
	variable TEMP3v : signed(factor_shift-1 downto 0);
	begin
		if reset = '1' then
			bias := zero;
			tf := zero;
			delta := zero;
		elsif rising_edge(clk) then
			if n_feedback = 1 then
				-- indicate to ignore larger indexes of when input smaller than hidden
				first_hidden_layer := current_layer = 0;
				first_hidden_layer_s <= first_hidden_layer;

				--if current_layer = 0 then
				--	-- first layer only passes through 
				--	if input_connections(index) = factor then
				--		-- max tf for output = '1'
				--		tf_signal <= maxValue;
				--	else
				--		tf_signal <= minValue;
				--	end if;
				--else
				--calculate output values
				tf := weighted_sum(weights_in, input_connections, first_hidden_layer) + bias_in;
				tf_signal <= tf;
				--end if;
				
				weights_out <= weights_in;
				output_errors <= (others => zero);
			elsif n_feedback = 0 then
				output_factor := multiply(output_previous, factor - output_previous);
				output_factor_s <= output_factor;
				-- TODO output_previous being set up with output, need to add earlier
				delta := multiply(output_factor, input_error); -- input connection is output of previous cycle

				--A_short := A(fixed_point'length+1-factor_shift_2 downto factor_shift_2);
				--B_short := B(fixed_point'length+1-factor_shift_2 downto factor_shift_2);
				TEMPv := output_factor * input_error;
				--TEMP2 := TEMP(factor_shift+fixed_point'length-1 downto factor_shift);
				--return A_short * B_short;
				TEMP2v := TEMPv(factor_shift+fixed_point'length-1 downto factor_shift);
				TEMP3v := TEMPv(factor_shift-1 downto 0);
				-- tend to infinity if negative result
				-- add one if result is negative and there is a rest being thrown away
				if TEMP2(fixed_point'length-1) = '1' and TEMP3 /= 0 then
					TEMP2v := TEMP2v + 1;
				end if;

				TEMP <= TEMPv;
				TEMP2 <= TEMP2v;
				TEMP3 <= TEMP3v;

				delta_signal <= delta;

				bias := bias_in + delta;
				bias_out <= bias;

				-- correct weight
				-- these weights are the incoming connection weights
				for i in 0 to weights_in'length - 1 loop 
					output_errors(i) <= multiply(weights_in(i), delta);
				
					weights := weights_in(i) + multiply(delta, input_connections(i));
					weights_out(i) <= weights;
				end loop;

				-- zero the other weights for correctness sake 
				for i in weights_in'length to maxWidth-1 loop
					output_errors(i) <= zero;
				
					--weights := weights_in(i) + multiply(delta, input_connections(i));
					weights_out(i) <= zero;
				end loop;	
			end if;
		end if;
	end process;
end Behavioral;

