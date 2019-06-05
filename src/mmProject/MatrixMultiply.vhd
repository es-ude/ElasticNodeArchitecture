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
use work.MatrixMultiplicationPackage;


entity MatrixMultiplication is
	port (
	--port map (clock, enable, data_out_rdy, matrixA, matrixB, matrixC);
		-- control interface
		clock				: in std_logic;
		enable			: in std_logic; -- controls functionality (sleep)
		-- run				: in std_logic; -- indicates the beginning and end
		-- ready 			: out std_logic; -- new transmission may begin
		-- done 				: out std_logic; -- done with entire calculation
		
		-- data control interface
		data_out_rdy	: out std_logic;
		
		-- data interface
		matrixA			: in MatrixMultiplicationPackage.inputMatrix1;
		matrixB			: in MatrixMultiplicationPackage.inputMatrix2;
		matrixC			: out MatrixMultiplicationPackage.outputMatrix
	);
end MatrixMultiplication;

architecture Behavioral of MatrixMultiplication is
	-- signal inputA, inputB : unsigned(31 downto 0);
	type receive_state is (idle, calculating, sendResult);
	signal current_receive_state : receive_state := idle;
	signal intermediate_result_s : MatrixMultiplicationPackage.outputMatrix;
	
	-- constant OUTPUT_SIZE : unsigned := to_unsigned((MatrixMultiplicationPackage.numrows1 * MatrixMultiplicationPackage.numcols2) * 4, 32);
begin

	-- process data receive 
	process (clock, enable, current_receive_state)
		variable column2 	: integer range 0 to MatrixMultiplicationPackage.numcols2 - 1 := 0;
		variable row2		: integer range 0 to MatrixMultiplicationPackage.numrows2 - 1 := 0;
		variable column1 	: integer range 0 to MatrixMultiplicationPackage.numcols1 - 1 := 0;
		variable row1		: integer range 0 to MatrixMultiplicationPackage.numrows1 - 1 := 0;
	
		variable intermediate_result : MatrixMultiplicationPackage.outputMatrix := (others => (others => (others => '0')));
		-- variable inputA : MatrixMultiplicationPackage.inputMatrix1 := (others => (others => (others => '0')));
		-- variable inputB : MatrixMultiplicationPackage.inputMatrix2 := (others => (others => (others => '0')));
		
		-- variable first : boolean := false;
		-- variable sendSize : boolean := false;
	begin
		if enable = '1' then
			-- beginning/end
			-- if run = '1' then
				if rising_edge(clock) then
					if current_receive_state = idle then
						-- initiate all required variables
						current_receive_state <= calculating; -- begin operation
						-- ready <= '1';
						data_out_rdy <= '0';
						-- data_out <= (others => '0');
						intermediate_result := (others => (others => (others => '0')));
						-- done <= '0';
						column2 := 0;
						row2 := 0;
						
						column1 := 0;
						row1 := 0;
						
--					elsif current_receive_state = receiveDone then
--						data_out_rdy <= '0';
--						if data_out_done = '1' then
--							current_receive_state <= idle;
--						end if;
					-- perform the required calculations
					elsif current_receive_state = calculating then
						
						--for row1 in 0 to MatrixMultiplicationPackage.numrows1-1 loop
							for column2 in 0 to MatrixMultiplicationPackage.numcols2-1 loop
								for column1 in 0 to MatrixMultiplicationPackage.numcols1-1 loop
									intermediate_result(row1)(column2) := intermediate_result(row1)(column2) + (matrixA(row1)(column1) * matrixB(column1)(column2));
								end loop;
							end loop;
						-- end loop;
						
						
						if row1 < (MatrixMultiplicationPackage.numrows1 - 1) then 
							row1 := row1 + 1;
						else
							current_receive_state <= sendResult;
							-- sendSize := true;
							-- done <= '1';
							row1 := 0;
							column2 := 0;
						end if;
					-- respond to incoming data
--					elsif data_in_rdy = '1' then
--						case current_receive_state is
--							when receiveA =>
--								ready <= '0';
--								done <= '0';
--							
--								inputA(row1)(column1) := unsigned(data_in(15 downto 0));
--								
--								-- check if next row
--								if column1 < MatrixMultiplicationPackage.numcols1 - 1 then
--									column1 := column1 + 1;
--								else
--									column1 := 0;
--									
--									if row1 < MatrixMultiplicationPackage.numrows1 - 1 then
--										row1 := row1 + 1;
--									else
--										current_receive_state <= receiveB;
--										row1 := 0;
--										column1 := 0;
--									end if;
--								end if;								
--							when receiveB =>
--								inputB(row2)(column2) := unsigned(data_in(15 downto 0));
--								
--								if column2 < MatrixMultiplicationPackage.numcols2 - 1 then
--									column2 := column2 + 1;
--								-- check if next row
--								else
--									column2 := 0;
--									if row2 < MatrixMultiplicationPackage.numrows2 - 1 then
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
					elsif current_receive_state = sendResult then
						matrixC <= intermediate_result;
						data_out_rdy <= '1';
--						if sendSize then
--							sendSize := false;
--							data_out <= std_logic_vector(OUTPUT_SIZE);
--							data_out_rdy <= '1';
--							-- first := true; -- ensure first datapoint is sent
--							
--						elsif data_out_done = '1' or first then
--							first := false;
--							
--							data_out <= std_logic_vector(intermediate_result(row1)(column2));
--							data_out_rdy <= '1';
--							
--							-- find next datapoint
--							if column2 < MatrixMultiplicationPackage.numcols2 - 1 then
--								column2 := column2 + 1;
--							else
--									column2 := 0;
--									if row1 < MatrixMultiplicationPackage.numrows1 - 1 then
--										row1 := row1 + 1;
--									else
--										current_receive_state <= idle;
--										data_out_rdy <= '0';
--										row1 := 0;
--										column2 := 0;
--									end if;
--							end if;
--						else
--							data_out_rdy <= '0';
						--end if;
					end if;
				-- end if;
			end if;
		else
			data_out_rdy <= '0';
			-- data_out <= (others => '0');
			-- done <= '0';
			-- ready <= '0';
			current_receive_state <= idle;
		end if;
		intermediate_result_s <= intermediate_result;
		-- inputA_s <= inputA;
		-- inputB_s <= inputB;
	end process;
	
	-- ready <= '1' when enable = '1' and current_receive_state = receiveN else '0';
	-- calculate <= '1' when current_receive_state = calculating else '0';
end Behavioral;

