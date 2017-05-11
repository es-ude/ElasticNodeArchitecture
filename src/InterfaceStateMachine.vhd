----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

entity InterfaceStateMachine is
	port(
		clk					: in std_logic;							-- clock
		reset					: in std_logic;							-- reset everything
		
		data_in_8			: in uint8_t_interface;
		data_out_8			: out uint8_t_interface;	-- data to be sent 
		data_out_8_done	: in std_logic;							-- data send complete
		data_in_32			: in uint32_t_interface;
		data_in_32_done	: out std_logic := '0';					-- data is done being written to ram
		data_out_32			: out uint32_t_interface;
		
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
end InterfaceStateMachine;

architecture Behavior of InterfaceStateMachine is 
begin
	
end Behavior;
