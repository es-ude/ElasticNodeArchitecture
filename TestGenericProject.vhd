--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:39:40 05/24/2017
-- Design Name:   
-- Module Name:   /home/ES/burger/git/fpgamiddlewareproject/TestGenericProject.vhd
-- Project Name:  fpgamiddlewareproject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: genericProject
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
 
ENTITY TestGenericProject IS
END TestGenericProject;
 
ARCHITECTURE behavior OF TestGenericProject IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT genericProject
    PORT(
         userlogic_done : OUT  std_logic;
         leds : OUT  std_logic_vector(3 downto 0);
         clk : IN  std_logic;
         rx : IN  std_logic;
         tx : OUT  std_logic;
         mcu_ad : INOUT  std_logic_vector(7 downto 0);
         mcu_ale : IN  std_logic;
         mcu_a : IN  std_logic_vector(15 downto 8);
         mcu_rd : IN  std_logic;
         mcu_wr : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rx : std_logic := '0';
   signal mcu_ale : std_logic := '0';
   signal mcu_a : std_logic_vector(15 downto 8) := (others => '0');
   signal mcu_rd : std_logic := '1';
   signal mcu_wr : std_logic := '1';

	--BiDirs
   signal mcu_ad : std_logic_vector(7 downto 0);
	signal mcu_ad_s : std_logic_vector(7 downto 0);

 	--Outputs
   signal userlogic_done : std_logic;
   signal leds : std_logic_vector(3 downto 0);
   signal tx : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
	constant mcu_clk : time := 125 ns;

	signal busy : boolean := true;

procedure write_uint8_t(constant data : std_logic_vector(7 downto 0); constant address : uint16_t; signal mcu_ad : out std_logic_vector(7 downto 0); signal mcu_a : out std_logic_vector(15 downto 8); signal mcu_ale : out std_logic; signal mcu_wr : out std_logic) is
	variable address_std : std_logic_vector(15 downto 0);
begin
	address_std := std_logic_vector(address);

	wait for mcu_clk / 2;
	mcu_ale <= '1';
	wait for mcu_clk / 2;
	mcu_a <= address_std(15 downto 8);
	mcu_ad <= address_std(7 downto 0);
	wait for mcu_clk / 2;
	mcu_ale <= '0';
	wait for mcu_clk / 2;
	mcu_wr <= '0';
	mcu_ad <= data;
	wait for mcu_clk;
	mcu_wr <= '1';
end procedure;

procedure write_uint32_t(constant data : uint32_t; constant address : uint16_t; signal mcu_ad : out std_logic_vector(7 downto 0); signal mcu_a : out std_logic_vector(15 downto 8); signal mcu_ale : out std_logic; signal mcu_wr : out std_logic) is
	variable data_std : std_logic_vector(31 downto 0);
begin
	data_std := std_logic_vector(data);
	write_uint8_t(data_std(7 downto 0), address, mcu_ad, mcu_a, mcu_ale, mcu_wr);
	write_uint8_t(data_std(15 downto 8), address + 1, mcu_ad, mcu_a, mcu_ale, mcu_wr);
	write_uint8_t(data_std(23 downto 16), address + 2, mcu_ad, mcu_a, mcu_ale, mcu_wr);
	write_uint8_t(data_std(31 downto 24), address + 3, mcu_ad, mcu_a, mcu_ale, mcu_wr);
end procedure;

procedure read_uint8_t(constant address : uint16_t; signal mcu_ad : out std_logic_vector(7 downto 0); signal mcu_a : out std_logic_vector(15 downto 8); signal mcu_ale : out std_logic; signal mcu_rd : out std_logic) is
	variable address_std : std_logic_vector(15 downto 0);
begin
	address_std := std_logic_vector(address);

	wait for mcu_clk / 2;
	mcu_ale <= '1';
	wait for mcu_clk / 2;
	mcu_a <= address_std(15 downto 8);
	mcu_ad <= address_std(7 downto 0);
	wait for mcu_clk / 2;
	mcu_ale <= '0';
	wait for mcu_clk / 2;
	mcu_rd <= '0';
	wait for mcu_clk;
	mcu_rd <= '1';
end procedure;


procedure read_uint32_t(constant address : uint16_t; signal mcu_ad : out std_logic_vector(7 downto 0); signal mcu_a : out std_logic_vector(15 downto 8); signal mcu_ale : out std_logic; signal mcu_rd : out std_logic) is
begin
	read_uint8_t(address + 0, mcu_ad, mcu_a, mcu_ale, mcu_rd);
	read_uint8_t(address + 1, mcu_ad, mcu_a, mcu_ale, mcu_rd);
	read_uint8_t(address + 2, mcu_ad, mcu_a, mcu_ale, mcu_rd);
	read_uint8_t(address + 3, mcu_ad, mcu_a, mcu_ale, mcu_rd);
end procedure;
 
BEGIN
	mcu_ad <= mcu_ad_s when mcu_rd = '1' else (others => 'Z');
	
	-- Instantiate the Unit Under Test (UUT)
   uut: genericProject PORT MAP (
          userlogic_done => userlogic_done,
          leds => leds,
          clk => clk,
          rx => rx,
          tx => tx,
          mcu_ad => mcu_ad,
          mcu_ale => mcu_ale,
          mcu_a => mcu_a,
          mcu_rd => mcu_rd,
          mcu_wr => mcu_wr
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
      -- reset <= '1';
		wait for clk_period;
		-- reset <= '0';

      -- insert stimulus here 
		write_uint8_t(x"02", x"2203", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --leds
		
		wait for clk_period * 2;
		--ulk
		write_uint32_t(x"01000000", x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
		write_uint32_t(x"02000000", x"2304", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
		write_uint32_t(x"02000000", x"2308", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
		
		wait for clk_period * 4;
		read_uint32_t(x"230C", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
		
		wait for clk_period * 4;
		
		busy <= false;
      wait;
   end process;

END;
