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
 
--    COMPONENT CommunicationStateMachine
--    PORT(
--		clk					: in std_logic;							-- clock
--		reset					: in std_logic;							-- reset everything
--		
--		data_in				: in std_logic_vector(7 downto 0);	-- data from controller
--		data_in_rdy			: in std_logic;							-- new data avail to receive
--		data_out				: out std_logic_vector(7 downto 0);	-- data to be sent 
--		data_out_rdy		: out std_logic := '0';					-- new data avail to send
--		data_out_done		: in std_logic;							-- data send complete
--		data_in_32			: in std_logic_vector(31 downto 0);-- data to be written to the uart by the middleware
--		data_in_32_rdy		: in std_logic;							-- data for ram is ready (must be high at least one rising edge clock
--		data_in_32_done	: in std_logic := '0';					-- data is done being written to ram
--		data_out_32			: out std_logic_vector(31 downto 0);-- data to be written to the ram by the middleware
--		data_out_32_rdy	: out std_logic := '0';					-- data for ram is ready (must be high at least one rising edge clock
--		
----		spi_en		: out std_logic := '0';					-- activate sending to spi
----		spi_continue: out std_logic := '0';					-- keep spi alive to keep reading/writing
----		spi_busy 	: in std_logic;
--		uart_en				: out std_logic := '0';					-- activate sending to uart
--		icap_en				: out std_logic := '0';
--		multiboot			: out std_logic_vector(23 downto 0);-- for outputting new address to icap
--		fpga_sleep			: out std_logic := '0';					-- put configuration to sleep
--		userlogic_en		: out std_logic := '0'; 				-- communicate directly with userlogic
--		
--		--debug
--		ready					: out std_logic;
--		current_state 		: out std_logic_vector(3 downto 0)
--        );
--    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   signal data_in_rdy : std_logic := '0';
   signal data_out : std_logic_vector(7 downto 0) := (others => '0');
   signal data_out_rdy : std_logic := '0';
	signal data_out_32 : std_logic_vector(31 downto 0) := (others => '0');
	signal data_in_32 : std_logic_vector(31 downto 0) := (others => '0');
   signal data_in_32_rdy : std_logic;
   signal data_out_32_rdy : std_logic := '0';
	signal data_out_done : std_logic := '0';
   -- signal spi_en : std_logic := '0';
	-- signal spi_en_strobe : std_logic;
	signal userlogic_en : std_logic := '0';
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
--	signal spi_busy			: std_logic;
--	signal spi_data_in		: std_logic_vector(7 downto 0);
--	signal spi_data_in_rdy	: std_logic := '0'; -- stretched strobe to send a byte 
--	signal spi_data_out 		: std_logic_vector(7 downto 0);
--	signal spi_data_out_rdy : std_logic := '0';
--	signal spi_data_in_done	: std_logic;
--	
--	signal spi_continue		: std_logic := '0';
--	
--	signal spi_cs				: std_logic;
--	signal spi_clk				: std_logic;
--	signal spi_mosi			: std_logic;
--	signal spi_miso			: std_logic := '1';
	
	signal busy : std_logic := '1';
	shared variable new_uart : std_logic := '0';
	signal data_in_32_done : std_logic;
	
	-- user logic signals 
	signal userlogic_rdy, userlogic_data_out_rdy, userlogic_data_out_done, userlogic_data_in_rdy, userlogic_done : std_logic;
	signal userlogic_data_in, userlogic_data_out : std_logic_vector(31 downto 0);
	
	-- uart data signal
	signal uart_data_out : std_logic_vector(7 downto 0);
	signal uart_data_out_rdy, uart_data_out_done, uart_tx : std_logic;
	
	procedure uart_op(constant data : in std_logic_vector(7 downto 0); signal data_in : out std_logic_vector(7 downto 0); signal data_in_rdy : out std_logic) is
	begin
		data_in <= data;
		data_in_rdy <= '1';
		wait for clk_period;
		data_in_rdy <= '0';
		wait for uart_byte_time;
	end uart_op;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.CommunicationStateMachine(Behavioral) PORT MAP (
          clk,
          reset,
          data_in,
          data_in_rdy,
          data_out,
          data_out_rdy,
			 data_out_done,
			 data_in_32,
			 data_in_32_rdy,
			 data_in_32_done,
			 data_out_32,
			 data_out_32_rdy,
			 
--          spi_en => spi_en,
--			 spi_continue => spi_continue,
--			 spi_busy => spi_busy,
          uart_en,
          icap_en,
			 multiboot,
			 fpga_sleep,
          userlogic_en,
			 userlogic_done,

          ready,
			 current_state
        );

	-- initialise user logic
	ul: entity work.VectorDotproduct(Behavioral) port map
		(
			clk, '1', userlogic_rdy, userlogic_done, userlogic_data_out_rdy, userlogic_data_out_done, userlogic_data_in_rdy, userlogic_data_in, userlogic_data_out
		);
	userlogic_data_in_rdy <= data_out_32_rdy and userlogic_en;
	userlogic_data_in <= data_out_32;
	data_in_32 <= userlogic_data_out;
	userlogic_data_out_done <= data_in_32_done;
	data_in_32_rdy <= userlogic_data_out_rdy;
	
	-- uart for sending testing 
	uart: entity fpgamiddlewarelibs.uartInterface(arch) 
	generic map (5)
	port map
		(
			x"00",
			'0',
			uart_data_out,
			uart_data_out_rdy,
			uart_data_out_done,
			--! physical interfaces
			'1',
			uart_tx, 
			clk
	);
	
	uart_data_out <= data_out;
	uart_data_out_rdy <= data_out_rdy and uart_en;
	data_out_done <= uart_data_out_done;

--	--! SPI communication interface
--	spi: entity fpgamiddlewarelibs.spiInterface(arch)
--		generic map(
--			prescaler => 2
--		)
--		port map(
--			enable => spi_en,
--			clk => clk,
--			continue => spi_continue,
--
--			busy => spi_busy,
--			data_in => data_out, -- data to be sent 
--			data_out => spi_data_out, -- data received
--			data_i_rdy => spi_data_in_rdy,
--			data_i_req => spi_data_in_done,
--			data_o_rdy => spi_data_out_rdy,
--			
--			--! SPI physical interfaces 
--			spi_cs => spi_cs,
--			spi_clk => spi_clk,
--			spi_mosi => spi_mosi,
--			spi_miso => spi_miso
--		);
--		
--	spi_data_in <= data_out;
--	spi_data_in_rdy <= data_out_rdy;

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
 

--   -- MISO process definitions
--   miso_process :process
--   begin
--		if busy = '1' then
--			
--			spi_miso <= '0';
--			wait for clk_period*3/2;
--			spi_miso <= '1';
--			wait for clk_period*3/2;
--		else
--			wait;
--		end if;
--	end process;
 

	-- uart process
--	uart_proc: process
--	begin
--		wait on new_uart;
--		-- data_in <= uart_data;
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for uart_byte_time;
--	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
	
		wait for clk_period*10;
		
		-- write ram data
		uart_op(x"03", data_in, data_in_rdy); 			-- command
		uart_op(x"10", data_in, data_in_rdy); 			-- address 1
		uart_op(x"20", data_in, data_in_rdy); 			-- address 2
		uart_op(x"30", data_in, data_in_rdy); 			-- address 3
		uart_op(x"40", data_in, data_in_rdy); 			-- address 4
		
		uart_op(x"00", data_in, data_in_rdy); 			-- size 1
		uart_op(x"00", data_in, data_in_rdy); 			-- size 2
		uart_op(x"00", data_in, data_in_rdy); 			-- size 3
		uart_op(x"0C", data_in, data_in_rdy); 			-- size 4
		
		uart_op(x"00", data_in, data_in_rdy); 			-- data a1
		uart_op(x"00", data_in, data_in_rdy); 			-- data a2
		uart_op(x"00", data_in, data_in_rdy); 			-- data a3
		uart_op(x"01", data_in, data_in_rdy); 			-- data a4
		
		uart_op(x"00", data_in, data_in_rdy); 			-- data b1
		uart_op(x"00", data_in, data_in_rdy); 			-- data b2
		uart_op(x"00", data_in, data_in_rdy); 			-- data b3
		uart_op(x"0A", data_in, data_in_rdy); 			-- data b4
		
		uart_op(x"00", data_in, data_in_rdy); 			-- data c1
		uart_op(x"00", data_in, data_in_rdy); 			-- data c2
		uart_op(x"00", data_in, data_in_rdy); 			-- data c3
		uart_op(x"0B", data_in, data_in_rdy); 			-- data c4
	
		
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
		

--		-- read from spi
--		data_in <= x"01"; 			-- spi read command
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for uart_byte_time;
--		data_in <= x"12"; 			-- address 1
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for uart_byte_time;
--		data_in <= x"34"; 			-- address 2
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for uart_byte_time;
--		data_in <= x"56"; 			-- address 3
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for uart_byte_time;
--		data_in <= x"12"; 			-- size 1
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for uart_byte_time;
--		data_in <= x"34"; 			-- size 2
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
--		wait for uart_byte_time;
--		data_in <= x"56"; 			-- size 3
--		data_in_rdy <= '1';
--		wait for clk_period;
--		data_in_rdy <= '0';
		
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
		
--		-- wait for reading from spi 
--		wait for clk_period * 24;
		
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
		
		-- wait for uart_byte_time * 20;
		wait until data_in_32_done = '1';
		wait for uart_byte_time * 5;
	
		busy <= '0';
		wait;

   end process;

END;
