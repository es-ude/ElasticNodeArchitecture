----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:58:32 07/07/2015 
-- Design Name: 
-- Module Name:    sumMux - Behavioral 
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

library neuralnetwork;
--use DesignLab.all;
use neuralnetwork.Common.all;
-- important: each neuron assigns its errors to one vector in the matrix,
-- therefore the output to a certain neuron needs to be a combination of all vectors 
-- hence output neuron x gets the x'th error from each vector 
entity sumMux is
	port (
			reset		:	in std_logic;
			clk			:	in std_logic;
			en 			:	in std_logic;
			index		:	in integer range 0 to maxWidth-1;
			errors_in	:	in fixed_point_vector;
			errors_out	: 	out fixed_point_vector
		);
end sumMux;

architecture Behavioral of sumMux is
	signal errors_out_signal : fixed_point_vector;
begin
	process(reset, clk, errors_in) 
		variable errors_out_var : fixed_point_vector;
	begin
		if reset = '1' then
			-- errors_out <= (others => zero);
			errors_out_var := (others => zero);
			-- errors_out_signal := (others => (others => '0'));
		elsif falling_edge(clk) then
			if en = '1' then
				--if index = 0 then
				--	errors_out_signal <= errors_in;
				--else
					-- i counts over output neurons
					for i in 0 to maxWidth - 1 loop
						-- j counts over input neurons
						-- for j in 0 to maxWidth - 1 loop
						errors_out_var(i) := errors_out_var(i) + errors_in(i);
							--errors_out_signal(i) := resize_fixed_point(errors_out_signal(i) + errors(j)(i));
							--errors_out_var := errors_out_var + errors_in(i);
						-- end loop;
					end loop;
				--end if;
			end if;
			errors_out_signal <= errors_out_var;
		end if;
	end process;
	errors_out <= errors_out_signal;
	

end Behavioral;

