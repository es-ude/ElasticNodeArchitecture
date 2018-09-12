library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.Common.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;


entity Sigmoid is
port (
	arg 	: in fixed_point;
	ret 	: out fixed_point
);
end Sigmoid;

architecture Behavioral of Sigmoid is
	begin
	process (arg) is
	begin
		if arg < -4096 then
			ret <= to_fixed_point(100);
		elsif arg > 4096 then
			ret <= to_fixed_point(924);
		elsif arg > to_fixed_point(-4095) and arg <= to_fixed_point(-3051) then
			ret <= to_fixed_point(0);
		elsif arg > to_fixed_point(-3051) and arg <= to_fixed_point(-1808) then
			ret <= to_fixed_point(100);
		elsif arg > to_fixed_point(-1808) and arg <= to_fixed_point(-1159) then
			ret <= to_fixed_point(200);
		elsif arg > to_fixed_point(-1159) and arg <= to_fixed_point(-673) then
			ret <= to_fixed_point(300);
		elsif arg > to_fixed_point(-673) and arg <= to_fixed_point(-251) then
			ret <= to_fixed_point(400);
		elsif arg > to_fixed_point(-251) and arg <= to_fixed_point(151) then
			ret <= to_fixed_point(500);
		elsif arg > to_fixed_point(151) and arg <= to_fixed_point(564) then
			ret <= to_fixed_point(600);
		elsif arg > to_fixed_point(564) and arg <= to_fixed_point(1029) then
			ret <= to_fixed_point(700);
		elsif arg > to_fixed_point(1029) and arg <= to_fixed_point(1621) then
			ret <= to_fixed_point(800);
		elsif arg > to_fixed_point(1621) and arg <= to_fixed_point(2607) then
			ret <= to_fixed_point(900);
		elsif arg > to_fixed_point(2607) and arg <= to_fixed_point(4095) then
			ret <= to_fixed_point(1000);
		else
			ret <= factor;
		end if;
	end process;
end Behavioral;
