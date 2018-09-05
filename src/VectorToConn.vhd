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
	
entity VectorToConn is
port
(
	vector	: in conn_vector;
	conn		: out fixed_point_vector := (others => zero)
);
end VectorToConn;

architecture Behavioral of VectorToConn is
begin
	process (vector) is
		variable fp : fixed_point;
		variable index : integer range 0 to vector'length;
	begin
		-- if undefined, revert to default:
		if vector(0) = 'U' then
			conn <= (others => zero);
		else
			-- first dim (each neuron)
			for j in 0 to maxWidth-1 loop
				index := j * (b);
				conn(j) <= signed(vector(index+b-1 downto index));
			end loop;
		end if;
	end process;
end Behavioral;

