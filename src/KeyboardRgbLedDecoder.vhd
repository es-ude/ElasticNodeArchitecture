----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:43:58 05/25/2017 
-- Design Name: 
-- Module Name:    KeyboardRgbLedDecoder - Behavioral 
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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

entity KeyboardRgbLedDecoder is
port
(
	leds_vector		: out std_logic_vector(3*fpgamiddlewarelibs.userlogicinterface.num_keys-1 downto 0);
	leds_rgb			: in kb_rgb_led
);
end KeyboardRgbLedDecoder;

architecture Behavioral of KeyboardRgbLedDecoder is

begin
gen_loop:
		for i in 0 to fpgamiddlewarelibs.userlogicinterface.num_keys-1 generate
			leds_vector(i*3 + 0) <= leds_rgb(i)(0);
			leds_vector(i*3 + 1) <= leds_rgb(i)(1);
			leds_vector(i*3 + 2) <= leds_rgb(i)(2);
		end generate;

end Behavioral;

