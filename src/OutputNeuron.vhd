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
use ieee.math_real.all;

library work;
-- use DesignLab.ALL;
use work.Common.ALL;
use work.Sigmoid.all;

library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OutputNeuron is
	--generic	(
	--	input_number 		: 	integer := input_number;
	--	output_number		:	integer := output_number
	--	);
	port (
		clk					:	in std_logic;

		n_feedback			:	in std_logic;

		input_connections 	: 	in fixed_point_vector;
		input_error			:	in fixed_point;

		output_connection	:	out fixed_point := real_to_fixed_point(0.0);
		output_errors		: 	out fixed_point_vector := (others => real_to_fixed_point(0.0))
		);
end OutputNeuron;

architecture Behavioral_OutputNeuron of OutputNeuron is
	signal weights			: 	fixed_point_vector := (others => real_to_fixed_point(0.5));
	signal delta_signal		:	fixed_point := real_to_fixed_point(0.0);
	signal output_connection_signal	:	fixed_point;
begin
	output_connection <= output_connection_signal;

	process (clk, n_feedback)
		variable bias			:	fixed_point := (others => '0');
		variable tf				: 	fixed_point := (others => '0');
		variable delta			:	fixed_point := (others => '0');
	begin
		if rising_edge(clk) then
			if n_feedback = '1' then
				--calculate output values
				tf := weighted_sum(weights, input_connections) + bias;
				output_connection_signal <= sigmoid(tf);
			elsif n_feedback = '0' then
				-- delta := resize_fixed_point(resize_fixed_point(output_connection_signal * (factor - (output_connection_signal))) * input_error);
				delta := multiply(multiply(output_connection_signal, factor - output_connection_signal), input_error);
--                delta := output_connection_signal * (factor - output_connection_signal) * input_error;
				--delta_signal <= delta;
				bias := bias + delta;

				-- correct weight
				for i in 0 to weights'length - 1 loop 
					--weights(i) <= resize_fixed_point(delta * input_connections(i) + weights(i));
					weights(i) <= multiply(delta, input_connections(i) + weights(i));
					--output_errors(i) <= resize_fixed_point(weights(i) * delta);
					output_errors(i) <= multiply(weights(i), delta);
				end loop;
			end if;				
	
		end if;
	end process;
end Behavioral_OutputNeuron;

