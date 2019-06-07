----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:39:26 03/15/2017 
-- Design Name: 
-- Module Name:    VectorDotproductSkeleton - Behavioral 
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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VectorDotproductSkeleton is
port (
		-- control interface
		clock				: in std_logic;
		enable				: in std_logic; -- controls functionality (sleep)
		-- run				: in std_logic; -- indicates the beginning and end
		ready 			: out std_logic; -- new transmission may begin
		done 				: out std_logic; -- done with entire calculation
		
--		-- data control interface
--		data_out_rdy	: out std_logic;
--		data_in_rdy		: in std_logic;
		
		-- data interface
		data_in			: in uint32_t_interface; -- std_logic_vector(31 downto 0);
		data_out			: out uint32_t_interface; -- std_logic_vector(31 downto 0)
		data_out_done	: in std_logic
		);
end VectorDotproductSkeleton;

architecture Behavioral of VectorDotproductSkeleton is
	-- generic
	type receive_state is (idle, receiveN, receiveA, receiveB, receiveDone, sendingResult);
	signal current_receive_state : receive_state := idle;
	signal data_clock : std_logic := '0';
	
	-- internal variables
	constant OUTPUT_SIZE : unsigned := to_unsigned(4, 32);
	
	-- interfacing variables
	signal enable_hwf : std_logic := '0';
	signal vectorA, vectorB, result : unsigned(31 downto 0);
	
begin

-- userlogic instantiate
vdp: entity work.VectorDotproduct(Behavioral)
	port map (data_clock, enable_hwf, enable, vectorA, vectorB, result);

	-- process data receive 
	process (clock, enable, data_in.ready, current_receive_state)
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
						data_out.ready <= '0';
						data_out.data <= (others => '0');
						ready <= '1';
						enable_hwf <= '0';
						-- done <= '0';
--					elsif current_receive_state = receiveDone then
--						if data_out_done = '1' then
--							current_receive_state <= headerDone;
--						end if;
					elsif current_receive_state = receiveDone then
						if data_out_done = '1' then
							current_receive_state <= sendingResult;
							data_out.data <= result;
						end if;
					elsif current_receive_state = sendingResult then
						data_out.ready <= '0';
						if data_out_done = '1' then
							current_receive_state <= idle;
						end if;
										
					-- respond to incoming data
					elsif data_in.ready = '1' then
						done <= '0';
						ready <= '0';
						case current_receive_state is
							when receiveN => 
								enable_hwf <= '0';
								vector_width := unsigned(data_in.data);
								-- reset important counters
								current_receive_state <= receiveA;
							when receiveA =>
								enable_hwf <= '1';
								
								vectorA <= unsigned(data_in.data);
								-- inputA := unsigned(data_in(15 downto 0));
								current_receive_state <= receiveB;
								current_dimension := current_dimension + 1;
								
								data_clock <= '0';
							when receiveB =>
								vectorB <= unsigned(data_in.data);
								-- inputB := unsigned(data_in(15 downto 0));
								-- intermediate_result := intermediate_result + inputA * inputB;
								
								data_clock <= '1';
								
								-- receive another dimension or return
								if current_dimension = vector_width then
									current_receive_state <= receiveDone; -- display output
									done <= '1';
									data_out.ready <= '1';
									data_out.data <= OUTPUT_SIZE;
								else
									current_receive_state <= receiveA; -- receive another 
								end if;
							when others => 
								current_receive_state <= receiveN;
								enable_hwf <= '0';
								current_dimension := (others => '0');
						end case;
								
					end if;
				-- end if;
			end if;
		else
			data_out.ready <= '0';
			data_out.data <= (others => '0');
			done <= '0';
			ready <= '0';
			current_receive_state <= idle;
			enable_hwf <= '0';
		end if;
		-- intermediate_result_out <= intermediate_result;
	end process;
	
	
end Behavioral;

