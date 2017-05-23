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
		reset				: in std_logic; -- controls functionality (sleep)
		
		-- run				: in std_logic; -- indicates the beginning and end
		done 				: out std_logic; -- done with entire calculation
		
		-- indicate new data or request
		rd					: in std_logic;	-- request a variable
		wr 				: in std_logic; 	-- request changing a variable
		
		-- data interface
		data_in			: in uint8_t; -- std_logic_vector(31 downto 0);
		address_in		: in uint16_t;
		data_out			: out uint8_t -- std_logic_vector(31 downto 0)
		);
end VectorDotproductSkeleton;

architecture Behavioral of VectorDotproductSkeleton is
	-- internal variables
	-- constant OUTPUT_SIZE : unsigned := to_unsigned(4, 32);
	
	-- interfacing variables
	signal vectorA, vectorB, result : uint32_t;
	signal width : uint32_t;
	signal calculate : std_logic;
	
	-- debug
	signal current_dimension_s : uint32_t;
begin

-- userlogic instantiate
vdp: entity work.VectorDotproduct(Behavioral)
	port map (clock, reset, calculate, vectorA, vectorB, result);

	-- process data receive 
	process (clock, rd, wr, reset)
		variable inputA, inputB : uint16_t;
		variable vector_width, current_dimension : uint32_t := (others => '0');
	begin
		current_dimension_s <= current_dimension;
	
		if reset = '1' then
			data_out <= (others => '0');
			calculate <= '0';
			done <= '0';
		else
		-- beginning/end
			if rising_edge(clock) then
				-- variable being set
				-- reverse from big to little endian
				if wr = '1' then
					-- do not calculate, unless accessing vectorB
					calculate <= '0';
					done <= '0';
					
					-- process address of written value
					case to_integer(address_in) is
					-- vector_width
					when 0 =>
						width(31 downto 24) <= data_in;
						done <= '0'; -- recognise this as a new sum
					when 1 =>
						width(23 downto 16) <= data_in;
					when 2 =>
						width(15 downto 8) <= data_in;
					when 3 =>
						width(7 downto 0) <= data_in;
					-- inputA
					when 4 =>
						vectorA(31 downto 24) <= data_in;
					when 5 =>
						vectorA(23 downto 16) <= data_in;
					when 6 =>
						vectorA(15 downto 8) <= data_in;
					when 7 =>
						vectorA(7 downto 0) <= data_in;
					-- inputB
					when 8 =>
						vectorB(31 downto 24) <= data_in;
					when 9 =>
						vectorB(23 downto 16) <= data_in;
					when 10 =>
						vectorB(15 downto 8) <= data_in;
					when 11 =>
						vectorB(7 downto 0) <= data_in;
						calculate  <= '1'; -- trigger calculate high for one clock cycle
						current_dimension := current_dimension + 1;
						if current_dimension = width then
							done <= '1';
							current_dimension := (others => '0');
						end if;
					when others =>
					end case;
						
				elsif rd = '1' then
					calculate <= '0';
				else
					calculate <= '0';
				end if;
				
--				if current_receive_state = idle then
--					-- initiate all required variables
--					current_receive_state <= receiveN; -- begin operation
--					current_dimension := (others => '0');
--					data_out.ready <= '0';
--					data_out.data <= (others => '0');
--					ready <= '1';
--					enable_hwf <= '0';
--					-- done <= '0';
----					elsif current_receive_state = receiveDone then
----						if data_out_done = '1' then
----							current_receive_state <= headerDone;
----						end if;
--				elsif current_receive_state = receiveDone then
--					if data_out_done = '1' then
--						current_receive_state <= sendingResult;
--						data_out.data <= result;
--					end if;
--				elsif current_receive_state = sendingResult then
--					data_out.ready <= '0';
--					if data_out_done = '1' then
--						current_receive_state <= idle;
--					end if;
--									
--				-- respond to incoming data
--				elsif data_in.ready = '1' then
--					done <= '0';
--					ready <= '0';
--					case current_receive_state is
--						when receiveN => 
--							enable_hwf <= '0';
--							vector_width := unsigned(data_in.data);
--							-- reset important counters
--							current_receive_state <= receiveA;
--						when receiveA =>
--							enable_hwf <= '1';
--							
--							vectorA <= unsigned(data_in.data);
--							-- inputA := unsigned(data_in(15 downto 0));
--							current_receive_state <= receiveB;
--							current_dimension := current_dimension + 1;
--							
--							data_clock <= '0';
--						when receiveB =>
--							vectorB <= unsigned(data_in.data);
--							-- inputB := unsigned(data_in(15 downto 0));
--							-- intermediate_result := intermediate_result + inputA * inputB;
--							
--							data_clock <= '1';
--							
--							-- receive another dimension or return
--							if current_dimension = vector_width then
--								current_receive_state <= receiveDone; -- display output
--								done <= '1';
--								data_out.ready <= '1';
--								data_out.data <= OUTPUT_SIZE;
--							else
--								current_receive_state <= receiveA; -- receive another 
--							end if;
--						when others => 
--							current_receive_state <= receiveN;
--							enable_hwf <= '0';
--							current_dimension := (others => '0');
--					end case;
							
--				end if;
			end if;
		end if;
		-- intermediate_result_out <= intermediate_result;
	end process;
	
	
end Behavioral;

