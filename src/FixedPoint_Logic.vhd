----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2015 03:22:37 PM
-- Design Name: 
-- Module Name: FixedPoint_Logic - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use neuralnetwork.Common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FixedPoint_Logic is
	Port (
		fixed_point		:	in fixed_point_vector;
		std_logic_vec	: 	out uintw_t;
		clk				:	in std_logic
	);
end FixedPoint_Logic;

architecture Behavioral of FixedPoint_Logic is

begin
	process(clk, fixed_point)
	begin
		if rising_edge(clk) then
			for i in 0 to w-1 loop
				std_logic_vec(i) <= round(fixed_point(i));
			end loop;
		end if;
	end process;

end Behavioral;
