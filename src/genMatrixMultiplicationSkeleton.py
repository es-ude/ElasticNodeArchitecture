#!/usr/bin/env python
import sys

def grabFile(filename):
	for i in file(filename):
		print i[:-1], '\\n\\'

def initial(file):
	file.write("\n\
---------------------------------------------------------------------------------- \n\
-- Company:  \n\
-- Engineer:  \n\
--  \n\
-- Create Date:    10:00:45 12/20/2016  \n\
-- Design Name:  \n\
-- Module Name:    vector_dotproduct - Behavioral  \n\
-- Project Name:  \n\
-- Target Devices:  \n\
-- Tool versions:  \n\
-- Description:  \n\
-- \n\
-- Dependencies:  \n\
-- \n\
-- Revision:  \n\
-- Revision 0.01 - File Created \n\
-- Additional Comments:  \n\
-- \n\
---------------------------------------------------------------------------------- \n\
library IEEE; \n\
use IEEE.STD_LOGIC_1164.ALL; \n\
 \n\
-- Uncomment the following library declaration if using \n\
-- arithmetic functions with Signed or Unsigned values \n\
use IEEE.NUMERIC_STD.ALL; \n\
 \n\
-- Uncomment the following library declaration if instantiating \n\
-- any Xilinx primitives in this code. \n\
--library UNISIM; \n\
--use UNISIM.VComponents.all; \n\
 \n\
library fpgamiddlewarelibs; \n\
use fpgamiddlewarelibs.UserLogicInterface.all; \n\
 \n\
library work; \n\
use work.MatrixMultiplicationPackage.all; \n\
 \n\
 \n\
entity MatrixMultiplicationSkeleton is \n\
	port ( \n\
		-- control interface \n\
		clock				: in std_logic; \n\
		reset				: in std_logic; -- controls functionality (sleep) \n\
		busy				: out std_logic; \n\
		-- done 				: out std_logic; -- done with entire calculation \n\
				\n\
		-- indicate new data or request \n\
		rd					: in std_logic;	-- request a variable \n\
		wr 				: in std_logic; 	-- request changing a variable \n\
		\n\
		-- data interface \n\
		data_in			: in uint8_t; -- std_logic_vector(31 downto 0); \n\
		address_in		: in uint16_t; \n\
		data_out			: out uint8_t; -- std_logic_vector(31 downto 0) \n\
		\n\
		-- trigger a calculation \n\
		calculate_out	: out std_logic; \n\
		\n\
		debug				: out uint8_t \n\
	); \n\
end MatrixMultiplicationSkeleton; \n\
 \n\
architecture Behavioral of MatrixMultiplicationSkeleton is \n\
	-- signal inputA, inputB : unsigned(31 downto 0); \n\
--	type receive_state is (idle, receiveA, receiveB, receiveDone, calculating, sendResult); \n\
--	signal intermediate_result_s : outputMatrix; \n\
	signal inputA : inputMatrix1; \n\
	signal inputB : inputMatrix2; \n\
	signal result : outputMatrix; \n\
--	\n\
	signal calculate: std_logic; \n\
--	\n\
--	constant OUTPUT_SIZE : unsigned := to_unsigned((numrows1 * numcols2) * 4, 32); \n\
--	\n\
	-- debug \n\
	signal row1_s, row2_s, column1_s, column2_s : integer; \n\
	signal busy_s : std_logic; \n\
	-- signal reset, mm_done : std_logic := '0'; \n\
begin \n\
 \n\
	\n\
mm: entity work.MatrixMultiplication(Behavioral) \n\
	port map (clock, reset, calculate, busy_s, inputA, inputB, result); \n\
	\n\
	busy <= busy_s; \n\
	calculate_out <= calculate; \n\
	\n\
	-- process data receive  \n\
	process (clock, rd, wr, reset) \n\
--		variable inputA, inputB : uint16_t; \n\
--		variable vector_width, current_dimension : uint32_t := (others => '0'); \n\
		\n\
		variable column2 	: integer range 0 to numcols2 - 1 := 0; \n\
		variable row2		: integer range 0 to numrows2 - 1 := 0; \n\
		variable column1 	: integer range 0 to numcols1 - 1 := 0; \n\
		variable row1		: integer range 0 to numrows1 - 1 := 0; \n\
		\n\
		\n\
		variable byte : integer range 0 to 3; \n\
		variable value : integer range 0 to (numcols2 * numrows2 + numcols1 * numrows1 - 1); \n\
		variable parameter : integer range 0 to 1; -- which parameter does it belong to \n\
	begin \n\
		\n\
		if reset = '1' then \n\
			data_out <= (others => '0'); \n\
			calculate <= '0'; \n\
			-- done <= '0'; \n\
		else \n\
		-- beginning/end \n\
			if rising_edge(clock) then \n\
				-- process address of written value \n\
				\n\
				calculate <= '0'; -- set to not calculate (can be overwritten below) \n\
				\n\
				if wr = '0' or rd = '0' then \n\
					value := to_integer(address_in) / 4; \n\
					-- first parameter \n\
					if value < numcols1 * numrows1 then \n\
						parameter := 0; \n\
						row1 := value / numcols1; \n\
						column1 := value - (row1 * numcols1); \n\
					-- second parameter \n\
					else \n\
						parameter := 1; \n\
					end if; \n\
					\n\
 					row1_s <= row1; \n\
					row2_s <= row2; \n\
					column1_s <= column1; \n\
					column2_s <= column2; \n\
					\n\
					-- variable being set \n\
					-- reverse from big to little endian \n\
					if wr = '0' then \n\
						case to_integer(address_in) is\n ")


def middle(X, file):
	# write
	#inputa
	for i in range(X):
		file.write("\t\t\t\t\t\twhen {} =>\n".format((i) * 2 + 0))
		file.write( "\t\t\t\t\t\t\tinputA(0)({})(7 downto 0) <= data_in;\n".format((i) + 0))
		file.write( "\t\t\t\t\t\twhen {} =>\n".format((i) * 2 + 1))
		file.write( "\t\t\t\t\t\t\tinputA(0)({})(15 downto 8) <= data_in;\n".format((i) + 0))
	#inputb
	for i in range(X):
		file.write("\t\t\t\t\t\twhen {} =>\n".format(X * 2 + (i) * 2 + 0))
		file.write( "\t\t\t\t\t\t\tinputB({})(0)(7 downto 0) <= data_in;\n".format((i) + 0))
		file.write( "\t\t\t\t\t\twhen {} =>\n".format(X * 2 + (i) * 2 + 1))
		file.write( "\t\t\t\t\t\t\tinputB({})(0)(15 downto 8) <= data_in;\n".format((i) + 0))
	file.write( "\t\t\t\t\t\twhen 107 =>\n")
	file.write( "\t\t\t\t\t\t\tcalculate <= '1';\n")
	file.write( "\t\t\t\t\t\twhen others =>\n")
	file.write( "\t\t\t\t\t\tend case;\n")
	
	file.write("\
					elsif rd = '0' then\n\
						calculate <= '0';\n\
						case to_integer(address_in) is\n")

	# read
	file.write("\t\t\t\t\t\twhen {} =>\n".format(108 + 0))
	file.write( "\t\t\t\t\t\t\tdata_out <= result(0)(0)(7 downto 0);\n")
	file.write("\t\t\t\t\t\twhen {} =>\n".format(108 + 1))
	file.write( "\t\t\t\t\t\t\tdata_out <= result(0)(0)(15 downto 8);\n")
	file.write("\t\t\t\t\t\twhen {} =>\n".format(108 + 2))
	file.write( "\t\t\t\t\t\t\tdata_out <= result(0)(0)(23 downto 16);\n")
	file.write("\t\t\t\t\t\twhen {} =>\n".format(108 + 3))
	file.write( "\t\t\t\t\t\t\tdata_out <= result(0)(0)(31 downto 24);\n")
	file.write( "\t\t\t\t\t\twhen others =>\n")

	# example = "\
	# 					when 0 => \
	# 						inputA(0)(0)(7 downto 0) <= data_in; \
	# 					when 107 => \
	# 						-- do not calculate, unless accessing vectorB \
	# 						calculate  <= '1'; -- trigger calculate high for one clock cycle \
	# 					when others => "

def final(file):
	file.write( "\n\
						end case; \n\
					else \n\
						calculate <= '0'; \n\
					end if; \n\
				end if; \n\
			end if; \n\
		end if; \n\
		-- intermediate_result_out <= intermediate_result; \n\
	end process; \n\
end Behavioral; \n\
 \n")
	file.close()

def package(X, file):
	data = "\
--package definition. \n\
library IEEE; \n\
use IEEE.STD_LOGIC_1164.all; \n\
use ieee.numeric_std.all; \n\
 \n\
library fpgamiddlewarelibs; \n\
use fpgamiddlewarelibs.UserLogicInterface.all; \n\
 \n\
package MatrixMultiplicationPackage is \n\
 \n\
-- size parameters \n\
constant X : integer := {}; \n\
constant numcols1 : integer := X; \n\
constant numrows1 : integer := 1; \n\
constant numcols2 : integer := 1; \n\
constant numrows2 : integer := X; \n\
 \n\
 \n\
-- input and output types definitions \n\
type t11 is array (0 to numcols1-1) of uint16_t; \n\
type inputMatrix1 is array (0 to numrows1-1) of t11;       \n\
type t22 is array (0 to numcols2-1) of uint16_t;    \n\
type inputMatrix2 is array (0 to numrows2-1) of t22;  \n\
type t33 is array (0 to numcols2-1) of uint32_t;    \n\
type outputMatrix is array (0 to numrows1-1) of t33;   \n\
 \n\
end MatrixMultiplicationPackage; \n\
 \n\
package body MatrixMultiplicationPackage is \n\
 \n\
end MatrixMultiplicationPackage; ".format(X)
	file.write(data)
	file.close()

if __name__ == '__main__':

	# grabFile('MatrixMultiplicationPackage.vhd')
	print sys.argv
	X = int(sys.argv[-1])

	print 'creating package and skeleton for X = {}'.format(X)
	package(X, open('../src/MatrixMultiplicationPackage.vhd', 'w'));
	skeleton = open('../src/MatrixMultiplicationSkeleton.vhd', 'w')
	initial(skeleton)
	middle(X, skeleton)
	final(skeleton)	
