----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:56:23 10/04/2016 
-- Design Name: 
-- Module Name:    CommunicationStateMachine - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CommunicationStateMachine is
	port(
		clk			: in std_logic;							-- clock
		reset			: in std_logic;							-- reset everything
		
		data_in		: in std_logic_vector(7 downto 0);	-- data from controller
		data_in_rdy	: in std_logic;							-- new data avail to receive
		data_out		: out std_logic_vector(7 downto 0);	-- data to be sent 
		data_out_rdy: out std_logic := '0';					-- new data avail to send
		data_out_done: in std_logic;							-- data send complete
		
		spi_en		: out std_logic := '0';					-- activate sending to spi
		spi_continue: out std_logic := '0';					-- keep spi alive to keep reading/writing
		spi_busy 	: in std_logic;
		uart_en		: out std_logic := '0';					-- activate sending to uart
		icap_en		: out std_logic := '0';
		multiboot	: out std_logic_vector(23 downto 0);-- for outputting new address to icap
		fpga_sleep	: out std_logic := '0';					-- put configuration to sleep
		
		--debug
		ready			: out std_logic;
		current_state : out std_logic_vector(3 downto 0)
	);
end CommunicationStateMachine;

architecture Behavioral of CommunicationStateMachine is

-- communication protocol
constant WRITE_FLASH 					: std_logic_vector(7 downto 0) := x"00"; --! header;24bit address;32bit size;data
constant READ_FLASH_REQUEST			: std_logic_vector(7 downto 0) := x"01"; --! header;24bit address;32bit size
constant SET_NEXT_CONFIG_ADDRESS		: std_logic_vector(7 downto 0) := x"06"; --! header;24bit address;
constant SLEEP_FPGA						: std_logic_vector(7 downto 0) := x"08"; --! header
constant WAKE_FPGA						: std_logic_vector(7 downto 0) := x"09"; --! header

-- receiving fsm
type receive_state is (
	idle, 									-- 0
	receiving_flash_request_address, -- 1
	receiving_flash_request_size,    -- 2
	sending_flash_request, 				-- 3
	send_flash_response, 				-- 4
	receiving_next_config, 				-- 5
	send_icap_multiboot					-- 6
	);
signal current_receive_state: receive_state := idle;
signal state_count 			: integer range 0 to 16; --! count how many times this state has happened

signal byte_count				: integer range 0 to 10 := 0;

-- intermediate signals for receiving data
signal flash_address 		: std_logic_vector(23 downto 0);
signal flash_size				: std_logic_vector(23 downto 0);

signal flash_man				: std_logic_vector(7 downto 0);
signal flash_dev	 			: std_logic_vector(15 downto 0);

begin
	
	
	--! React to availability of new byte incoming
	process (clk, data_in_rdy, reset, current_receive_state)
	begin
		if reset = '1' then 
			current_receive_state <= idle;
			byte_count <= 0;
			state_count <= 0;
		elsif rising_edge(clk) then
			
			--! Respond based on what state the middleware is in 
			case current_receive_state is
				--! different states 
				when idle =>

					if data_in_rdy = '1' then
						byte_count <= byte_count + 1;

						--! see if new command is being received
						case data_in is
							--! Set next Configuration Address
							when READ_FLASH_REQUEST =>
								current_receive_state <= receiving_flash_request_address;
							when SET_NEXT_CONFIG_ADDRESS =>
								current_receive_state <= receiving_next_config;
								state_count <= 0;
							when SLEEP_FPGA =>
								fpga_sleep <= '1';
							when WAKE_FPGA => 
								fpga_sleep <= '0';
							when others => 
						end case;
						state_count <= 0;
					end if;
				when receiving_flash_request_address =>
					if data_in_rdy = '1' then

						state_count <= state_count + 1; --! only incremented at end of process
					
						case state_count is
							when 0 =>
								flash_address(23 downto 16) <= data_in;
							when 1 =>
								flash_address(15 downto 8) <= data_in;
							when 2 =>
								flash_address(7 downto 0) <= data_in;
								current_receive_state <= receiving_flash_request_size;
								state_count <= 0;
							when others =>
						end case;
					end if;
				when receiving_flash_request_size =>
					if data_in_rdy = '1' then
						state_count <= state_count + 1; --! only incremented at end of process

						case state_count is
							when 0 =>
								flash_size(23 downto 16) <= data_in;
							when 1 =>
								flash_size(15 downto 8) <= data_in;
							when 2 =>
								flash_size(7 downto 0) <= data_in;
								current_receive_state <= sending_flash_request;
								state_count <= 0;
							when others =>
						end case;
					end if;
				when sending_flash_request =>
					case state_count is

						when 0 => -- send 9f
							-- assert cs low and connect spi data registers
							spi_en <= '1';
							
							-- provide data
							data_out <= x"9F";
							data_out_rdy <= '1';
							
							state_count <= state_count + 1;
						when 1 => 
							-- wait for data to be start sending
							data_out_rdy <= '0';
							spi_en <= '0';
							spi_continue <= '1'; -- make spi interface continue to receive
							-- TODO: data_out_busy
							if spi_busy = '1' then -- currently connected to spi di_req_o
								state_count <= state_count + 1; --! only incremented at end of process
							end if;
						when 2 => 
							-- wait for data to be done sending
							if spi_busy = '0' then -- currently connected to spi di_req_o
								state_count <= state_count + 1; --! only incremented at end of process
							end if;
						when 3 => -- receive first
							spi_continue <= '0';
							-- now wait for incoming data 1
							if data_in_rdy = '1' then
								flash_man <= data_in;
								state_count <= state_count + 1;
								spi_continue <= '0';
							end if;
						when 4 =>
							-- wait for previous to end
							if data_in_rdy = '0' then
								state_count <= state_count + 1;
							end if;
						when 5 =>
							-- now wait for incoming data 2
							if data_in_rdy = '1' then
								flash_dev(15 downto 8) <= data_in;
								state_count <= state_count + 1;
							end if;
						when 6 =>
							-- wait for previous to end
							if data_in_rdy = '0' then
								state_count <= state_count + 1;
							end if;
						when 7 =>
							-- now wait for incoming data 3
							if data_in_rdy = '1' then
								flash_dev(7 downto 0) <= data_in;
								current_receive_state <= send_flash_response;
								state_count <= 0;
								spi_en <= '0';
							end if;
						when others =>
					end case;
				when send_flash_response =>
					case state_count is
						-- send first byte
						when 0 =>
							uart_en <= '1';
							data_out <= flash_man;
							data_out_rdy <= '1';
							state_count <= state_count + 1;
						when 1 =>
							data_out_rdy <= '0';
							if data_out_done = '1' then
								current_receive_state <= Idle;
								uart_en <= '0';
							end if;
						when others =>
					end case;
				when receiving_next_config =>
					if data_in_rdy = '1' then
						--! receive a byte of config
						case state_count is
							when 0 =>
								multiboot(23 downto 16) <= data_in;
							when 1 =>
								multiboot(15 downto 8) <= data_in;
							when 2 =>
								multiboot(7 downto 0) <= data_in;
								current_receive_state <= send_icap_multiboot;
							when others =>
						end case;
						state_count <= state_count + 1;
					end if;
				when send_icap_multiboot =>
					-- set icap for one clock cycle
					current_receive_state <= idle;
				when others =>
					current_receive_state <= idle;
			end case;
		end if;
		current_state <= std_logic_vector(to_unsigned(receive_state'pos(current_receive_state), 4));

	end process;

icap_en <= '1' when current_receive_state = send_icap_multiboot else '0';
ready <= '1' when current_receive_state = idle else '0';
end Behavioral;

