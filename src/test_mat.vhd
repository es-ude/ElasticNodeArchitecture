library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.mat_ply.all;

entity test_mat is
	port (
		clk : in std_logic;
		a : in array1;
		b : in array2;
		prod : out array3
	);
end test_mat;

architecture Behavioral of test_mat is
begin
	process(clk)
	begin
		if rising_edge(clk) then
			prod <= matmul(a,b); --function is called here.
		end if;
	end process;
end Behavioral;