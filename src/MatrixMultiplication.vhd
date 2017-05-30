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
		reset				: in std_logic;
		calculate		: in std_logic; -- controls functionality (sleep)
		
		done 				: out std_logic; -- done with entire calculation
		
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
	process (clock, current_receive_state)
		variable column2 	: integer range 0 to MatrixMultiplicationPackage.numcols2 - 1 := 0;
		variable row2		: integer range 0 to MatrixMultiplicationPackage.numrows2 - 1 := 0;
		variable column1 	: integer range 0 to MatrixMultiplicationPackage.numcols1 - 1 := 0;
		variable row1		: integer range 0 to MatrixMultiplicationPackage.numrows1 - 1 := 0;
	
		variable intermediate_result : MatrixMultiplicationPackage.outputMatrix := (others => (others => (others => '0')));
	begin
		if calculate = '1' then
			-- beginning/end
			-- if run = '1' then
				if rising_edge(clock) then
					if current_receive_state = idle then
						-- initiate all required variables
						current_receive_state <= calculating; -- begin operation
						intermediate_result := (others => (others => (others => '0')));
						done <= '0';
						column2 := 0;
						row2 := 0;
						
						column1 := 0;
						row1 := 0;

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
							row1 := 0;
							column2 := 0;
						end if;
					elsif current_receive_state = sendResult then
						matrixC <= intermediate_result;
						done <= '1';
					end if;
			end if;
		else
			done <= '0';
			current_receive_state <= idle;
		end if;
		intermediate_result_s <= intermediate_result;
	end process;
end Behavioral;

