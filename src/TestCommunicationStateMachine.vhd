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
library fpgamiddlewarelibs;
use fpgamiddlewarelibs.all;

 
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
			spi_continue : out std_logic;
			spi_busy : in std_logic;

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
	signal spi_en_strobe : std_logic;
   signal uart_en : std_logic := '0';
   signal icap_en : std_logic := '0';
   signal multiboot : std_logic_vector(23 downto 0) := (others => '0');
	signal fpga_sleep : std_logic := '0';
   signal ready : std_logic := '0';
	signal current_state : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 31.25 ns; 
	constant uart_byte_time : time := clk_period*10; -- sped up for faster simulation
 
	-- spi variables
	signal spi_busy			: std_logic;
	signal spi_data_in		: std_logic_vector(7 downto 0);
	signal spi_data_in_rdy	: std_logic := '0'; -- stretched strobe to send a byte 
	signal spi_data_out 		: std_logic_vector(7 downto 0);
	signal spi_data_out_rdy : std_logic := '0';
	signal spi_data_in_done	: std_logic;
	
	signal spi_continue		: std_logic := '0';
	
	signal spi_cs				: std_logic;
	signal spi_clk				: std_logic;
	signal spi_mosi			: std_logic;
	signal spi_miso			: std_logic := '1';
	
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
			 spi_continue => spi_continue,
			 spi_busy => spi_busy,
          uart_en => uart_en,
          icap_en => icap_en,
          multiboot => multiboot,
			 fpga_sleep => fpga_sleep,
          ready => ready,
			 current_state => current_state
        );

	--! SPI communication interface
	spi: entity fpgamiddlewarelibs.spiInterface(arch)
		generic map(
			prescaler => 2
		)
		port map(
			enable => spi_en,
			clk => clk,
			continue => spi_continue,

			busy => spi_busy,
			data_in => data_out, -- data to be sent 
			data_out => spi_data_out, -- data received
			data_i_rdy => spi_data_in_rdy,
			data_i_req => spi_data_in_done,
			data_o_rdy => spi_data_out_rdy,
			
			--! SPI physical interfaces 
			spi_cs => spi_cs,
			spi_clk => spi_clk,
			spi_mosi => spi_mosi,
			spi_miso => spi_miso
		);
		
	spi_data_in <= data_out;
	spi_data_in_rdy <= data_out_rdy;

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
 

   -- MISO process definitions
   miso_process :process
   begin
		if busy = '1' then
			
			spi_miso <= '0';
			wait for clk_period*3/2;
			spi_miso <= '1';
			wait for clk_period*3/2;
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
		
--		-- load new configuration address
--      data_in <= x"06"; 			-- command
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		
--		wait for uart_byte_time;
--		data_in <= x"10";				-- first byte
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		
--		wait for uart_byte_time;
--		data_in <= x"00";				-- second byte
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		
--		wait for uart_byte_time;
--		data_in <= x"00";				-- third byte
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for uart_byte_time;
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
		
--		-- simulate read from spi
--		wait for clk_period * 8;
--		data_out_done <= '1';
--		wait for clk_period;
--		data_out_done <= '0';
--		wait for clk_period * 7;
--		data_in <= x"21";
--		data_in_rdy <= '1'; -- first
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for clk_period * 7;
--		data_in <= x"54";
--		data_in_rdy <= '1'; -- second
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for clk_period * 7;
--		data_in <= x"65";
--		data_in_rdy <= '1'; -- third
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for clk_period * 7;
--		-- send response
--		wait for uart_byte_time;
--		data_out_done <= '1';
--		wait for clk_period;
--		data_out_done <= '0';
		
		-- wait for reading from spi 
		wait for clk_period * 24;
		
--		-- sleep fpga
--		wait for uart_byte_time;
--		data_in <= x"08"; 			-- sleep command
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		
--		wait for uart_byte_time * 2;
--
--		-- wake fpga
--		wait for uart_byte_time;
--		data_in <= x"09"; 			-- wake command
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
		
		wait for uart_byte_time * 20;
	
		busy <= '0';
		wait;

   end process;

END;
