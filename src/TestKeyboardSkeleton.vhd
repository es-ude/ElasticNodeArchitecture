--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:40:36 05/25/2017
-- Design Name:   
-- Module Name:   C:/Users/alwynster/git/fpgamiddlewareproject/src/TestKeyboardSkeleton.vhd
-- Project Name:  fpgamiddlewareproject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: KeyboardSkeleton
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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;
use fpgamiddlewarelibs.procedures.all;
 
ENTITY TestKeyboardSkeleton IS
END TestKeyboardSkeleton;
 
ARCHITECTURE behavior OF TestKeyboardSkeleton IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT KeyboardSkeleton
	 generic(
			PRESCALER	: integer
	 );
    PORT(
         clock : IN  std_logic;
         reset : IN  std_logic;
         done : OUT  std_logic;
         rd : IN  std_logic;
         wr : IN  std_logic;
         data_in : IN  uint8_t;
         address_in : IN  uint16_t;
         data_out : OUT  uint8_t;
         leds : OUT  std_logic_vector(fpgamiddlewarelibs.userlogicinterface.num_keys*3-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal rd : std_logic := '1';
   signal wr : std_logic := '1';
   signal data_in : uint8_t := (others => '0');
   signal address_in : uint16_t := (others => '0');

 	--Outputs
   signal done : std_logic;
   signal data_out : uint8_t;
   signal leds : std_logic_vector(fpgamiddlewarelibs.userlogicinterface.num_keys*3-1 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
	signal busy : boolean := true;
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: KeyboardSkeleton generic map (1) PORT MAP (
          clock => clock,
          reset => reset,
          done => done,
          rd => rd,
          wr => wr,
          data_in => data_in,
          address_in => address_in,
          data_out => data_out,
          leds => leds
        );

   -- Clock process definitions
   clock_process :process
   begin
		if busy then
			clock <= '0';
			wait for clock_period/2;
			clock <= '1';
			wait for clock_period/2;
		else
			wait;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		reset <= '1';
      -- hold reset state for 100 ns.
      wait for clock_period*2;
		reset <= '0';
		
      write_uint24_t(x"0025FF", x"0000", address_in, data_in, wr);
		
		wait for clock_period*780;
		busy <= false;
		wait for clock_period*2;
      wait;
   end process;

END;
