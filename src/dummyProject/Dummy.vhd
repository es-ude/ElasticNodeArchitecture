----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:00:45 12/20/2016 
-- Design Name: 
-- Module Name:    vector_dotproduct - Behavioral 
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
use fpgamiddlewarelibs.UserLogicInterface.all;



entity Dummy is
	port (
		-- control interface
		clock				: in std_logic;
		reset 				: in std_logic;
		busy			: in std_logic; -- controls functionality (sleep)
		-- run				: in std_logic; -- indicates the beginning and end
		-- ready 			: out std_logic; -- new transmission may begin
		-- done 				: out std_logic; -- done with entire calculation
		
		-- data control interface
		-- data_out_rdy	: out std_logic;
		-- data_out_done	: in std_logic;
		-- data_in_rdy		: in std_logic;

		data_rd			: in std_logic;
		data_wr			: in std_logic;
		
		-- data interface
		data_in			: in uint8_t;
		data_address	: in uint16_t;
		data_out			: out uint8_t
	);
end Dummy;

architecture Behavioral of Dummy is
	-- signal inputA, inputB : unsigned(31 downto 0);
	type receive_state is (idle, receive, send);
	signal current_receive_state : receive_state := idle;
	signal intermediate_result_out : unsigned(31 downto 0);
begin
	data_out <= x"DD";
	-- process data receive 
	-- process (clock, data_rd, data_in_rdy, current_receive_state)
	-- 	variable intermediate_result : unsigned(31 downto 0);
	-- begin
		-- if data_rd = '0' then
		-- 	-- beginning/end
		-- 	-- if run = '1' then
		-- 		if rising_edge(clock) then
		-- 			if current_receive_state = idle then
		-- 				-- initiate all required variables
		-- 				current_receive_state <= receive; -- begin operation
		-- 				data_out_rdy <= '0';
		-- 				data_out <= (others => '0');
		-- 				intermediate_result := (others => '0');
		-- 				ready <= '1';
		-- 			elsif current_receive_state = send then
		-- 				data_out_rdy <= '0';
		-- 				if data_out_done = '1' then
		-- 					current_receive_state <= idle;
		-- 				end if;
						
		-- 			-- respond to incoming data
		-- 			elsif data_in_rdy = '1' then
		-- 				done <= '0';
		-- 				ready <= '0';
		-- 				case current_receive_state is
		-- 					when receive => 
		-- 						intermediate_result := unsigned(data_in);
		-- 						done <= '1';
		-- 						data_out_rdy <= '1';
		-- 						data_out <= std_logic_vector(intermediate_result);
								
		-- 						current_receive_state <= send; -- receive another 
		-- 					when others => 
		-- 						current_receive_state <= receive;
		-- 				end case;
								
		-- 			end if;
		-- 		-- end if;
		-- 	end if;
		-- else
		-- 	data_out_rdy <= '0';
		-- 	data_out <= (others => '0');
		-- 	done <= '0';
		-- end if;
		-- intermediate_result_out <= intermediate_result;
	-- end process;
	
end Behavioral;

