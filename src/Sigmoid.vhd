library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.Common.all;

package Sigmoid is
function sigmoid(arg : in fixed_point) return fixed_point;
end Sigmoid;

package body Sigmoid is
	function sigmoid (arg: in fixed_point) return fixed_point is
		variable ret : fixed_point;
	begin
		if arg < to_signed(-4096, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg > to_signed(4096, fixed_point'length) then
			ret := to_signed(1019, fixed_point'length);
		elsif arg >= to_signed(-4096, fixed_point'length) and arg < to_signed(-4096, fixed_point'length) then
			ret := to_signed(23, fixed_point'length);
		elsif arg >= to_signed(-4096, fixed_point'length) and arg < to_signed(-3185, fixed_point'length) then
			ret := to_signed(48, fixed_point'length);
		elsif arg >= to_signed(-3185, fixed_point'length) and arg < to_signed(-2275, fixed_point'length) then
			ret := to_signed(104, fixed_point'length);
		elsif arg >= to_signed(-2275, fixed_point'length) and arg < to_signed(-1365, fixed_point'length) then
			ret := to_signed(217, fixed_point'length);
		elsif arg >= to_signed(-1365, fixed_point'length) and arg < to_signed(-455, fixed_point'length) then
			ret := to_signed(401, fixed_point'length);
		elsif arg >= to_signed(-455, fixed_point'length) and arg < to_signed(455, fixed_point'length) then
			ret := to_signed(623, fixed_point'length);
		elsif arg >= to_signed(455, fixed_point'length) and arg < to_signed(1365, fixed_point'length) then
			ret := to_signed(807, fixed_point'length);
		elsif arg >= to_signed(1365, fixed_point'length) and arg < to_signed(2275, fixed_point'length) then
			ret := to_signed(920, fixed_point'length);
		elsif arg >= to_signed(2275, fixed_point'length) and arg < to_signed(3185, fixed_point'length) then
			ret := to_signed(976, fixed_point'length);
		elsif arg >= to_signed(3185, fixed_point'length) and arg < to_signed(4096, fixed_point'length) then
			ret := to_signed(1001, fixed_point'length);
		elsif arg >= to_signed(4096, fixed_point'length) and arg < to_signed(4096, fixed_point'length) then
			ret := to_signed(1001, fixed_point'length);
		else
			return factor;
		end if;
		return ret;
	end sigmoid;
end Sigmoid;
