----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:53:49 05/21/2017 
-- Design Name: 
-- Module Name:    keyboard - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

entity keyboard is
generic
(
	PRESCALER	: integer
);
port
(
	clk			: in std_logic;
	reset 		: in std_logic;

	rgb_values	: in kb_rgb_value;
	leds			: out kb_rgb_led
);
end keyboard;

architecture Behavioral of keyboard is
	signal prescale_clk : std_logic := '0';
begin

-- prescaler for pwm
pre:
	process (clk) is
		variable counter : integer range 0 to PRESCALER := 0;
	begin
		if rising_edge(clk) then
			counter := counter + 1;
			if counter >= PRESCALER then
				prescale_clk <= not prescale_clk;
			end if;
		elsif falling_edge(clk) then
			counter := counter + 1;
			if counter >= PRESCALER then
				prescale_clk <= not prescale_clk;
			end if;
		end if;
	end process;

-- generate all the keys
key_loop:	
	for i in 0 to num_keys-1 generate
		key_loopx: entity work.key (Behavioral) port map
		(
			prescale_clk, reset, rgb_values(i), leds(i)
		);
	end generate;

end Behavioral;

