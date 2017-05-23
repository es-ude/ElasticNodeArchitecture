--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:28:24 05/21/2017
-- Design Name:   
-- Module Name:   C:/Users/alwynster/git/fpgamiddlewareproject/src/TestKey.vhd
-- Project Name:  fpgamiddlewareproject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: key
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
--USE ieee.numeric_std.ALL;
 
library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;
 
ENTITY TestKey IS
END TestKey;
 
ARCHITECTURE behavior OF TestKey IS 

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal red : uint8_t := x"00";
   signal green : uint8_t := x"10";
   signal blue : uint8_t := x"fE";

 	--Outputs
   signal red_led : std_logic;
   signal green_led : std_logic;
   signal blue_led : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	signal busy : boolean := true;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.key (Behavioral) PORT MAP (
          clk => clk,
          reset => reset,
          value(0) => red,
          value(1) => green,
          value(2) => blue,
          leds(0) => red_led,
          leds(1) => green_led,
          leds(2) => blue_led
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
		
      wait for clk_period*510;

      -- insert stimulus here 
		busy <= false;
      wait;
   end process;

END;
