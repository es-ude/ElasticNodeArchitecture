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

library work;
use work.MatrixMultiplication;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
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
	signal sending_state : std_logic_vector(3 downto 0);
	signal receiving_state : std_logic_vector(3 downto 0);

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
	
	procedure uart_op_32(constant data : in std_logic_vector(31 downto 0); signal data_in : out std_logic_vector(7 downto 0); signal data_in_rdy : out std_logic) is
	begin
		uart_op(data(31 downto 24), data_in, data_in_rdy);
		uart_op(data(23 downto 16), data_in, data_in_rdy);
		uart_op(data(15 downto 8), data_in, data_in_rdy);
		uart_op(data(7 downto 0), data_in, data_in_rdy);
	end procedure;
	
	procedure sleep_fpga(signal data_in : out std_logic_vector(7 downto 0); signal data_in_rdy : out std_logic) is
	begin
		-- sleep fpga
		uart_op(x"08", data_in, data_in_rdy);
	end sleep_fpga;
	
	procedure wake_fpga(signal data_in : out std_logic_vector(7 downto 0); signal data_in_rdy : out std_logic) is
	begin
		-- wake fpga
		uart_op(x"09", data_in, data_in_rdy);
	end wake_fpga;
	
	procedure vector_dotproduct(signal data_in : out std_logic_vector(7 downto 0); signal data_in_rdy : out std_logic) is
	begin
		-- write ram data
		uart_op(x"03", data_in, data_in_rdy); 			-- command

		-- stimulus for vectordotproduct
		uart_op_32(x"10203040", data_in, data_in_rdy); 								-- address
		uart_op_32(x"0000000C", data_in, data_in_rdy); 								-- size
		
		uart_op_32(x"00000001", data_in, data_in_rdy); 								-- data a
		uart_op_32(std_logic_vector(to_unsigned(100, 32)), data_in, data_in_rdy); 	-- data b
		uart_op_32(std_logic_vector(to_unsigned(75, 32)), data_in, data_in_rdy); 	-- data c
	end procedure;
	
	procedure matrix_multiplication(signal data_in : out std_logic_vector(7 downto 0); signal data_in_rdy : out std_logic) is
	begin
		-- write ram data
		uart_op(x"03", data_in, data_in_rdy); 			-- command
		
		-- stimulus for matrixmultiplication
		uart_op_32(x"10203040", data_in, data_in_rdy); 										-- address
		
		uart_op_32(std_logic_vector(to_unsigned(108, 32)), data_in, data_in_rdy); 	-- size
		
		-- inputA 12*4=48
		-- row 1
		uart_op_32(x"00000000", data_in, data_in_rdy);
		uart_op_32(x"00000001", data_in, data_in_rdy);
		uart_op_32(x"00000009", data_in, data_in_rdy);

		-- row 2
		uart_op_32(x"00000002", data_in, data_in_rdy);
		uart_op_32(x"00000000", data_in, data_in_rdy);
		uart_op_32(x"00000001", data_in, data_in_rdy);

		-- row 3
		uart_op_32(x"00000001", data_in, data_in_rdy);
		uart_op_32(x"00000005", data_in, data_in_rdy);
		uart_op_32(x"00000000", data_in, data_in_rdy);

		-- row 4
		uart_op_32(x"00000001", data_in, data_in_rdy);
		uart_op_32(x"00000001", data_in, data_in_rdy);
		uart_op_32(x"00000000", data_in, data_in_rdy);
		
		-- input B 15*4=60
		-- row 1
		uart_op_32(x"00000000", data_in, data_in_rdy);
		uart_op_32(x"00000001", data_in, data_in_rdy);
		uart_op_32(x"00000004", data_in, data_in_rdy);
		uart_op_32(x"00000002", data_in, data_in_rdy);
		uart_op_32(x"00000007", data_in, data_in_rdy);
		
		-- row 2
		uart_op_32(x"00000000", data_in, data_in_rdy);
		uart_op_32(x"00000001", data_in, data_in_rdy);
		uart_op_32(x"00000003", data_in, data_in_rdy);
		uart_op_32(x"00000002", data_in, data_in_rdy);
		uart_op_32(x"00000004", data_in, data_in_rdy);
		
		-- row 3
		uart_op_32(x"00000000", data_in, data_in_rdy);
		uart_op_32(x"00000002", data_in, data_in_rdy);
		uart_op_32(x"00000003", data_in, data_in_rdy);
		uart_op_32(x"00000004", data_in, data_in_rdy);
		uart_op_32(x"00000005", data_in, data_in_rdy);
	end procedure;
	
	procedure config_address(constant address : std_logic_vector(23 downto 0); signal data_in : out std_logic_vector(7 downto 0); signal data_in_rdy : out std_logic) is
	begin
		-- load new configuration address
		uart_op(x"06", data_in, data_in_rdy); 			-- command
		uart_op(address(23 downto 16), data_in, data_in_rdy); 			-- first byte
		uart_op(address(15 downto 8), data_in, data_in_rdy); 			-- second byte
		uart_op(address(7 downto 0), data_in, data_in_rdy); 			-- third byte
	end procedure;
	
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
			 receiving_state,
			 sending_state
        );

	ic : entity fpgamiddlewarelibs.icapInterface(Behavioral)
		generic map (goldenboot_address => (others => '0')) 
		port map (clk => clk, enable => icap_en, status_running => open, multiboot_address => multiboot);

	-- initialise user logic
	ul: entity work.VectorDotproduct(Behavioral) port map
	--ul: entity work.MatrixMultiplication(Behavioral) port map
		(
			clk, not fpga_sleep, userlogic_rdy, userlogic_done, userlogic_data_out_rdy, userlogic_data_out_done, userlogic_data_in_rdy, userlogic_data_in, userlogic_data_out
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
		--reset <= '1';
      -- wait for 100 ns;	
		reset <= '0';
	
		wait for uart_byte_time * 20;
		
		sleep_fpga(data_in, data_in_rdy);
		wake_fpga(data_in, data_in_rdy);
		wait for uart_byte_time * 8;
		
		vector_dotproduct(data_in, data_in_rdy);
		
		-- matrix_multiplication(data_in, data_in_rdy);
		wait until userlogic_rdy = '1';
		wait for uart_byte_time * 32;
		-- matrix_multiplication(data_in, data_in_rdy);
		
		config_address(x"123456", data_in, data_in_rdy);

		

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
		-- wait until data_in_32_rdy = '0';
		wait for uart_byte_time * 25;
		
		busy <= '0';
		wait;

   end process;

END;
