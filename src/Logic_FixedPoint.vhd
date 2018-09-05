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

entity Logic_FixedPoint is
	Port (
		fixed_point		:	out fixed_point_vector := (others => zero);
		std_logic_vec	: 	in uintw_t;
		clk				:	in std_logic
	);
end Logic_FixedPoint;

architecture Behavioral of Logic_FixedPoint is

begin
	process(clk, std_logic_vec)
	begin
		--if rising_edge(clk) then
			for i in 0 to maxWidth-1 loop
				fixed_point(i) <= logic_to_fixed_point(std_logic_vec(i));
			end loop;
		--end if;
	end process;

end Behavioral;
