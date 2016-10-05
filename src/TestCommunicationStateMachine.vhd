--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:09:24 10/04/2016
-- Design Name:   
-- Module Name:   /home/ES/burger/git/fpgamiddlewareproject/src/TestCommunicationStateMachine.vhd
-- Project Name:  fpgamiddlewareproject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CommunicationStateMachine
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
 
ENTITY TestCommunicationStateMachine IS
END TestCommunicationStateMachine;
 
ARCHITECTURE behavior OF TestCommunicationStateMachine IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CommunicationStateMachine
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         data_in_rdy : IN  std_logic;
         data_out : OUT  std_logic_vector(7 downto 0);
         data_out_rdy : OUT  std_logic;
			data_out_done: in std_logic;							-- data send complete
         spi_en : OUT  std_logic;
         uart_en : OUT  std_logic;
         icap_en : OUT  std_logic;
         multiboot : OUT  std_logic_vector(23 downto 0);
			fpga_sleep	: out std_logic := '0';					-- put configuration to sleep

         ready : OUT  std_logic;
			current_state : out std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal data_in_rdy : std_logic := '0';
   signal data_out : std_logic_vector(7 downto 0) := (others => '0');
   signal data_out_rdy : std_logic := '0';
	signal data_out_done : std_logic := '0';
   signal spi_en : std_logic := '0';
   signal uart_en : std_logic := '0';
   signal icap_en : std_logic := '0';
   signal multiboot : std_logic_vector(23 downto 0) := (others => '0');
	signal fpga_sleep : std_logic := '0';
   signal ready : std_logic := '0';
	signal current_state : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 31.25 ns; 
	constant uart_byte_time : time := clk_period*10; -- sped up for faster simulation
 
	signal busy : std_logic := '1';
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CommunicationStateMachine PORT MAP (
          clk => clk,
          reset => reset,
          data_in => data_in,
          data_in_rdy => data_in_rdy,
          data_out => data_out,
          data_out_rdy => data_out_rdy,
			 data_out_done => data_out_done,
          spi_en => spi_en,
          uart_en => uart_en,
          icap_en => icap_en,
          multiboot => multiboot,
			 fpga_sleep => fpga_sleep,
          ready => ready,
			 current_state => current_state
        );

   -- Clock process definitions
   clk_process :process
   begin
		if busy = '1' then
			
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
      wait for 100 ns;	
		reset <= '0';
	
		wait for clk_period*10;
		
		-- load new configuration address
      data_in <= x"06"; 			-- command
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		
		wait for uart_byte_time;
		data_in <= x"10";				-- first byte
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		
		wait for uart_byte_time;
		data_in <= x"00";				-- second byte
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		
		wait for uart_byte_time;
		data_in <= x"00";				-- third byte
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		wait for uart_byte_time;
      -- insert stimulus here 
		

		-- read from spi
		data_in <= x"01"; 			-- spi read command
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		wait for uart_byte_time;
		data_in <= x"12"; 			-- address 1
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		wait for uart_byte_time;
		data_in <= x"34"; 			-- address 2
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		wait for uart_byte_time;
		data_in <= x"56"; 			-- address 3
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		wait for uart_byte_time;
		data_in <= x"12"; 			-- size 1
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		wait for uart_byte_time;
		data_in <= x"34"; 			-- size 2
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		wait for uart_byte_time;
		data_in <= x"56"; 			-- size 3
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		
		-- simulate read from spi
		wait for clk_period * 8;
		data_out_done <= '1';
		wait for clk_period;
		data_out_done <= '0';
		wait for clk_period * 7;
		data_in <= x"21";
		data_in_rdy <= '1'; -- first
		wait for clk_period;
		data_in_rdy <= '0';
		wait for clk_period * 7;
		data_in <= x"54";
		data_in_rdy <= '1'; -- second
		wait for clk_period;
		data_in_rdy <= '0';
		wait for clk_period * 7;
		data_in <= x"65";
		data_in_rdy <= '1'; -- third
		wait for clk_period;
		data_in_rdy <= '0';
		wait for clk_period * 7;
		-- send response
		wait for uart_byte_time;
		data_out_done <= '1';
		wait for clk_period;
		data_out_done <= '0';
		
		-- sleep fpga
		wait for uart_byte_time;
		data_in <= x"08"; 			-- sleep command
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		
		wait for uart_byte_time * 2;

		-- wake fpga
		wait for uart_byte_time;
		data_in <= x"09"; 			-- wake command
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		
		wait for uart_byte_time * 2;
	
		busy <= '0';
		wait;

   end process;

END;
