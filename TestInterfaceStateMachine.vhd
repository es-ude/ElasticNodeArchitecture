--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:36:51 05/11/2017
-- Design Name:   
-- Module Name:   /home/ES/burger/git/fpgamiddlewareproject/TestInterfaceStateMachine.vhd
-- Project Name:  fpgamiddlewareproject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: InterfaceStateMachine
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
USE ieee.numeric_std.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

ENTITY TestInterfaceStateMachine IS
END TestInterfaceStateMachine;
 
ARCHITECTURE behavior OF TestInterfaceStateMachine IS 
 
   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal data_in_8 : uint8_t_interface;
   signal data_out_8_done : std_logic := '0';
   signal data_in_32 : uint32_t_interface;
   signal userlogic_rdy : std_logic := '0';
   signal userlogic_done : std_logic := '0';

 	--Outputs
   signal data_out_8 : uint8_t_interface;
   signal data_in_32_done : std_logic;
   signal data_out_32 : uint32_t_interface;
   signal uart_en : std_logic;
   signal icap_en : std_logic;
   signal multiboot : uint24_t;
   signal fpga_sleep : std_logic;
   signal userlogic_en : std_logic;
   signal ready : std_logic;
   signal receive_state_out : std_logic_vector(3 downto 0);
   signal send_state_out : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	signal busy : boolean := True;
	
	--Ram interface
	signal ad : std_logic_vector(7 downto 0);
	signal a : std_logic_vector(15 downto 8);
	signal ale : std_logic := '0';
	signal rd_i, wr_i : std_logic := '1';
		
	-- higher level ports
	signal address : std_logic_vector(15 downto 0);
	signal data_in, data_out : std_logic_vector(7 downto 0);
	signal rd, wr : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.InterfaceStateMachine(Behavior) PORT MAP (
		 clk => clk,
		 reset => reset,
		 data_in_8 => data_in_8,
		 data_out_8 => data_out_8,
		 data_out_8_done => data_out_8_done,
		 data_in_32 => data_in_32,
		 data_in_32_done => data_in_32_done,
		 data_out_32 => data_out_32,
		 uart_en => uart_en,
		 icap_en => icap_en,
		 multiboot => multiboot,
		 fpga_sleep => fpga_sleep,
		 userlogic_en => userlogic_en,
		 userlogic_rdy => userlogic_rdy,
		 userlogic_done => userlogic_done,
		 ready => ready,
		 receive_state_out => receive_state_out,
		 send_state_out => send_state_out
	);

	-- initialise ram interface
	sram: entity work.sramSlave(Behavioral) 
	generic map
	(
		OFFSET => x"0000"
	)
	port map 
	(
		clk => clk,
		
		ARD_RESET => open,
		
		mcu_ad => ad,
		mcu_ale => ale,
		mcu_a => a,
		mcu_rd => rd_i,
		mcu_wr => wr_i,
		
		-- higher level ports
		address => address,
		data_out => data_out,
		data_in => data_in,
		rd => rd,
		wr => wr,
		
		leds => open
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

		wait for clk_period*2;
		
		ad <= x"12"; -- address low
		a <= x"34";  -- address high
		wait for clk_period*2;
		ale <= '1';
		wait for clk_period*2;
		ale <= '0';
		wait for clk_period;
		ad <= x"78"; -- data
		wait for clk_period;
		wr_i <= '0';
		wait for clk_period*2;
		wr_i <= '1';
		wait for clk_period;
		

      wait for clk_period*10;

      -- insert stimulus here 
		
		busy <= False;
		
      wait;
   end process;

END;
