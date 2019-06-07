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
		if arg <= -4095 then
			ret <= to_fixed_point(0);
--		elsif arg >= 4096 then
--			ret <= to_fixed_point(924);
		elsif arg > to_fixed_point(-4095) and arg <= to_fixed_point(-3040) then
			ret <= to_fixed_point(0);
		elsif arg > to_fixed_point(-3040) and arg <= to_fixed_point(-1804) then
			ret <= to_fixed_point(100);
		elsif arg > to_fixed_point(-1804) and arg <= to_fixed_point(-1157) then
			ret <= to_fixed_point(200);
		elsif arg > to_fixed_point(-1157) and arg <= to_fixed_point(-671) then
			ret <= to_fixed_point(300);
		elsif arg > to_fixed_point(-671) and arg <= to_fixed_point(-249) then
			ret <= to_fixed_point(400);
		elsif arg > to_fixed_point(-249) and arg <= to_fixed_point(153) then
			ret <= to_fixed_point(500);
		elsif arg > to_fixed_point(153) and arg <= to_fixed_point(566) then
			ret <= to_fixed_point(600);
		elsif arg > to_fixed_point(566) and arg <= to_fixed_point(1032) then
			ret <= to_fixed_point(700);
		elsif arg > to_fixed_point(1032) and arg <= to_fixed_point(1625) then
			ret <= to_fixed_point(800);
		elsif arg > to_fixed_point(1625) and arg <= to_fixed_point(2614) then
			ret <= to_fixed_point(900);
		elsif arg > to_fixed_point(2614) and arg <= to_fixed_point(4095) then
			ret <= to_fixed_point(1000);
		else
			ret <= factor;
		end if;
	end process;
end Behavioral;
