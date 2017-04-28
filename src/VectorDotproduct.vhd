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
		run				: in std_logic; -- controls functionality (sleep)
		enable 			: in std_logic;
		--ready 			: out std_logic; -- new transmission may begin
		--done 				: out std_logic; -- done with entire calculation
		
		-- data in
		vectorA			: in unsigned(31 downto 0);
		vectorB			: in unsigned(31 downto 0);
		
		-- data out 
		result			: out unsigned(31 downto 0)
		);
end VectorDotproduct;

architecture Behavioral of VectorDotproduct is
	-- signal inputA, inputB : unsigned(31 downto 0);
	type state is (idle, receive);
	signal current_state : state := idle;
	signal intermediate_result : unsigned(31 downto 0);
	
begin

	-- process data receive 
	process (clock, enable, current_state)
		-- variable intermediate_result : unsigned(31 downto 0);
	begin
		if enable = '0' then
			current_state <= idle;
			intermediate_result <= to_unsigned(0, 32);
		elsif rising_edge(clock) then
			if run = '1' then
				current_state <= receive;
				intermediate_result <= intermediate_result + vectorA(15 downto 0) * vectorB(15 downto 0);
			else
				current_state <= idle;
			end if;
		end if;
	end process;
		
	result <= intermediate_result;
end Behavioral;

