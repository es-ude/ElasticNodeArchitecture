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

port
(
	clk			: in std_logic;
	reset 		: in std_logic;
	
	leds			: out kb_rgb_led
);
end keyboard;

architecture Behavioral of keyboard is

	signal rgb_values	: kb_rgb_value;
	
begin

process (clk, reset) is
	variable counter : uint8_t := (others => '0');
begin
	if reset = '1' then
	else
		if rising_edge(clk) then
			for j in 0 to num_keys-1 loop
				rgb_values(j)(0) <= counter;
				rgb_values(j)(1) <= counter;
				rgb_values(j)(2) <= counter;
			end loop;
			counter := counter + 1;
		end if;
	end if;
end process;
	
key_loop:	
	for i in 0 to num_keys-1 generate
		key_loopx: entity work.key (Behavioral) port map
		(
			clk, reset, rgb_values(i), leds(i)
		);
	end generate;

end Behavioral;

