--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:27:48 05/21/2017
-- Design Name:   
-- Module Name:   C:/Users/alwynster/git/fpgamiddlewareproject/src/TestKeyboard.vhd
-- Project Name:  fpgamiddlewareproject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: keyboard
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

ENTITY TestKeyboard IS
END TestKeyboard;
 
ARCHITECTURE behavior OF TestKeyboard IS 

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal values : kb_rgb_value; -- := (others => (others => '0'));

 	--Outputs
   signal leds : kb_rgb_led;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
	signal busy : boolean := true;
	
BEGIN
		  
	values(0)(0) <= to_unsigned(	0		, 8);
	values(0)(1) <= to_unsigned(	127	, 8);
	values(0)(2) <= to_unsigned(	255 	, 8); 
	
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.keyboard (Behavioral) PORT MAP (
          clk,
          reset,
          values,
          leds
        );



   -- Clock process definitions
   clk_process :process
   begin
		if busy then
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		else
			wait;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for clk_period;
		reset <= '0';

      wait for clk_period*10;

      -- insert stimulus here 
		
		busy <= false;
      wait;
   end process;

END;
