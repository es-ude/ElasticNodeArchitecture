----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:32:45 07/08/2015 
-- Design Name: 
-- Module Name:    SimulateSumMux - Behavioral 
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

library work;
use work.Common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimulateSumMux is
end SimulateSumMux;

architecture Behavioral of SimulateSumMux is

	constant period: time := 100 ns;
	--signal clk: std_logic := '0';

	component sumMux is
	-- size is number of elements in vector, not matrix
	port (
		--clk			:	in std_logic;

		errors 		:	in fixed_point_matrix;
		errors_out	: 	out fixed_point_vector
		);
	end component;

	--signal errors : weights_matrix;
	 --:= ((0.0, 0.1, 0.2), (0.0, 0.0, 0.0));
	signal errors_in : fixed_point_matrix := (others => (others => real_to_fixed_point(0.0)));
	signal errors_out : fixed_point_vector;
	signal d : boolean;
	signal comp : fixed_point_vector;
begin

	--clk <= not clk after period/2;

	uut: sumMux port map(
		errors => errors_in, errors_out => errors_out
		);

	process begin
		wait for period;
		errors_in(0) <= (real_to_fixed_point(0.0), real_to_fixed_point(0.1), real_to_fixed_point(0.2));
		errors_in(1) <= (real_to_fixed_point(0.0), real_to_fixed_point(0.0), real_to_fixed_point(0.0));
		errors_in(2) <= (real_to_fixed_point(0.0), real_to_fixed_point(0.0), real_to_fixed_point(0.0));
		--comp <= (0.0, 0.1, 0.2);
		
		wait for period;

		--assert (errors_out = comp);
		--errors_in(1) <= (0.0, 0.1, 0.2);
		wait for period;

		--comp <= (0.0, 0.2, 0.4);
		--assert (errors_out = comp);
		
		report "Finished" severity error;
		wait;
	end process;


end Behavioral;

