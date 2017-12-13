----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:59:48 12/13/2017 
-- Design Name: 
-- Module Name:    SimulateLogicFixedPoint - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimulateLogicFixedPoint is
end SimulateLogicFixedPoint;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:39:14 12/13/2017 
-- Design Name: 
-- Module Name:    Simulate_Logic_FixedPoint - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library neuralnetwork;
use neuralnetwork.all;
use neuralnetwork.Common.all;

entity SimulateLogicFixedPoint is
end SimulateLogicFixedPoint;

architecture Behavioral of SimulateLogicFixedPoint is
	component Logic_FixedPoint is
		Port (
			fixed_point		:	out fixed_point_vector;
			std_logic_vec	: 	in uintw_t;
			clk			:	in std_logic
		);
	end component;
	
	signal clk		: std_logic := '0';
	signal fixed_point : fixed_point_vector;
	signal std_logic_vec : uintw_t;
	
	constant clock_period : time := 100ns;
	
	signal sim_busy : boolean := true;
begin

	clock_process : process
		begin
			if sim_busy then
				wait for clock_period;
				clk <= not clk;
			else
				wait;
			end if;
		end process;
		
lfp: Logic_FixedPoint port map
(
    fixed_point, std_logic_vec, clk
);

main: process
	begin
		wait for clock_period * 2;
		
		std_logic_vec <= to_unsigned(2, w); -- std_logic_vector(to_unsigned(2, w));
		
		wait for clock_period * 2;
		sim_busy <= false;
	end process;

end Behavioral;

architecture Behavioral of SimulateLogicFixedPoint is

begin


end Behavioral;

