--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:28:39 05/15/2017
-- Design Name:   
-- Module Name:   /home/ES/burger/git/fpgamiddlewareproject/src/TestInterfaceStateMachine.vhd
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;
 
ENTITY TestInterfaceStateMachine IS
END TestInterfaceStateMachine;

 
ARCHITECTURE behavior OF TestInterfaceStateMachine IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT InterfaceStateMachine
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         icap_address : OUT  uint24_t_interface;
         uart_tx : OUT  uint8_t_interface;
         uart_tx_done : IN  std_logic;
         uart_rx : IN  uint8_t_interface;
         sram_address : IN  uint16_t;
         sram_data_out : OUT  uint8_t;
         sram_data_in : IN  uint8_t;
         sram_rd : IN  std_logic;
         sram_wr : IN  std_logic;
			userlogic_sleep : out std_logic;
         userlogic_done : IN  std_logic;
         userlogic_data_in : OUT  uint8_t;
         userlogic_address : OUT  uint16_t;
         userlogic_data_out : IN  uint8_t;
			userlogic_rd		: out std_logic;
			userlogic_wr		: out std_logic;
			leds : out std_logic_vector (3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal uart_tx_done : std_logic := '0';
   signal uart_rx : uint8_t_interface;
   signal sram_address : uint16_t := (others => '0');
   signal sram_data_in : uint8_t := (others => '0');
   signal sram_rd : std_logic := '0';
   signal sram_wr : std_logic := '0';
   signal userlogic_done : std_logic := '0';
   signal userlogic_data_out : uint8_t := (others => '0');

 	--Outputs
   signal icap_address : uint24_t_interface;
   signal uart_tx : uint8_t_interface;
   signal sram_data_out : uint8_t;
   signal userlogic_sleep : std_logic := '0';
   signal userlogic_data_in : uint8_t;
   signal userlogic_address : uint16_t;
	signal userlogic_rd, userlogic_wr : std_logic;
	signal leds : std_logic_vector(3 downto 0);
	
   -- Clock period definitions
   constant clock_period : time := 10 ns;
	signal busy : boolean := true;
	
	-- procedures
	procedure write_uint8_t(constant data : in uint8_t; constant address : in uint16_t; signal address_out : out uint16_t; signal data_out : out uint8_t; signal wr : out std_logic) is
	begin
		address_out <= address;
		data_out <= data;
		wr <= '1';
		wait for clock_period;
		wr <= '0';
		wait for clock_period;
	end procedure;

	procedure write_uint24_t(constant data : in uint24_t; constant address : in uint16_t; signal address_out : out uint16_t; signal data_out : out uint8_t; signal wr : out std_logic) is
	begin
		write_uint8_t(data(7 downto 0), address, address_out, data_out, wr);
		write_uint8_t(data(15 downto 8), address + 1, address_out, data_out, wr);
		write_uint8_t(data(23 downto 16), address + 2, address_out, data_out, wr);
	end procedure;

	procedure write_uint32_t(constant data : in uint32_t; constant address : in uint16_t; signal address_out : out uint16_t; signal data_out : out uint8_t; signal wr : out std_logic) is
	begin
		write_uint8_t(data(7 downto 0), address, address_out, data_out, wr);
		write_uint24_t(data(31 downto 8), address + 1, address_out, data_out, wr);
	end procedure;


BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: InterfaceStateMachine PORT MAP (
          clk => clk,
          reset => reset,
          icap_address => icap_address,
          uart_tx => uart_tx,
          uart_tx_done => uart_tx_done,
          uart_rx => uart_rx,
          sram_address => sram_address,
          sram_data_out => sram_data_out,
          sram_data_in => sram_data_in,
          sram_rd => sram_rd,
          sram_wr => sram_wr,
			 userlogic_sleep => userlogic_sleep,
          userlogic_done => userlogic_done,
          userlogic_data_in => userlogic_data_in,
          userlogic_address => userlogic_address,
          userlogic_data_out => userlogic_data_out,
			 userlogic_rd => userlogic_rd,
			 userlogic_wr => userlogic_wr,
			 leds => leds
        );

   -- Clock process definitions
   clk_process :process
   begin
		if busy then
			clk <= '0';
			wait for clock_period/2;
			clk <= '1';
			wait for clock_period/2;
		else 
			wait;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for clock_period * 4;
		reset <= '0';
		
		--icap
		write_uint24_t(x"060000", x"0000", sram_address, sram_data_in, sram_wr);
		wait for clock_period * 4;

		--leds
		write_uint8_t(x"06", x"0003", sram_address, sram_data_in, sram_wr);
		wait for clock_period * 4;

		--sleep
		write_uint8_t(x"01", x"0004", sram_address, sram_data_in, sram_wr);
		wait for clock_period * 4;
		--wake
		write_uint8_t(x"00", x"0004", sram_address, sram_data_in, sram_wr);
		wait for clock_period * 4;

		write_uint8_t(x"07", x"0001", sram_address, sram_data_in, sram_wr);
		wait for clock_period * 4;

		--ul
		write_uint32_t(x"12345678", x"0100", sram_address, sram_data_in, sram_wr);
		
      -- insert stimulus here 
		wait for clock_period * 10;
		busy <= false;
      wait;
   end process;

END;
