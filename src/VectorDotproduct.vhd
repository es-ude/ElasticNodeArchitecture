----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:00:45 12/20/2016 
-- Design Name: 
-- Module Name:    vector_dotproduct - Behavioral 
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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;



entity VectorDotproduct is
	port (
		-- control interface
		clock				: in std_logic;
		reset 			: in std_logic;
		calculate		: in std_logic; -- perform a single calculation on the current data
		
		-- data in
		vectorA			: in unsigned(31 downto 0);
		vectorB			: in unsigned(31 downto 0);
		
		-- data out 
		result			: out unsigned(31 downto 0)
		);
end VectorDotproduct;

architecture Behavioral of VectorDotproduct is
	-- signal inputA, inputB : unsigned(31 downto 0);
	signal intermediate_result : unsigned(31 downto 0);
	
begin

	-- process data receive 
	process (clock, reset)
		-- variable intermediate_result : unsigned(31 downto 0);
	begin
		if reset = '1' then
			intermediate_result <= to_unsigned(0, 32);
		elsif rising_edge(clock) then
		-- perform one dimension's calculations per cycle
			if calculate = '1' then
				intermediate_result <= intermediate_result + vectorA(15 downto 0) * vectorB(15 downto 0);
			else 
				intermediate_result <= intermediate_result;
			end if;
		end if;
	end process;
		
	result <= intermediate_result;
end Behavioral;

