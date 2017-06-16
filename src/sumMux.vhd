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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


--library ieee_proposed;
--use ieee_proposed.fixed_float_types.all;
--use ieee_proposed.fixed_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- important: each neuron assigns its errors to one vector in the matrix,
-- therefore the output to a certain neuron needs to be a combination of all vectors 
-- hence output neuron x gets the x'th error from each vector 
entity sumMux is
	-- size is number of elements in vector, not matrix
	port (
		--clk			:	in std_logic;
		errors 		:	in fixed_point_matrix;
		errors_out	: 	out fixed_point_vector
		);
end sumMux;

architecture Behavioral of sumMux is
begin
	process(errors) 
	variable errors_out_signal : fixed_point_vector;
	begin
		--if (rising_edge(clk)) then
			errors_out_signal := (others => (others => '0'));
			-- i counts over output neurons
			for i in 0 to w - 1 loop
				-- j counts over input neurons
				for j in 0 to w - 1 loop
					--errors_out_signal(i) := resize_fixed_point(errors_out_signal(i) + errors(j)(i));
					errors_out_signal(i) := errors_out_signal(i) + errors(j)(i);
				end loop;
			end loop;
		--end if;
		errors_out <= errors_out_signal;
	end process;
end Behavioral;

