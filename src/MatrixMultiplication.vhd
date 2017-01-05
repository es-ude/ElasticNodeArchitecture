--package definition.
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


package MatrixMultiplicationPackage is

	--numcols3 : integer := 5;
	--numrows3 : integer := 4;

-- size parameters
constant numcols1 : integer := 3;
constant numrows1 : integer := 4;
constant numcols2 : integer := 5;
constant numrows2 : integer := 3;


-- input and output types definitions
type t11 is array (0 to numcols1-1) of unsigned(15 downto 0);
type inputMatrix1 is array (0 to numrows1-1) of t11;      
type t22 is array (0 to numcols2-1) of unsigned(15 downto 0);   
type inputMatrix2 is array (0 to numrows2-1) of t22; 
type t33 is array (0 to numcols2-1) of unsigned(31 downto 0);   
type outputMatrix is array (0 to numrows1-1) of t33;  

-- function matmul ( a : inputMatrix1; b:inputMatrix2 ) return outputMatrix;

end MatrixMultiplicationPackage;

package body MatrixMultiplicationPackage is

--function  matmul  ( a : inputMatrix1; b:inputMatrix2 ) return outputMatrix is
--
--variable i,j,k : integer:=0;
--variable prod : outputMatrix := (others => (others => (others => '0')));
--
--begin
--
--	for i in 0 to numrows1-1 loop
--		for j in 0 to numcols2-1 loop
--			for k in 0 to numcols1-1 loop
--				prod(i)(j) := prod(i)(j) + (a(i)(k) * b(k)(j));
--			end loop;
--		end loop;
--	end loop;
--	return prod;
--
--end matmul;

end MatrixMultiplicationPackage;
