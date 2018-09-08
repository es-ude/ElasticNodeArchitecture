----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:08:51 06/20/2017 
-- Design Name: 
-- Module Name:    WeightsToVector - Behavioral 
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
use neuralnetwork.common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity WeightsToVector is
port (
	matrix : in fixed_point_matrix;
	vector : out weights_vector
);
end WeightsToVector;

architecture Behavioral of WeightsToVector is

begin
	process (matrix) is
		variable fpv : fixed_point_vector;
		variable fp : fixed_point;
	begin
		-- first dim (each outside neuron)
		for i in 0 to maxWidth-1 loop
			fpv := matrix(i);
			-- second dim (each neuron)
			for j in 0 to maxWidth-1 loop
				fp := fpv(j);
				-- vector
				for k in 0 to b-1 loop
					 vector(k + j * (b) + i * (b*maxWidth)) <= fp(k);
				end loop;
			end loop;
		end loop;
	end process;
end Behavioral;

