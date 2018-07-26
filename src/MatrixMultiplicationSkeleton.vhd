
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
		reset				: in std_logic; -- controls functionality (sleep) 
		busy				: out std_logic; 
		-- done 				: out std_logic; -- done with entire calculation 
				
		-- indicate new data or request 
		rd					: in std_logic;	-- request a variable 
		wr 				: in std_logic; 	-- request changing a variable 
		
		-- data interface 
		data_in			: in uint8_t; -- std_logic_vector(31 downto 0); 
		address_in		: in uint16_t; 
		data_out			: out uint8_t; -- std_logic_vector(31 downto 0) 
		
		-- trigger a calculation 
		calculate_out	: out std_logic; 
		
		debug				: out uint8_t 
	); 
end MatrixMultiplicationSkeleton; 
 
architecture Behavioral of MatrixMultiplicationSkeleton is 
	-- signal inputA, inputB : unsigned(31 downto 0); 
--	type receive_state is (idle, receiveA, receiveB, receiveDone, calculating, sendResult); 
--	signal intermediate_result_s : outputMatrix; 
	signal inputA : inputMatrix1; 
	signal inputB : inputMatrix2; 
	signal result : outputMatrix; 
--	
	signal calculate: std_logic; 
--	
--	constant OUTPUT_SIZE : unsigned := to_unsigned((numrows1 * numcols2) * 4, 32); 
--	
	-- debug 
	signal row1_s, row2_s, column1_s, column2_s : integer; 
	signal busy_s : std_logic; 
	-- signal reset, mm_done : std_logic := '0'; 
begin 
 
	
mm: entity work.MatrixMultiplication(Behavioral) 
	port map (clock, reset, calculate, busy_s, inputA, inputB, result); 
	
	busy <= busy_s; 
	calculate_out <= calculate; 
	
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
 						when 107 =>
							calculate <= '1';
						when others =>
						end case;
					elsif rd = '0' then
						calculate <= '0';
						case to_integer(address_in) is
						when 108 =>
							data_out <= result(0)(0)(7 downto 0);
						when 109 =>
							data_out <= result(0)(0)(15 downto 8);
						when 110 =>
							data_out <= result(0)(0)(23 downto 16);
						when 111 =>
							data_out <= result(0)(0)(31 downto 24);
						when others =>

						end case; 
					else 
						calculate <= '0'; 
					end if; 
				end if; 
			end if; 
		end if; 
		-- intermediate_result_out <= intermediate_result; 
	end process; 
end Behavioral; 
 
