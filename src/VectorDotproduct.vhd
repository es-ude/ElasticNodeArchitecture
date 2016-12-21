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



entity VectorDotproduct is
	port (
		-- control interface
		clock				: in std_logic;
		enable			: in std_logic; -- controls functionality (sleep)
		-- run				: in std_logic; -- indicates the beginning and end
		ready 			: out std_logic; -- new transmission may begin
		-- done 				: out std_logic; -- done with entire calculation
		
		-- data control interface
		data_out_rdy	: out std_logic;
		data_in_rdy		: in std_logic;
		
		-- data interface
		data_in			: in std_logic_vector(31 downto 0);
		data_out			: out std_logic_vector(31 downto 0)
	);
end VectorDotproduct;

architecture Behavioral of VectorDotproduct is
	-- signal inputA, inputB : unsigned(31 downto 0);
	signal intermediate_result : unsigned(31 downto 0);

	type receive_state is (idle, receiveN, receiveA, receiveB, receiveDone);
	signal current_receive_state : receive_state := idle;
begin

	-- process data receive 
	process (clock, enable, data_in_rdy, current_receive_state)
		variable inputA, inputB : unsigned(15 downto 0);
		variable vector_width, current_dimension : unsigned(31 downto 0);
	begin
		if enable = '1' then
			-- beginning/end
			-- if run = '1' then
				if rising_edge(clock) then
					if current_receive_state = idle then
						-- initiate all required variables
						current_receive_state <= receiveN; -- begin operation
						current_dimension := (others => '0');
						data_out_rdy <= '0';
						data_out <= (others => '0');
					elsif current_receive_state = receiveDone then
						data_out_rdy <= '0';
						current_receive_state <= idle;
						
					-- respond to incoming data
					elsif data_in_rdy = '1' then
						case current_receive_state is
							when receiveN => 
								vector_width := unsigned(data_in);
								-- reset important counters
								current_receive_state <= receiveA;
								intermediate_result <= (others => '0');
							when receiveA =>
								inputA := unsigned(data_in(15 downto 0));
								current_receive_state <= receiveB;
								current_dimension := current_dimension + 1;
							when receiveB =>
								inputB := unsigned(data_in(15 downto 0));
								intermediate_result <= intermediate_result + inputA * inputB;
								
								-- receive another dimension or return
								if current_dimension = vector_width then
									current_receive_state <= receiveDone; -- display output
									data_out_rdy <= '1';
									data_out <= std_logic_vector(intermediate_result);
								else
									current_receive_state <= receiveA; -- receive another 
								end if;
							when others => 
								current_receive_state <= receiveN;
								current_dimension := (others => '0');
						end case;
								
					end if;
				-- end if;
			else
				data_out_rdy <= '0';
				data_out <= (others => '0');
			end if;
		end if;
	end process;
	
	ready <= '1' when enable = '1' and current_receive_state = receiveN else '0';

end Behavioral;

