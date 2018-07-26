--package definition. 
library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all; 
 
library fpgamiddlewarelibs; 
use fpgamiddlewarelibs.UserLogicInterface.all; 
 
package MatrixMultiplicationPackage is 
 
-- size parameters 
constant X : integer := 0; 
constant numcols1 : integer := X; 
constant numrows1 : integer := 1; 
constant numcols2 : integer := 1; 
constant numrows2 : integer := X; 
 
 
-- input and output types definitions 
type t11 is array (0 to numcols1-1) of uint16_t; 
type inputMatrix1 is array (0 to numrows1-1) of t11;       
type t22 is array (0 to numcols2-1) of uint16_t;    
type inputMatrix2 is array (0 to numrows2-1) of t22;  
type t33 is array (0 to numcols2-1) of uint32_t;    
type outputMatrix is array (0 to numrows1-1) of t33;   
 
end MatrixMultiplicationPackage; 
 
package body MatrixMultiplicationPackage is 
 
end MatrixMultiplicationPackage; 