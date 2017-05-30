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

library work;
use work.MatrixMultiplicationPackage.all;


entity MatrixMultiplicationSkeleton is
	port (
		-- control interface
		clock				: in std_logic;
		reset			: in std_logic; -- controls functionality (sleep)
		done 				: out std_logic; -- done with entire calculation
				
		-- indicate new data or request
		rd					: in std_logic;	-- request a variable
		wr 				: in std_logic; 	-- request changing a variable
		
		-- data interface
		data_in			: in uint8_t; -- std_logic_vector(31 downto 0);
		address_in		: in uint16_t;
		data_out			: out uint8_t -- std_logic_vector(31 downto 0)
	);
end MatrixMultiplicationSkeleton;

architecture Behavioral of MatrixMultiplicationSkeleton is
	-- signal inputA, inputB : unsigned(31 downto 0);
--	type receive_state is (idle, receiveA, receiveB, receiveDone, calculating, sendResult);
--	signal intermediate_result_s : outputMatrix;
	signal inputA : inputMatrix1;
	signal inputB : inputMatrix2;
	signal output : outputMatrix;
	
	signal calculate: std_logic;
	
	constant OUTPUT_SIZE : unsigned := to_unsigned((numrows1 * numcols2) * 4, 32);
	
	-- debug
	signal row1_s, row2_s, column1_s, column2_s : integer;
	-- signal reset, mm_done : std_logic := '0';
begin

--uut: entity work.MatrixMultiplication(Behavioral)
--	port map (clock, reset, calculate, done, inputA, inputB, output);

-- process data receive 
	process (clock, rd, wr, reset)
--		variable inputA, inputB : uint16_t;
--		variable vector_width, current_dimension : uint32_t := (others => '0');
		
		variable column2 	: integer range 0 to numcols2 - 1 := 0;
		variable row2		: integer range 0 to numrows2 - 1 := 0;
		variable column1 	: integer range 0 to numcols1 - 1 := 0;
		variable row1		: integer range 0 to numrows1 - 1 := 0;
		
		
		variable byte : integer range 0 to 3;
		variable value : integer range 0 to (numcols2 * numrows2 + numcols1 * numrows1 - 1);
		variable parameter : integer range 0 to 1; -- which parameter does it belong to
	begin
		
		if reset = '1' then
			data_out <= (others => '0');
			calculate <= '0';
			-- done <= '0';
		else
		-- beginning/end
			if rising_edge(clock) then
				-- process address of written value
				
				calculate <= '0'; -- set to not calculate (can be overwritten below)
				
				if wr = '0' or rd = '0' then
					value := to_integer(address_in) / 4;
					-- first parameter
					if value < numcols1 * numrows1 then
						parameter := 0;
						row1 := value / numcols1;
						column1 := value - (row1 * numcols1);
					-- second parameter
					else
						parameter := 1;
					end if;
					
					row1_s <= row1;
					row2_s <= row2;
					column1_s <= column1;
					column2_s <= column2;
					
					-- variable being set
					-- reverse from big to little endian
					if wr = '0' then
						case to_integer(address_in) is
						-- inputA
						when 0 =>
							inputA(0)(0)(7 downto 0) <= data_in;
							-- done <= '0'; -- recognise this as a new sum
						when 1 =>
							inputA(0)(0)(15 downto 8) <= data_in;
						when 2 =>
							inputA(0)(0)(23 downto 16) <= data_in;
						when 3 =>
							inputA(0)(0)(31 downto 24) <= data_in;
						

--							-- do not calculate, unless accessing vectorB
--							calculate  <= '1'; -- trigger calculate high for one clock cycle
--							current_dimension := current_dimension + 1;
--							if current_dimension >= width then
--								-- done <= '1';
--								current_dimension := (others => '0');
--							end if;
						when others =>
						end case;
	--				elsif rd = '0' then
	--					calculate <= '0';
	--					case to_integer(address_in) is
	--					-- vector_width
	--					when 0 =>
	--						data_out <= width(7 downto 0);
	--					when 1 =>
	--						data_out <= width(15 downto 8);
	--					when 2 =>
	--						data_out <= width(23 downto 16);
	--					when 3 =>
	--						data_out <= width(31 downto 24);
	--					-- inputA
	--					when 4 =>
	--						data_out <= vectorA(7 downto 0);
	--					when 5 =>
	--						data_out <= vectorA(15 downto 8);
	--					when 6 =>
	--						data_out <= vectorA(23 downto 16);
	--					when 7 =>
	--						data_out <= vectorA(31 downto 24);
	--					-- inputB
	--					when 8 =>
	--						data_out <= vectorB(7 downto 0);
	--					when 9 =>
	--						data_out <= vectorB(15 downto 8);
	--					when 10 =>
	--						data_out <= vectorB(23 downto 16);
	--					when 11 =>
	--						data_out <= vectorB(31 downto 24);
	--						
	--					-- result
	--					when 12 =>
	--						data_out <= result(7 downto 0);
	--					when 13 =>
	--						data_out <= result(15 downto 8);
	--					when 14 =>
	--						data_out <= result(23 downto 16);
	--					when 15 =>
	--						data_out <= result(31 downto 24);
	--					when others =>
	--						data_out <= to_unsigned(255, 8) - address_in(7 downto 0) + address_in(15 downto 8);
	--					end case;
					else
						calculate <= '0';
					end if;
				end if;
			end if;
		end if;
		-- intermediate_result_out <= intermediate_result;
	end process;
--	-- process data receive 
--	process (clock, enable, data_in.ready, current_receive_state)
--		variable column2 	: integer range 0 to numcols2 - 1 := 0;
--		variable row2		: integer range 0 to numrows2 - 1 := 0;
--		variable column1 	: integer range 0 to numcols1 - 1 := 0;
--		variable row1		: integer range 0 to numrows1 - 1 := 0;
--	
--		-- variable intermediate_result : MatrixMultiplicationPackage.outputMatrix := (others => (others => (others => '0')));
--		variable inputA : inputMatrix1 := (others => (others => (others => '0')));
--		variable inputB : inputMatrix2 := (others => (others => (others => '0')));
--		
--		variable first : boolean := false;
--		variable sendSize : boolean := false;
--	begin
--		if enable = '1' then
--			-- beginning/end
--			-- if run = '1' then
--				if rising_edge(clock) then
--					if current_receive_state = idle then
--						-- initiate all required variables
--						current_receive_state <= receiveA; -- begin operation
--						ready <= '1';
--						data_out.ready <= '0';
--						data_out.data <= (others => '0');
--						-- intermediate_result := (others => (others => (others => '0')));
--						done <= '0';
--						column2 := 0;
--						row2 := 0;
--						
--						column1 := 0;
--						row1 := 0;
--						
--					elsif current_receive_state = receiveDone then
--						data_out.ready <= '0';
--						if data_out_done = '1' then
--							current_receive_state <= idle;
--						end if;
--					-- perform the required calculations
--					elsif current_receive_state = calculating then
--						mm_enable <= '1';
--						
--						if mm_done = '1' then
--							intermediate_result_s <= output_s;
--							current_receive_state <= sendResult;
--							sendSize := true;
--							done <= '1';
--							row1 := 0;
--							column2 := 0;
--						end if;
--					-- respond to incoming data
--					elsif data_in.ready = '1' then
--						case current_receive_state is
--							when receiveA =>
--								ready <= '0';
--								done <= '0';
--							
--								inputA(row1)(column1) := data_in.data(15 downto 0);
--								
--								-- check if next row
--								if column1 < numcols1 - 1 then
--									column1 := column1 + 1;
--								else
--									column1 := 0;
--									
--									if row1 < numrows1 - 1 then
--										row1 := row1 + 1;
--									else
--										current_receive_state <= receiveB;
--										row1 := 0;
--										column1 := 0;
--									end if;
--								end if;								
--							when receiveB =>
--								inputB(row2)(column2) := data_in.data(15 downto 0);
--								
--								if column2 < numcols2 - 1 then
--									column2 := column2 + 1;
--								-- check if next row
--								else
--									column2 := 0;
--									if row2 < numrows2 - 1 then
--										row2 := row2 + 1;
--									else
--										current_receive_state <= calculating;
--										row2 := 0;
--										column2 := 0;
--										row1 := 0;
--									end if;
--								end if;												
--							when others => 
--								current_receive_state <= idle;
--						end case;
--					elsif current_receive_state = sendResult then
--						if sendSize then
--							sendSize := false;
--							data_out.data <= OUTPUT_SIZE;
--							data_out.ready <= '1';
--							-- first := true; -- ensure first datapoint is sent
--							
--						elsif data_out_done = '1' or first then
--							first := false;
--							
--							data_out.data <= intermediate_result_s(row1)(column2);
--							data_out.ready <= '1';
--							
--							-- find next datapoint
--							if column2 < numcols2 - 1 then
--								column2 := column2 + 1;
--							else
--									column2 := 0;
--									if row1 < numrows1 - 1 then
--										row1 := row1 + 1;
--									else
--										current_receive_state <= idle;
--										data_out.ready <= '0';
--										row1 := 0;
--										column2 := 0;
--									end if;
--							end if;
----						else
----							data_out_rdy <= '0';
--						end if;
--					end if;
--				-- end if;
--			end if;
--		else
--			data_out.ready <= '0';
--			data_out.data <= (others => '0');
--			done <= '0';
--			ready <= '0';
--			current_receive_state <= idle;
--			
--			mm_enable <= '0';
--		end if;
--		-- intermediate_result_s <= intermediate_result;
--		inputA_s <= inputA;
--		inputB_s <= inputB;
--	end process;
	
	-- ready <= '1' when enable = '1' and current_receive_state = receiveN else '0';
	-- calculate <= '1' when current_receive_state = calculating else '0';
end Behavioral;

