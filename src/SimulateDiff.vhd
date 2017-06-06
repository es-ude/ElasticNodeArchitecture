----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:58:52 07/27/2015 
-- Design Name: 
-- Module Name:    SimulateDiff - Behavioral 
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
library DesignLab;
use DesignLab.Common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimulateDiff is
end SimulateDiff;

architecture Behavioral of SimulateDiff is
	component Diff is port
	(
		current		:	in probability_vector;
		wanted		:	in probability_vector;
		difference 	:	out probability_vector
	);
	end component;
	signal current, wanted, difference : probability_vector;

begin
	uut : Diff port map (current, wanted, difference);
	process
	begin
		current <= (0.0, 0.0, 1.0);
		wanted <= (0.5, 1.0, 0.0);
		wait;
	end process;	
end Behavioral;

