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
						-- inputA
						-- row 1
						when 0 =>
							inputA(0)(0)(7 downto 0) <= data_in;
							-- done <= '0'; -- recognise this as a new sum
						when 1 =>
							inputA(0)(0)(15 downto 8) <= data_in;
						-- ignore (31 downto 16)
--						when 2 =>
--							inputA(0)(0)(23 downto 16) <= data_in;
--						when 3 =>
--							inputA(0)(0)(31 downto 24) <= data_in;
						when 4 =>
							inputA(0)(1)(7 downto 0) <= data_in;
						when 5 =>
							inputA(0)(1)(15 downto 8) <= data_in;
						when 8 =>
							inputA(0)(2)(7 downto 0) <= data_in;
						when 9 =>
							inputA(0)(2)(15 downto 8) <= data_in;
						-- row 2
						when 12 =>
							inputA(1)(0)(7 downto 0) <= data_in;
						when 13 =>
							inputA(1)(0)(15 downto 8) <= data_in;
						when 16 =>
							inputA(1)(1)(7 downto 0) <= data_in;
						when 17 =>
							inputA(1)(1)(15 downto 8) <= data_in;
						when 20 =>
							inputA(1)(2)(7 downto 0) <= data_in;
						when 21 =>
							inputA(1)(2)(15 downto 8) <= data_in;
						-- row 3
						when 24 =>
							inputA(2)(0)(7 downto 0) <= data_in;
						when 25 =>
							inputA(2)(0)(15 downto 8) <= data_in;
						when 28 =>
							inputA(2)(1)(7 downto 0) <= data_in;
						when 29 =>
							inputA(2)(1)(15 downto 8) <= data_in;
						when 32 =>
							inputA(2)(2)(7 downto 0) <= data_in;
						when 33 =>
							inputA(2)(2)(15 downto 8) <= data_in;
						-- row 4
						when 36 =>
							inputA(3)(0)(7 downto 0) <= data_in;
						when 37 =>
							inputA(3)(0)(15 downto 8) <= data_in;
						when 40 =>
							inputA(3)(1)(7 downto 0) <= data_in;
						when 41 =>
							inputA(3)(1)(15 downto 8) <= data_in;
						when 44 =>
							inputA(3)(2)(7 downto 0) <= data_in;
						when 45 =>
							inputA(3)(2)(15 downto 8) <= data_in;
						
						-- inputB
						-- row 1
						when 48 =>
							inputB(0)(0)(7 downto 0) <= data_in;
						when 49 =>
							inputB(0)(0)(15 downto 8) <= data_in;
						when 52 =>
							inputB(0)(1)(7 downto 0) <= data_in;
						when 53 =>
							inputB(0)(1)(15 downto 8) <= data_in;
						when 56 =>
							inputB(0)(2)(7 downto 0) <= data_in;
						when 57 =>
							inputB(0)(2)(15 downto 8) <= data_in;							
						when 60 =>
							inputB(0)(3)(7 downto 0) <= data_in;
						when 61 =>
							inputB(0)(3)(15 downto 8) <= data_in;
						when 64 =>
							inputB(0)(4)(7 downto 0) <= data_in;
						when 65 =>
							inputB(0)(4)(15 downto 8) <= data_in;	
						-- row 2
						when 68 =>
							inputB(1)(0)(7 downto 0) <= data_in;
						when 69 =>
							inputB(1)(0)(15 downto 8) <= data_in;
						when 72 =>
							inputB(1)(1)(7 downto 0) <= data_in;
						when 73 =>
							inputB(1)(1)(15 downto 8) <= data_in;
						when 76 =>
							inputB(1)(2)(7 downto 0) <= data_in;
						when 77 =>
							inputB(1)(2)(15 downto 8) <= data_in;							
						when 80 =>
							inputB(1)(3)(7 downto 0) <= data_in;
						when 81 =>
							inputB(1)(3)(15 downto 8) <= data_in;
						when 84 =>
							inputB(1)(4)(7 downto 0) <= data_in;
						when 85 =>
							inputB(1)(4)(15 downto 8) <= data_in;	
						-- row 3
						when 88 =>
							inputB(2)(0)(7 downto 0) <= data_in;
						when 89 =>
							inputB(2)(0)(15 downto 8) <= data_in;
						when 92 =>
							inputB(2)(1)(7 downto 0) <= data_in;
						when 93 =>
							inputB(2)(1)(15 downto 8) <= data_in;
						when 96 =>
							inputB(2)(2)(7 downto 0) <= data_in;
						when 97 =>
							inputB(2)(2)(15 downto 8) <= data_in;							
						when 100 =>
							inputB(2)(3)(7 downto 0) <= data_in;
						when 101 =>
							inputB(2)(3)(15 downto 8) <= data_in;
						when 104 =>
							inputB(2)(4)(7 downto 0) <= data_in;
						when 105 =>
							inputB(2)(4)(15 downto 8) <= data_in;	
						
						when 107 =>
							-- do not calculate, unless accessing vectorB
							calculate  <= '1'; -- trigger calculate high for one clock cycle
						when others =>
						end case;
					elsif rd = '0' then
						calculate <= '0';
						case to_integer(address_in) is
						-- inputA
						-- row 1
						when 0 =>
							data_out <= inputA(0)(0)(7 downto 0);
							-- done <= '0'; -- recognise this as a new sum
						when 1 =>
							data_out <= inputA(0)(0)(15 downto 8);
						-- ignore (31 downto 16)
--						when 2 =>
--							data_out <= inputA(0)(0)(23 downto 16);
--						when 3 =>
--							data_out <= inputA(0)(0)(31 downto 24);
						when 4 =>
							data_out <= inputA(0)(1)(7 downto 0);
						when 5 =>
							data_out <= inputA(0)(1)(15 downto 8);
						when 8 =>
							data_out <= inputA(0)(2)(7 downto 0);
						when 9 =>
							data_out <= inputA(0)(2)(15 downto 8);
						-- row 2
						when 12 =>
							data_out <= inputA(1)(0)(7 downto 0);
						when 13 =>
							data_out <= inputA(1)(0)(15 downto 8);
						when 16 =>
							data_out <= inputA(1)(1)(7 downto 0);
						when 17 =>
							data_out <= inputA(1)(1)(15 downto 8);
						when 20 =>
							data_out <= inputA(1)(2)(7 downto 0);
						when 21 =>
							data_out <= inputA(1)(2)(15 downto 8);
						-- row 3
						when 24 =>
							data_out <= inputA(2)(0)(7 downto 0);
						when 25 =>
							data_out <= inputA(2)(0)(15 downto 8);
						when 28 =>
							data_out <= inputA(2)(1)(7 downto 0);
						when 29 =>
							data_out <= inputA(2)(1)(15 downto 8);
						when 32 =>
							data_out <= inputA(2)(2)(7 downto 0);
						when 33 =>
							data_out <= inputA(2)(2)(15 downto 8);
						-- row 4
						when 36 =>
							data_out <= inputA(3)(0)(7 downto 0);
						when 37 =>
							data_out <= inputA(3)(0)(15 downto 8);
						when 40 =>
							data_out <= inputA(3)(1)(7 downto 0);
						when 41 =>
							data_out <= inputA(3)(1)(15 downto 8);
						when 44 =>
							data_out <= inputA(3)(2)(7 downto 0);
						when 45 =>
							data_out <= inputA(3)(2)(15 downto 8);
						
						-- inputB
						-- row 1
						when 48 =>
							data_out <= inputB(0)(0)(7 downto 0);
						when 49 =>
							data_out <= inputB(0)(0)(15 downto 8);
						when 52 =>
							data_out <= inputB(0)(1)(7 downto 0);
						when 53 =>
							data_out <= inputB(0)(1)(15 downto 8);
						when 56 =>
							data_out <= inputB(0)(2)(7 downto 0);
						when 57 =>
							data_out <= inputB(0)(2)(15 downto 8);							
						when 60 =>
							data_out <= inputB(0)(3)(7 downto 0);
						when 61 =>
							data_out <= inputB(0)(3)(15 downto 8);
						when 64 =>
							data_out <= inputB(0)(4)(7 downto 0);
						when 65 =>
							data_out <= inputB(0)(4)(15 downto 8);	
						-- row 2
						when 68 =>
							data_out <= inputB(1)(0)(7 downto 0);
						when 69 =>
							data_out <= inputB(1)(0)(15 downto 8);
						when 72 =>
							data_out <= inputB(1)(1)(7 downto 0);
						when 73 =>
							data_out <= inputB(1)(1)(15 downto 8);
						when 76 =>
							data_out <= inputB(1)(2)(7 downto 0);
						when 77 =>
							data_out <= inputB(1)(2)(15 downto 8);							
						when 80 =>
							data_out <= inputB(1)(3)(7 downto 0);
						when 81 =>
							data_out <= inputB(1)(3)(15 downto 8);
						when 84 =>
							data_out <= inputB(1)(4)(7 downto 0);
						when 85 =>
							data_out <= inputB(1)(4)(15 downto 8);	
						-- row 3
						when 88 =>
							data_out <= inputB(2)(0)(7 downto 0);
						when 89 =>
							data_out <= inputB(2)(0)(15 downto 8);
						when 92 =>
							data_out <= inputB(2)(1)(7 downto 0);
						when 93 =>
							data_out <= inputB(2)(1)(15 downto 8);
						when 96 =>
							data_out <= inputB(2)(2)(7 downto 0);
						when 97 =>
							data_out <= inputB(2)(2)(15 downto 8);							
						when 100 =>
							data_out <= inputB(2)(3)(7 downto 0);
						when 101 =>
							data_out <= inputB(2)(3)(15 downto 8);
						when 104 =>
							data_out <= inputB(2)(4)(7 downto 0);
						when 105 =>
							data_out <= inputB(2)(4)(15 downto 8);

						-- result
						-- row 1
						when 108 =>
							data_out <= result(0)(0)(7 downto 0);
						when 109 =>
							data_out <= result(0)(0)(15 downto 8);
						when 110 =>
							data_out <= result(0)(0)(23 downto 16);
						when 111 =>
							data_out <= result(0)(0)(31 downto 24);
						when 112 =>
							data_out <= result(0)(1)(7 downto 0);
						when 113 =>
							data_out <= result(0)(1)(15 downto 8);
						when 114 =>
							data_out <= result(0)(1)(23 downto 16);
						when 115 =>
							data_out <= result(0)(1)(31 downto 24);
						when 116 =>
							data_out <= result(0)(2)(7 downto 0);
						when 117 =>
							data_out <= result(0)(2)(15 downto 8);
						when 118 =>
							data_out <= result(0)(2)(23 downto 16);
						when 119 =>
							data_out <= result(0)(2)(31 downto 24);
						when 120 =>
							data_out <= result(0)(3)(7 downto 0);
						when 121 =>
							data_out <= result(0)(3)(15 downto 8);
						when 122 =>
							data_out <= result(0)(3)(23 downto 16);
						when 123 =>
							data_out <= result(0)(3)(31 downto 24);
						when 124 =>
							data_out <= result(0)(4)(7 downto 0);
						when 125 =>
							data_out <= result(0)(4)(15 downto 8);
						when 126 =>
							data_out <= result(0)(4)(23 downto 16);
						when 127 =>
							data_out <= result(0)(4)(31 downto 24);
						-- row 2
						when 128 =>
							data_out <= result(1)(0)(7 downto 0);
						when 129 =>
							data_out <= result(1)(0)(15 downto 8);
						when 130 =>
							data_out <= result(1)(0)(23 downto 16);
						when 131 =>
							data_out <= result(1)(0)(31 downto 24);
						when 132 =>
							data_out <= result(1)(1)(7 downto 0);
						when 133 =>
							data_out <= result(1)(1)(15 downto 8);
						when 134 =>
							data_out <= result(1)(1)(23 downto 16);
						when 135 =>
							data_out <= result(1)(1)(31 downto 24);
						when 136 =>
							data_out <= result(1)(2)(7 downto 0);
						when 137 =>
							data_out <= result(1)(2)(15 downto 8);
						when 138 =>
							data_out <= result(1)(2)(23 downto 16);
						when 139 =>
							data_out <= result(1)(2)(31 downto 24);
						when 140 =>
							data_out <= result(1)(3)(7 downto 0);
						when 141 =>
							data_out <= result(1)(3)(15 downto 8);
						when 142 =>
							data_out <= result(1)(3)(23 downto 16);
						when 143 =>
							data_out <= result(1)(3)(31 downto 24);
						when 144 =>
							data_out <= result(1)(4)(7 downto 0);
						when 145 =>
							data_out <= result(1)(4)(15 downto 8);
						when 146 =>
							data_out <= result(1)(4)(23 downto 16);
						when 147 =>
							data_out <= result(1)(4)(31 downto 24);
						-- row 3
						when 148 =>
							data_out <= result(2)(0)(7 downto 0);
						when 149 =>
							data_out <= result(2)(0)(15 downto 8);
						when 150 =>
							data_out <= result(2)(0)(23 downto 16);
						when 151 =>
							data_out <= result(2)(0)(31 downto 24);
						when 152 =>
							data_out <= result(2)(1)(7 downto 0);
						when 153 =>
							data_out <= result(2)(1)(15 downto 8);
						when 154 =>
							data_out <= result(2)(1)(23 downto 16);
						when 155 =>
							data_out <= result(2)(1)(31 downto 24);
						when 156 =>
							data_out <= result(2)(2)(7 downto 0);
						when 157 =>
							data_out <= result(2)(2)(15 downto 8);
						when 158 =>
							data_out <= result(2)(2)(23 downto 16);
						when 159 =>
							data_out <= result(2)(2)(31 downto 24);
						when 160 =>
							data_out <= result(2)(3)(7 downto 0);
						when 161 =>
							data_out <= result(2)(3)(15 downto 8);
						when 162 =>
							data_out <= result(2)(3)(23 downto 16);
						when 163 =>
							data_out <= result(2)(3)(31 downto 24);
						when 164 =>
							data_out <= result(2)(4)(7 downto 0);
						when 165 =>
							data_out <= result(2)(4)(15 downto 8);
						when 166 =>
							data_out <= result(2)(4)(23 downto 16);
						when 167 =>
							data_out <= result(2)(4)(31 downto 24);
						-- row 4
						when 168 =>
							data_out <= result(3)(0)(7 downto 0);
						when 169 =>
							data_out <= result(3)(0)(15 downto 8);
						when 170 =>
							data_out <= result(3)(0)(23 downto 16);
						when 171 =>
							data_out <= result(3)(0)(31 downto 24);
						when 172 =>
							data_out <= result(3)(1)(7 downto 0);
						when 173 =>
							data_out <= result(3)(1)(15 downto 8);
						when 174 =>
							data_out <= result(3)(1)(23 downto 16);
						when 175 =>
							data_out <= result(3)(1)(31 downto 24);
						when 176 =>
							data_out <= result(3)(2)(7 downto 0);
						when 177 =>
							data_out <= result(3)(2)(15 downto 8);
						when 178 =>
							data_out <= result(3)(2)(23 downto 16);
						when 179 =>
							data_out <= result(3)(2)(31 downto 24);
						when 180 =>
							data_out <= result(3)(3)(7 downto 0);
						when 181 =>
							data_out <= result(3)(3)(15 downto 8);
						when 182 =>
							data_out <= result(3)(3)(23 downto 16);
						when 183 =>
							data_out <= result(3)(3)(31 downto 24);
						when 184 =>
							data_out <= result(3)(4)(7 downto 0);
						when 185 =>
							data_out <= result(3)(4)(15 downto 8);
						when 186 =>
							data_out <= result(3)(4)(23 downto 16);
						when 187 =>
							data_out <= result(3)(4)(31 downto 24);
						-- status
						when 188 =>
							data_out(0) <= busy_s;
						when others =>
							data_out <= to_unsigned(255, 8) - address_in(7 downto 0) + address_in(15 downto 8);
						end case;
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

