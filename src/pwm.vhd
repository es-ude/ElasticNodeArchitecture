----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:33:39 05/21/2017 
-- Design Name: 
-- Module Name:    pwm - Behavioral 
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
use fpgamiddlewarelibs.userlogicinterface.all;

entity pwm is
port
(
	clk		: in std_logic;
	reset 	: in std_logic;
	
	compare	: in uint8_t;
	output	: out std_logic := '0'
);
end pwm;

architecture Behavioral of pwm is
begin
	-- main process
	process (clk, reset) is
		variable counter : integer range 0 to fpgamiddlewarelibs.userlogicinterface.top;
	begin
		if reset = '1' then
			output <= '0';
			counter := 0;
		else
			if rising_edge(clk) then
				-- check if it's time to toggle
				if counter = top then
					counter := 0;
				elsif counter < compare then
					output <= '1';
					counter := counter + 1;
				else
					-- increment
					counter := counter + 1;
					if counter >= compare then
						output <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;


end Behavioral;

