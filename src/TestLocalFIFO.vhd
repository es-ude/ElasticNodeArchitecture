--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:19:02 08/13/2018
-- Design Name:   
-- Module Name:   /home/alwynster/git/fpgamiddlewareproject/src/TestLocalFIFO.vhd
-- Project Name:  fpgamiddlewareproject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: localFIFO
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
 
ENTITY TestLocalFIFO IS
END TestLocalFIFO;
 
ARCHITECTURE behavior OF TestLocalFIFO IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT localFIFO
		 generic ( 
			width				: integer;
			depth				: integer
		);
		PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         dataIn : IN  std_logic_vector(width-1 downto 0);
         dataInValid : IN  std_logic;
         dataOut : OUT  std_logic_vector(width-1 downto 0);
         dataOutRequest : IN  std_logic;
         empty : OUT  std_logic;
         full : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
	constant w : integer := 16;
	constant d : integer := 2;
   signal dataIn : std_logic_vector(w-1 downto 0) := (others => '0');
   signal dataInValid : std_logic := '0';
   signal dataOutRequest : std_logic := '0';

 	--Outputs
   signal dataOut : std_logic_vector(w-1 downto 0);
   signal empty : std_logic;
   signal full : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	signal finish : boolean := false;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: localFIFO GENERIC MAP (
			 width => w,
			 depth => d
		  )
		PORT MAP (
          clk => clk,
          reset => reset,
          dataIn => dataIn,
          dataInValid => dataInValid,
          dataOut => dataOut,
          dataOutRequest => dataOutRequest,
          empty => empty,
          full => full
        );

   -- Clock process definitions
   clk_process :process
   begin
		if finish then
			wait;
		else
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for clk_period*2;	
		reset <= '0';
		
      wait for clk_period*1;
		-- wait for clk_period/2;
		
		-- write 2 values
		dataInValid <= '1';
		dataIn <= x"ABCD";
		wait for clk_period;
		dataIn <= x"EF01";
		wait for clk_period;
		dataInValid <= '0';
		
		-- read one of them
		dataOutRequest <= '1';
		wait for clk_period;
		assert dataOut = x"ABCD" report "Value incorrect" severity error;
		dataOutRequest <= '0';
		wait for clk_period;
		
		-- write one in its place
		dataInValid <= '1';
		dataIn <= x"DDDD";
		wait for clk_period;
		dataInValid <= '0';
		
		-- read out both
		dataOutRequest <= '1';
		wait for clk_period;
		assert dataOut = x"EF01" report "Value incorrect" severity error;
		wait for clk_period;
		assert dataOut = x"DDDD" report "Value incorrect" severity error;
		dataOutRequest <= '0';
		wait for clk_period;
		
		wait for clk_period * 10;
      -- insert stimulus here 
	
		finish <= true;
		
      wait;
   end process;

END;
