library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;
use ieee.numeric_std.all;
library work;
use work.Common.all;

package Sigmoid is
function sigmoid(arg : in fixed_point) return fixed_point;
end Sigmoid;

package body Sigmoid is
	function sigmoid (arg: in fixed_point) return fixed_point is
	   variable ret : integer range -10000 to 10000;
	begin
		if arg < -10000 then
			ret :=  0;
		elsif arg > 10000 then
			ret :=  1024;
		elsif arg >= -10000 and arg < -6767 then
			ret :=  0;
		elsif arg >= -6767 and arg < -6565 then
			ret :=  1;
		elsif arg >= -6565 and arg < -6363 then
			ret :=  1;
		elsif arg >= -6363 and arg < -6161 then
			ret :=  1;
		elsif arg >= -6161 and arg < -5959 then
			ret :=  2;
		elsif arg >= -5959 and arg < -5757 then
			ret := 2;
		elsif arg >= -5757 and arg < -5555 then
			ret := 3;
		elsif arg >= -5555 and arg < -5353 then
			ret := 3;
		elsif arg >= -5353 and arg < -5151 then
			ret := 4;
		elsif arg >= -5151 and arg < -4949 then
			ret := 5;
		elsif arg >= -4949 and arg < -4747 then
			ret := 7;
		elsif arg >= -4747 and arg < -4545 then
			ret := 8;
		elsif arg >= -4545 and arg < -4343 then
			ret := 10;
		elsif arg >= -4343 and arg < -4141 then
			ret := 12;
		elsif arg >= -4141 and arg < -3939 then
			ret := 15;
		elsif arg >= -3939 and arg < -3737 then
			ret := 19;
		elsif arg >= -3737 and arg < -3535 then
			ret := 23;
		elsif arg >= -3535 and arg < -3333 then
			ret := 28;
		elsif arg >= -3333 and arg < -3131 then
			ret := 34;
		elsif arg >= -3131 and arg < -2929 then
			ret := 41;
		elsif arg >= -2929 and arg < -2727 then
			ret := 50;
		elsif arg >= -2727 and arg < -2525 then
			ret := 61;
		elsif arg >= -2525 and arg < -2323 then
			ret := 74;
		elsif arg >= -2323 and arg < -2121 then
			ret := 89;
		elsif arg >= -2121 and arg < -1919 then
			ret := 107;
		elsif arg >= -1919 and arg < -1717 then
			ret := 127;
		elsif arg >= -1717 and arg < -1515 then
			ret := 152;
		elsif arg >= -1515 and arg < -1313 then
			ret := 180;
		elsif arg >= -1313 and arg < -1111 then
			ret := 211;
		elsif arg >= -1111 and arg < -909 then
			ret := 247;
		elsif arg >= -909 and arg < -707 then
			ret := 287;
		elsif arg >= -707 and arg < -505 then
			ret := 330;
		elsif arg >= -505 and arg < -303 then
			ret := 376;
		elsif arg >= -303 and arg < -101 then
			ret := 424;
		elsif arg >= -101 and arg < 101 then
			ret := 474;
		elsif arg >= 101 and arg < 303 then
			ret := 525;
		elsif arg >= 303 and arg < 505 then
			ret := 575;
		elsif arg >= 505 and arg < 707 then
			ret := 623;
		elsif arg >= 707 and arg < 909 then
			ret := 669;
		elsif arg >= 909 and arg < 1111 then
			ret := 712;
		elsif arg >= 1111 and arg < 1313 then
			ret := 752;
		elsif arg >= 1313 and arg < 1515 then
			ret := 788;
		elsif arg >= 1515 and arg < 1717 then
			ret := 819;
		elsif arg >= 1717 and arg < 1919 then
			ret := 847;
		elsif arg >= 1919 and arg < 2121 then
			ret := 872;
		elsif arg >= 2121 and arg < 2323 then
			ret := 892;
		elsif arg >= 2323 and arg < 2525 then
			ret := 910;
		elsif arg >= 2525 and arg < 2727 then
			ret := 925;
		elsif arg >= 2727 and arg < 2929 then
			ret := 938;
		elsif arg >= 2929 and arg < 3131 then
			ret := 949;
		elsif arg >= 3131 and arg < 3333 then
			ret := 958;
		elsif arg >= 3333 and arg < 3535 then
			ret := 965;
		elsif arg >= 3535 and arg < 3737 then
			ret := 971;
		elsif arg >= 3737 and arg < 3939 then
			ret := 976;
		elsif arg >= 3939 and arg < 4141 then
			ret := 980;
		elsif arg >= 4141 and arg < 4343 then
			ret := 984;
		elsif arg >= 4343 and arg < 4545 then
			ret := 987;
		elsif arg >= 4545 and arg < 4747 then
			ret := 989;
		elsif arg >= 4747 and arg < 4949 then
			ret := 991;
		elsif arg >= 4949 and arg < 5151 then
			ret := 992;
		elsif arg >= 5151 and arg < 5353 then
			ret := 994;
		elsif arg >= 5353 and arg < 5555 then
			ret := 995;
		elsif arg >= 5555 and arg < 5757 then
			ret := 996;
		elsif arg >= 5757 and arg < 5959 then
			ret := 996;
		elsif arg >= 5959 and arg < 6161 then
			ret := 997;
		elsif arg >= 6161 and arg < 6363 then
			ret := 997;
		elsif arg >= 6363 and arg < 6565 then
			ret := 998;
		elsif arg >= 6565 and arg < 6767 then
			ret := 998;
		elsif arg >= 6767 and arg < 6969 then
			ret := 998;
		elsif arg >= 9797 and arg < 10000 then
			ret := 999;
		else
			ret := 1000;
		end if;
		return to_signed(ret, fixed_point'length);
	end sigmoid;
end Sigmoid;
