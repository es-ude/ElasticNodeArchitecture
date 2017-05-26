--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:43:09 05/15/2017
-- Design Name:   
-- Module Name:   /home/ES/burger/git/fpgamiddlewareproject/src/TestMiddleware.vhd
-- Project Name:  fpgamiddlewareproject
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: middleware
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

ENTITY TestMiddleware IS
END TestMiddleware;
 
ARCHITECTURE behavior OF TestMiddleware IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT middleware
    PORT(
			reset  			: in std_logic;
			clk 				: in std_ulogic;	--! Clock 32 MHz

			-- userlogic
			userlogic_reset: out std_logic;
			userlogic_done	: in std_logic;
			userlogic_data_in: out uint8_t;
			userlogic_data_out: in uint8_t;
			userlogic_address	: out uint16_t;
			userlogic_rd	: out std_logic;
			userlogic_wr	: out std_logic;
			
			-- debug
			interface_leds	: out std_logic_vector(3 downto 0);
			
			-- uart
			rx					: in std_logic;
			tx 				: out std_logic;
			
			-- sram
			sram_address 	: in uint16_t;
			sram_data_out	: out uint8_t; -- for reading from ext ram
			sram_data_in 	: in uint8_t; 	-- for writing to ext ram
			sram_rd			: in std_logic;
			sram_wr			: in std_logic
        );
    END COMPONENT;
    

   --Inputs
	signal reset : std_logic;
   signal userlogic_done : std_logic := '0';
   signal data_in_32 : uint32_t_interface;
   signal clk : std_logic := '0';
   signal rx : std_logic := '0';
   signal sram_address : uint16_t := (others => '0');
   signal sram_data_in : uint8_t := (others => '0');
   signal sram_rd : std_logic := '0';
   signal sram_wr : std_logic := '0';
	signal userlogic_data_out: uint8_t;
			
			
 	--Outputs
   signal status_out : std_logic;
   signal config_sleep : std_logic;
   signal task_complete : std_logic;
   signal userlogic_reset : std_logic;
   signal userlogic_sleep : std_logic;
	signal userlogic_data_in: uint8_t;
	signal userlogic_address : uint16_t;
	signal userlogic_rd	: std_logic;
	signal userlogic_wr	: std_logic;
   signal interface_leds : std_logic_vector(3 downto 0);
   signal tx : std_logic;
   signal sram_data_out : uint8_t;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	
-- procedures
	procedure write_uint8_t(constant data : in uint8_t; constant address : in uint16_t; signal address_out : out uint16_t; signal data_out : out uint8_t; signal wr : out std_logic) is
	begin
		address_out <= address;
		data_out <= data;
		wr <= '1';
		wait for clk_period;
		wr <= '0';
		wait for clk_period;
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
	
	procedure read_uint8_t(constant address : in uint16_t; signal address_out : out uint16_t; signal rd : out std_logic) is
	begin
		address_out <= address;
		rd <= '1';
		wait for clk_period;
		rd <= '0';
		wait for clk_period;
	end procedure;

	procedure read_uint24_t(constant address : in uint16_t; signal address_out : out uint16_t; signal rd : out std_logic) is
	begin
		read_uint8_t(address, address_out, rd);
		read_uint8_t(address + 1, address_out, rd);
		read_uint8_t(address + 2, address_out, rd);
	end procedure;

	procedure read_uint32_t(constant address : in uint16_t; signal address_out : out uint16_t; signal rd : out std_logic) is
	begin
		read_uint8_t(address, address_out, rd);
		read_uint24_t(address + 1, address_out, rd);
	end procedure;
	
	
	signal busy : boolean := true;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: middleware PORT MAP (
		reset => reset,
		clk => clk,

		-- userlogic
		userlogic_reset => userlogic_reset,
		userlogic_done => userlogic_done,
		userlogic_data_in => userlogic_data_in,
		userlogic_data_out => userlogic_data_out,
		userlogic_address	=> userlogic_address,
		userlogic_rd => userlogic_rd,
		userlogic_wr => userlogic_wr,
		
		-- debug
		interface_leds => interface_leds,
		
		-- uart
		rx => rx,
		tx => tx,
		
		-- sram
		sram_address => sram_address,
		sram_data_out => sram_data_out,
		sram_data_in => sram_data_in,
		sram_rd => sram_rd,
		sram_wr => sram_wr
        );

	ul: entity work.VectorDotproductSkeleton(Behavioral)
		port map (clk, reset, userlogic_done, userlogic_rd, userlogic_wr, userlogic_data_in, userlogic_address, userlogic_data_out);
      

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
		reset <= '1';
		wait for clk_period*10;
		reset <= '0';
		
      -- insert stimulus here \
		write_uint24_t(x"000000", x"0000", sram_address, sram_data_in, sram_wr);
		write_uint8_t(x"02", x"0003", sram_address, sram_data_in, sram_wr);
		-- ul
		write_uint32_t(x"01000000", x"0100", sram_address, sram_data_in, sram_wr);
		write_uint32_t(x"00010000", x"0104", sram_address, sram_data_in, sram_wr);
		write_uint32_t(x"10000000", x"0108", sram_address, sram_data_in, sram_wr);
		
		if userlogic_done = '0' then
			wait until userlogic_done = '1';
		end if;
		
		wait for clk_period * 2;
		read_uint32_t(x"010C", sram_address, sram_rd);
		read_uint32_t(x"0104", sram_address, sram_rd);
		read_uint32_t(x"0108", sram_address, sram_rd);
		
		wait for clk_period * 12;
		busy <= false;
      wait;
   end process;

END;
