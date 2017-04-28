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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

entity CommunicationStateMachine is
	port(
		clk					: in std_logic;							-- clock
		reset					: in std_logic;							-- reset everything
		
		-- data_in				: in std_logic_vector(7 downto 0);	-- data from controller
		data_in_8			: in uint8_t_interface;
		-- data_in_rdy		: in std_logic;							-- new data avail to receive
		-- data_out			: out std_logic_vector(7 downto 0);	-- data to be sent 
		data_out_8			: out uint8_t_interface;	-- data to be sent 
		-- data_out_rdy	: out std_logic := '0';					-- new data avail to send
		data_out_8_done	: in std_logic;							-- data send complete
		data_in_32			: in uint32_t_interface;
		-- data_in_32			: in std_logic_vector(31 downto 0);	-- data to be written to the uart by the middleware
		-- data_in_32_rdy 	: in std_logic;							-- data from ram is ready
		data_in_32_done	: out std_logic := '0';					-- data is done being written to ram
		data_out_32			: out uint32_t_interface;
		-- data_out_32			: out std_logic_vector(31 downto 0);-- data to be written to the ram by the middleware
		-- data_out_32_rdy	: out std_logic := '0';					-- data for ram is ready (must be high at least one rising edge clock)
		
--		spi_en		: out std_logic := '0';					-- activate sending to spi
--		spi_continue: out std_logic := '0';					-- keep spi alive to keep reading/writing
--		spi_busy 	: in std_logic;
		uart_en				: out std_logic := '0';					-- activate sending to uart
		icap_en				: out std_logic := '0';
		multiboot			: out uint24_t; -- std_logic_vector(23 downto 0);-- for outputting new address to icap
		fpga_sleep			: out std_logic := '1';					-- put configuration to sleep
		userlogic_en		: out std_logic := '0'; 				-- communicate directly with userlogic
		userlogic_rdy		: in std_logic;							-- userlogic boot done
		userlogic_done		: in std_logic;							-- userlogic operations done
		
		--debug
		ready					: out std_logic;
		receive_state_out	: out std_logic_vector(3 downto 0);
		send_state_out		: out std_logic_vector(3 downto 0)
	);
end CommunicationStateMachine;

architecture Behavioral of CommunicationStateMachine is

-- communication protocol
constant WRITE_FLASH 								: uint8_t := x"00"; --! header;24bit address;32bit size;data
constant READ_FLASH_REQUEST						: uint8_t := x"01"; --! header;24bit address;32bit size
constant WRITE_RAM									: uint8_t := x"03"; --! header;32bit address;32bit size;data
constant READ_RAM_RESPONSE							: uint8_t := x"05"; --! header;data
constant SET_NEXT_CONFIG_ADDRESS					: uint8_t := x"06"; --! header;24bit address;
constant SLEEP_FPGA									: uint8_t := x"08"; --! header
constant WAKE_FPGA									: uint8_t := x"09"; --! header
constant MCU_TRANSMIT_PARAMETER_DATA_DIRECTLY: uint8_t := x"0D"; --! header;32bit size;data
constant FPGA_CALCULATION_RESULT					: uint8_t := x"0E"; --! header;32bit size;data
constant FPGA_READY									: uint8_t := x"10"; --! header

-- receiving fsm
type receive_state is (
	booting,
	idle, 									-- 0
	done,
	receiving_flash_request_address, -- 1
	receiving_flash_request_size,    -- 2
	receiving_ram_write_address,		-- 3
	receiving_ram_write_size,    		-- 4
	receiving_ram_write_data,    		-- 5
	sending_flash_request, 				-- 6
	send_flash_response, 				-- 7
	receiving_next_config, 				-- 8
	send_icap_multiboot,					-- 9
	receiving_parameters
	);
signal current_receive_state: receive_state := booting;
signal state_count 			: integer range 0 to 16; --! count how many times this state has happened
-- sending fsm
type sending_state is (
	idle,
	sending_header,
	sending_data,
	sending_done,
	sending_next_value,
	sending_userlogic_rdy
	);
signal current_sending_state: sending_state := idle;

signal byte_count				: integer range 0 to 10 := 4;

-- intermediate signals for receiving data
signal flash_address 		: uint24_t; -- std_logic_vector(23 downto 0);
signal flash_size				: uint24_t; 

signal flash_man				: uint8_t;
signal flash_dev	 			: uint16_t;

signal ram_address, ram_size, ram_data : unsigned(31 downto 0);

signal uart_buffer			: uint32_t;-- std_logic_vector(31 downto 0);

shared variable data_available		: boolean := false;
signal next_byte				: std_logic := 'Z';
signal current_byte			: integer range 0 to 5;	-- decides which byte to send of 32bit data, 0 is header and 5 is done
shared variable header_done 			: boolean := false;
signal data_out_done_toggle: std_logic := '0';
signal this_is_header 		: boolean := false;

begin
	
--	newdataProcess: process ( data_in_32_rdy )
--	begin
--		if rising_edge(data_in_32_rdy) then
--			uart_buffer <= data_in_32;
--			new_32_bit_data <= '1';
--		end if;
--	end process;
	
	
	-- time 32 bit data to 8 bit by toggling a done signal
	-- assuming data_out_done is only high one clock cycle...
	convert8bit32bitProcess: process  (reset, clk, current_sending_state, data_out_8_done)
		variable was_low : boolean := true;
	begin
		if reset = '1' then
			data_out_done_toggle <= '0';
			current_byte <= 0;
		elsif falling_edge(clk) then
			-- if not currently sending, reset values
			if (current_sending_state = sending_data) then -- (current_sending_state = sending_header) or 
				if data_out_8_done = '1' and was_low then
					was_low := false;
					data_out_done_toggle <= not data_out_done_toggle;
					next_byte <= '1';
					
					-- if this is the header, we do not increment current byte
					if not this_is_header then
						if current_byte = 5 then 
							-- data_out_rdy <= '0';
						else 
							-- data_out_rdy <= '1';
							current_byte <= current_byte + 1;
						end if;
					end if;
				else
					next_byte <= '0';
					was_low := true;
				end if;
			else
				data_out_done_toggle <= '0';
				current_byte <= 0;

			end if;
		end if;
	end process;		
	
	sendingProcess: process (reset, clk, data_in_32.ready, data_out_8_done, userlogic_done, userlogic_rdy)
		-- variable bytecount : integer range 0 to 4 := 4;
		-- variable data_available: boolean := false;
		variable userlogic_return : boolean := false;
		variable delay_one_cycle : boolean := false;
		variable direct_to_first_byte : boolean := false;
		variable userlogic_was_not_rdy : boolean := true;
		variable state_count : integer range 0 to 7 := 0;
	begin
		if reset = '1' then
			current_sending_state <= idle;
			userlogic_return := false;
			delay_one_cycle := false;
			direct_to_first_byte := false;
			userlogic_was_not_rdy := true;
			data_out_8.ready <= '0';
			uart_en <= '0';
			data_in_32_done <= '0';
			data_out_8.data <= (others => '0');
			state_count := 0;
		else
			-- add return header to next incoming data
			if rising_edge(clk) then
				-- advance bytecount when readys
				case current_sending_state is
				when idle =>
					data_out_8.ready <= '0';
					uart_en <= '0';
					data_in_32_done <= '0';
					if userlogic_was_not_rdy and userlogic_rdy = '1' then
						current_sending_state <= sending_userlogic_rdy;
						userlogic_was_not_rdy := false;
					else
						if userlogic_rdy = '0' then
							userlogic_was_not_rdy := true;
						end if;
						if data_in_32.ready = '1' then
							uart_buffer <= data_in_32.data;
							if userlogic_done = '1' then
								current_sending_state <= sending_header;
							else
								current_sending_state <= sending_data;
								-- TODO INTERMEDIATE RESULTS FIRST BYTE
							end if;
						end if;
					end if;
				when sending_userlogic_rdy =>
					data_out_8.ready <= '1';
					data_out_8.data <= FPGA_READY;
					-- current_sending_state <= idle;
					uart_en <= '1';
					
					if state_count < 5 then
						state_count := state_count + 1;
					else
						current_sending_state <= idle;
					end if;
					
				when sending_header =>
					data_out_8.ready <= '1';
					-- if data_ then
					data_out_8.data <= FPGA_CALCULATION_RESULT;
					data_available := false;
					current_sending_state <= sending_data;
					uart_en <= '1';
					direct_to_first_byte := false;
					this_is_header <= true;

				when sending_data =>
					data_out_8.ready <= '0';
					uart_en <= '1';
					
					if next_byte = '1' or direct_to_first_byte then -- (data_out_done = '1')
						this_is_header <= false;
						direct_to_first_byte := false;
						if current_byte < 3 then
							data_out_8.ready <= '1';
						else
							data_out_8.ready <= '1';
						end if;
						case current_byte is
							-- when coming from header first 1, otherwise 0
							-- when 0 =>
							-- 	data_out <= uart_buffer(31 downto 24);
							when 0 =>
								data_out_8.data <= uart_buffer(7 downto 0);
							when 1 =>
								data_out_8.data <= uart_buffer(15 downto 8);
							when 2 =>
								data_out_8.data <= uart_buffer(23 downto 16);
							when 3 =>
								data_out_8.data <= uart_buffer(31 downto 24);
								-- current_sending_state <= sending_done; -- disable uart next clock cycle
							when others =>
								-- data_in_32_done <= '1';
								data_out_8.ready <= '0';
								data_in_32_done <= '1';
								-- current_sending_state <= idle;
								current_sending_state <= sending_done; -- disable uart next clock cycle
								delay_one_cycle := false;
						end case;
						-- current_byte <= current_byte + 1;
					end if;
				when sending_done =>
					-- disable uart to avoid sending last byte double
					-- uart_en <= '0';
					-- if data_out_done = '1' then
					-- go straight to next 32bit value
					data_in_32_done <= '0';
					-- wait one cycle here to see if more data is available
					--if delay_one_cycle then
						if data_in_32.ready = '1' then
							-- return to idle because last byte has been sent
							current_sending_state <= sending_next_value;
						else
							current_sending_state <= idle;
						end if;
--					else
--						delay_one_cycle := true;
--					end if;
				-- delay one clock cycle to give time to prepare next 32bit value
				when sending_next_value =>
					uart_buffer <= data_in_32.data;
					current_sending_state <= sending_data;
					direct_to_first_byte := true;
				when others =>
					
				end case;
							
			end if;
		end if;
	end process;
	
	--! React to availability of new byte incoming
	receiveProcess: process (clk, data_in_8.ready, reset, current_receive_state, data_in_32.data)
		-- variable ram_address, ram_size, ram_data : unsigned(31 downto 0);
		-- variable data_in_unsigned : unsigned(7 downto 0);
		-- variable ram_data_s : unsigned(31 downto 0);
		variable data_count : unsigned(31 downto 0);
	begin
		if reset = '1' then 
			current_receive_state <= booting;
			byte_count <= 0;
			state_count <= 0;
			data_out_32.ready <= '0';
		elsif rising_edge(clk) then
			-- data_in_unsigned := unsigned(data_in);
			
			--! Respond based on what state the middleware is in 
			case current_receive_state is
				--! different states 
				when booting =>
					-- delay starting userlogic one cycle
					fpga_sleep <= '0';
					userlogic_en <= '0';
					current_receive_state <= idle;
				when idle =>
				
					if  data_in_8.ready = '1' then
						byte_count <= byte_count + 1;

						--! see if new command is being received
						case data_in_8.data is
							when MCU_TRANSMIT_PARAMETER_DATA_DIRECTLY =>
								current_receive_state <= receiving_parameters;
							when WRITE_RAM =>
								current_receive_state <= receiving_ram_write_address;
							when READ_FLASH_REQUEST =>
								current_receive_state <= receiving_flash_request_address;
							when SET_NEXT_CONFIG_ADDRESS =>
								current_receive_state <= receiving_next_config;
							when SLEEP_FPGA =>
								fpga_sleep <= '1';
								userlogic_en <= '0';
							when WAKE_FPGA => 
								fpga_sleep <= '0';
								userlogic_en <= '1';
							when others => 
						end case;
						state_count <= 0;
					end if;
				
					data_out_32.ready <= '0';
					-- userlogic_en <= '0';
				
				
				-- ram write command
				-- TODO ENDIAN
				when receiving_ram_write_address =>
					if data_in_8.ready = '1' then

						state_count <= state_count + 1; --! only incremented at end of process
					
						case state_count is
							when 0 =>
								ram_address(31 downto 24) <= data_in_8.data;
							when 1 =>
								ram_address(23 downto 16) <= data_in_8.data;
							when 2 =>
								ram_address(15 downto 8) <= data_in_8.data;
							when 3 =>
								ram_address(7 downto 0) <= data_in_8.data;
								current_receive_state <= receiving_ram_write_size;
								state_count <= 0;
							when others =>
						end case;
					end if;
				-- userlogic parameters incoming
				when receiving_parameters =>
				-- when receiving_ram_write_size =>
					if data_in_8.ready = '1' then

						state_count <= state_count + 1; --! only incremented at end of process
					
						case state_count is
							when 0 =>
								ram_size(7 downto 0) <= data_in_8.data;
							when 1 =>
								ram_size(15 downto 8) <= data_in_8.data;
							when 2 =>
								ram_size(23 downto 16) <= data_in_8.data;
							when 3 =>
								ram_size(31 downto 24) <= data_in_8.data;
								current_receive_state <= receiving_ram_write_data;
								state_count <= 0;
								data_count := (others => '0');
							when others =>
						end case;
					end if;
				-- receiving parameter data 
				when receiving_ram_write_data =>
					if data_in_8.ready = '1' then

						data_count := data_count + 1;
						
						case state_count is
							when 0 =>
								data_out_32.data(7 downto 0) <= data_in_8.data;
							when 1 =>
								data_out_32.data(15 downto 8) <= data_in_8.data;
							when 2 =>
								data_out_32.data(23 downto 16) <= data_in_8.data;
							when 3 =>
								data_out_32.data(31 downto 24) <= data_in_8.data;
								
								-- userlogic_en <= '1';
								if data_count = ram_size then
									current_receive_state <= idle;
								-- else -- TODO WHY WAS ENABLE WHEN NOT IDLE?
								end if;
								
								
								-- present ram_data as ready
								-- data_out_32 <= std_logic_vector(ram_data);
								data_out_32.ready <= '1';
							when others =>
						end case;
						
						if state_count = 3 then
							state_count <= 0;
						else
							state_count <= state_count + 1; --! only incremented at end of process
						end if;
					else 
						data_out_32.ready <= '0';
					end if;
					
				
--				-- read data from flash
--				when receiving_flash_request_address =>
--					if data_in_rdy = '1' then
--
--						state_count <= state_count + 1; --! only incremented at end of process
--					
--						case state_count is
--							when 0 =>
--								flash_address(23 downto 16) <= data_in;
--							when 1 =>
--								flash_address(15 downto 8) <= data_in;
--							when 2 =>
--								flash_address(7 downto 0) <= data_in;
--								current_receive_state <= receiving_flash_request_size;
--								state_count <= 0;
--							when others =>
--						end case;
--					end if;
--				when receiving_flash_request_size =>
--					if data_in_rdy = '1' then
--						state_count <= state_count + 1; --! only incremented at end of process
--
--						case state_count is
--							when 0 =>
--								flash_size(23 downto 16) <= data_in;
--							when 1 =>
--								flash_size(15 downto 8) <= data_in;
--							when 2 =>
--								flash_size(7 downto 0) <= data_in;
--								current_receive_state <= sending_flash_request;
--								state_count <= 0;
--							when others =>
--						end case;
--					end if;
--					
--				when sending_flash_request =>
--					case state_count is
--
--						when 0 => -- send 9f
--							-- assert cs low and connect spi data registers
--							spi_en <= '1';
--							
--							-- provide data
--							data_out <= x"9F";
--							data_out_rdy <= '1';
--							
--							state_count <= state_count + 1;
--						when 1 => 
--							-- wait for data to be start sending
--							data_out_rdy <= '0';
--							spi_en <= '0';
--							spi_continue <= '1'; -- make spi interface continue to receive
--							-- TODO: data_out_busy
--							if spi_busy = '1' then -- currently connected to spi di_req_o
--								state_count <= state_count + 1; --! only incremented at end of process
--							end if;
--						when 2 => 
--							-- wait for data to be done sending
--							if spi_busy = '0' then -- currently connected to spi di_req_o
--								state_count <= state_count + 1; --! only incremented at end of process
--							end if;
--						when 3 => -- receive first
--							spi_continue <= '0';
--							-- now wait for incoming data 1
--							if data_in_rdy = '1' then
--								flash_man <= data_in;
--								state_count <= state_count + 1;
--								spi_continue <= '0';
--							end if;
--						when 4 =>
--							-- wait for previous to end
--							if data_in_rdy = '0' then
--								state_count <= state_count + 1;
--							end if;
--						when 5 =>
--							-- now wait for incoming data 2
--							if data_in_rdy = '1' then
--								flash_dev(15 downto 8) <= data_in;
--								state_count <= state_count + 1;
--							end if;
--						when 6 =>
--							-- wait for previous to end
--							if data_in_rdy = '0' then
--								state_count <= state_count + 1;
--							end if;
--						when 7 =>
--							-- now wait for incoming data 3
--							if data_in_rdy = '1' then
--								flash_dev(7 downto 0) <= data_in;
--								current_receive_state <= send_flash_response;
--								state_count <= 0;
--								spi_en <= '0';
--							end if;
--						when others =>
--					end case;
--					
--				when send_flash_response =>
--					case state_count is
--						-- send first byte
--						when 0 =>
--							uart_en <= '1';
--							data_out <= flash_man;
--							data_out_rdy <= '1';
--							state_count <= state_count + 1;
--						when 1 =>
--							data_out_rdy <= '0';
--							if data_out_done = '1' then
--								current_receive_state <= Idle;
--								uart_en <= '0';
--							end if;
--						when others =>
--					end case;
				-- receive next multiboot address
				when receiving_next_config =>
					if data_in_8.ready = '1' then
						--! receive a byte of config
						case state_count is
							when 0 =>
								multiboot(7 downto 0) <= data_in_8.data;
							when 1 =>
								multiboot(15 downto 8) <= data_in_8.data;
							when 2 =>
								multiboot(23 downto 16) <= data_in_8.data;
								current_receive_state <= send_icap_multiboot;
							when others =>
						end case;
						state_count <= state_count + 1;
					end if;
				when send_icap_multiboot =>
					-- set icap for one clock cycle
					current_receive_state <= done;
				when done =>
					current_receive_state <= done;
				when others =>
					current_receive_state <= idle;
			end case;
		end if;
		receive_state_out <= std_logic_vector(to_unsigned(receive_state'pos(current_receive_state), 4));
		send_state_out <= std_logic_vector(to_unsigned(sending_state'pos(current_sending_state), 4));
		-- send_state_out <= std_logic_vector(data_in_32.data(3 downto 0));

	end process;

icap_en <= '1' when current_receive_state = send_icap_multiboot or current_receive_state = done else '0';
ready <= '1' when current_receive_state = idle else '0';
end Behavioral; 

