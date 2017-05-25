----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:19:48 05/21/2017 
-- Design Name: 
-- Module Name:    key - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

library work;
use work.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity key is
port
(
	clk			: in std_logic;
	reset 		: in std_logic;
	
	value			: in rgb_value;
	
	leds			: out rgb_led
);
end key;

architecture Behavioral of key is

begin

-- init pwms
gen_loop:
	for i in 0 to 2 generate
		pwmx:
			entity pwm(Behavioral) port map ( clk, reset, value(i), leds(i) );
	end generate; 
	
end Behavioral;

