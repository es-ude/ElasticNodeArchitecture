----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:09:09 06/20/2017 
-- Design Name: 
-- Module Name:    VectorToWeights - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
	
entity VectorToWeights is
port
(
	vector	: in weights_vector;
	weights	: out fixed_point_matrix := (others => (others => init_weight))
);
end VectorToWeights;

architecture Behavioral of VectorToWeights is
	-- signal weights : fixed_point_matrix := (others => (others => init_weight));
begin
	process (vector) is
		variable fpv : fixed_point_vector;
		variable fp : fixed_point;
		variable index : integer range 0 to vector'length;
	begin
		-- if undefined, revert to default:
		if vector(0) = 'U' then
			weights <= (others => (others => init_weight));
		else
			-- first dim (each outside neuron)
			for i in 0 to w-1 loop
				-- fpv := matrix(i);
				-- second dim (each neuron)
				for j in 0 to w-1 loop
					-- fp := fpv(j);
					-- vector
					-- for k in 0 to b-1 loop
					index := j * (b) + i * (b*w);
					weights(i)(j) <= signed(vector(index+b-1 downto index));
						-- vector(k + j * (b) + i * (b*w)) <= fp(k);
					-- end loop;
				end loop;
			end loop;
		end if;
	end process;
end Behavioral;

