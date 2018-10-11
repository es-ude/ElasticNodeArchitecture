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
use fpgamiddlewarelibs.userlogicinterface.all;

library matrixmultiplication;
use matrixmultiplication.MatrixMultiplication;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY TestCommunicationStateMachine IS
END TestCommunicationStateMachine;
 
ARCHITECTURE behavior OF TestCommunicationStateMachine IS 
    --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal data_in : uint8_t_interface;
   -- signal data_in_rdy : std_logic := '0';
   signal data_out : uint8_t_interface;
   -- signal data_out_rdy : std_logic := '0';
	signal data_out_32 : uint32_t_interface;
	signal data_in_32 : uint32_t_interface;
   -- signal data_in_32_rdy : std_logic;
   -- signal data_out_32_rdy : std_logic := '0';
	signal data_out_done : std_logic := '0';
	signal data_out_32_done : std_logic := '0';
   -- signal spi_en : std_logic := '0';
	-- signal spi_en_strobe : std_logic;
	signal userlogic_en : std_logic := '0';
   signal uart_en : std_logic := '0';
   signal icap_en : std_logic := '0';
   signal multiboot : uint24_t;
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
	signal userlogic_data_in, userlogic_data_out : uint32_t_interface;
	
	-- uart data signal
	signal uart_data_out, uart_data_in : uint8_t_interface;
	signal uart_data_out_rdy, uart_data_out_done, uart_tx : std_logic;
	
	procedure uart_op(constant data : in std_logic_vector(7 downto 0); signal data_in : out uint8_t_interface) is
	begin
		data_in.data <= unsigned(data);
		data_in.ready <= '1';
		wait for clk_period;
		data_in.ready <= '0';
		wait for uart_byte_time;
	end uart_op;
	
	procedure uart_op_32(constant data : in std_logic_vector(31 downto 0); signal data_in : out uint8_t_interface) is
	begin
		uart_op(data(7 downto 0), data_in);
		uart_op(data(15 downto 8), data_in);
		uart_op(data(23 downto 16), data_in);
		uart_op(data(31 downto 24), data_in);
	end procedure;
	
	procedure sleep_fpga(signal data_in : out uint8_t_interface) is
	begin
		-- sleep fpga
		uart_op(x"08", data_in);
	end sleep_fpga;
	
	procedure wake_fpga(signal data_in : out uint8_t_interface) is
	begin
		-- wake fpga
		uart_op(x"09", data_in);
	end wake_fpga;
	
	procedure dummy(signal data_in : out uint8_t_interface) is
	begin
		-- write ram data
		uart_op(x"03", data_in); 			-- command

		-- stimulus for vectordotproduct
		uart_op_32(x"10203040", data_in); 								-- address
		uart_op_32(x"00000004", data_in); 								-- size
		
		uart_op_32(std_logic_vector(to_unsigned(100, 32)), data_in); 	-- data
	end procedure;
	
	procedure vector_dotproduct(signal data_in : out uint8_t_interface) is
	begin
		-- write ram data
		uart_op(x"0D", data_in); 			-- command

		-- stimulus for vectordotproduct
		-- uart_op_32(x"10203040", data_in, data_in_rdy); 								-- address
		uart_op_32(x"00000014", data_in); 								-- size
		
		uart_op_32(x"00000002", data_in); 								-- data a
		uart_op_32(std_logic_vector(to_unsigned(100, 32)), data_in); 	-- data b
		uart_op_32(std_logic_vector(to_unsigned(75, 32)), data_in); 	-- data c
		uart_op_32(std_logic_vector(to_unsigned(100, 32)), data_in); 	-- data b
		uart_op_32(std_logic_vector(to_unsigned(75, 32)), data_in); 	-- data c
	end procedure;
	
	procedure matrix_multiplication(signal data_in : out uint8_t_interface) is
	begin
		-- write ram data
		uart_op(x"0D", data_in); 			-- command
		
		-- stimulus for matrixmultiplication
		-- uart_op_32(x"10203040", data_in, data_in_rdy); 										-- address
		
		uart_op_32(std_logic_vector(to_unsigned(108, 32)), data_in); 	-- size
		
		-- inputA 12*4=48
		-- row 1
		uart_op_32(x"00000000", data_in);
		uart_op_32(x"00000001", data_in);
		uart_op_32(x"00000009", data_in);

		-- row 2
		uart_op_32(x"00000002", data_in);
		uart_op_32(x"00000000", data_in);
		uart_op_32(x"00000001", data_in);

		-- row 3
		uart_op_32(x"00000001", data_in);
		uart_op_32(x"00000005", data_in);
		uart_op_32(x"00000000", data_in);

		-- row 4
		uart_op_32(x"00000001", data_in);
		uart_op_32(x"00000001", data_in);
		uart_op_32(x"00000000", data_in);
		
		-- input B 15*4=60
		-- row 1
		uart_op_32(x"00000000", data_in);
		uart_op_32(x"00000001", data_in);
		uart_op_32(x"00000004", data_in);
		uart_op_32(x"00000002", data_in);
		uart_op_32(x"00000007", data_in);
		
		-- row 2
		uart_op_32(x"00000000", data_in);
		uart_op_32(x"00000001", data_in);
		uart_op_32(x"00000003", data_in);
		uart_op_32(x"00000002", data_in);
		uart_op_32(x"00000004", data_in);
		
		-- row 3
		uart_op_32(x"00000000", data_in);
		uart_op_32(x"00000002", data_in);
		uart_op_32(x"00000003", data_in);
		uart_op_32(x"00000004", data_in);
		uart_op_32(x"00000005", data_in);
	end procedure;
	
	procedure config_address(constant address : std_logic_vector(23 downto 0); signal data_in : out uint8_t_interface) is
	begin
		-- load new configuration address
		uart_op(x"06", data_in); 			-- command
		uart_op(address(7 downto 0), data_in); 			-- third byte
 		uart_op(address(15 downto 8), data_in); 			-- second byte
		uart_op(address(23 downto 16), data_in); 			-- first byte
	end procedure;
	
BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.CommunicationStateMachine(Behavioral) PORT MAP (
          clk,
          reset,
          data_in,
          -- data_in_rdy,
          data_out,
          -- data_out_rdy,
			 data_out_done,
			 data_in_32,
			 -- data_in_32_rdy,
			 data_in_32_done,
			 data_out_32,
			 -- data_out_32_rdy,
			 
--          spi_en => spi_en,
--			 spi_continue => spi_continue,
--			 spi_busy => spi_busy,
          uart_en,
          icap_en,
			 multiboot,
			 fpga_sleep,
          userlogic_en,
			 userlogic_rdy,
			 userlogic_done,

          ready,
			 receiving_state,
			 sending_state
        );

	ic : entity fpgamiddlewarelibs.icapInterface(Behavioral)
		generic map (goldenboot_address => (others => '0')) 
		port map (clk => clk, enable => icap_en, status_running => open, multiboot_address => std_logic_vector(multiboot));

	-- initialise user logic
	-- ul: entity work.Dummy(Behavioral) port map
	ul: entity vectordotproduct.VectorDotproductSkeleton(Behavioral) port map
	-- ul: entity matrixmultiplication.MatrixMultiplication(Behavioral) port map
		(
			clk, userlogic_en, userlogic_rdy, userlogic_done, userlogic_data_in, userlogic_data_out, userlogic_data_out_done
		);
	-- userlogic_data_in_rdy <= data_out_32_rdy; -- userlogic_en;
	userlogic_data_in <= data_out_32;
	data_in_32 <= userlogic_data_out;
	userlogic_data_out_done <= data_in_32_done;
	-- data_in_32_rdy <= userlogic_data_out_rdy;
	
	-- uart for sending testing 
	uart: entity fpgamiddlewarelibs.uartInterface(arch) 
	generic map (5)
	port map
		(
			open,
			uart_data_out,
			-- uart_data_out_rdy,
			uart_data_out_done,
			--! physical interfaces
			'1',
			uart_tx, 
			clk
	);
	
	-- uart_data_in <= data_out;
	uart_data_out.data <= data_out.data;
	uart_data_out.ready <= data_out.ready and uart_en;
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
	
		-- wait for uart_byte_time * 20;
		wait for 100 ns;	
		sleep_fpga(data_in);
		wake_fpga(data_in);
		--wait for uart_byte_time * 8;
		
		vector_dotproduct(data_in);
		-- matrix_multiplication(data_in, data_in_rdy);
		-- dummy(data_in, data_in_rdy);
		
		wait until userlogic_rdy = '1';
		wait for uart_byte_time * 32;
		wait for uart_byte_time * 4;
		-- matrix_multiplication(data_in, data_in_rdy);

		vector_dotproduct(data_in);
		-- matrix_multiplication(data_in, data_in_rdy);
		-- dummy(data_in, data_in_rdy);
		
		wait until userlogic_rdy = '1';
		wait for uart_byte_time * 32;
		-- matrix_multiplication(data_in, data_in_rdy);
		
		config_address(x"000000", data_in);
		wait for uart_byte_time * 8;
		
		

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
		-- wait for uart_byte_time * 25;
		
		busy <= '0';
		wait;

   end process;

END;
