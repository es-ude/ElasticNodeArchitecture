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

entity ConnToVector is
port (
	conn	 : in fixed_point_vector;
	vector : out conn_vector
);
end ConnToVector;

architecture Behavioral of ConnToVector is

begin
	process (conn) is
		variable fp : fixed_point;
	begin
		-- first dim (each outside neuron)
		for j in 0 to w-1 loop
			fp := conn(j);
			-- vector
			for k in 0 to b-1 loop
				 vector(k + j * (b)) <= fp(k);
			end loop;
		end loop;
	end process;
end Behavioral;

