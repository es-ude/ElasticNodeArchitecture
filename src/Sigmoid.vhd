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
		if arg < -10*factor then
			ret := zero;
		elsif arg > 10 * factor then
			ret := factor;
		elsif arg >= to_signed(-128, fixed_point'length) and arg < to_signed(-125, fixed_point'length) then
			ret := to_signed(7, fixed_point'length);
		elsif arg >= to_signed(-125, fixed_point'length) and arg < to_signed(-122, fixed_point'length) then
			ret := to_signed(7, fixed_point'length);
		elsif arg >= to_signed(-122, fixed_point'length) and arg < to_signed(-120, fixed_point'length) then
			ret := to_signed(8, fixed_point'length);
		elsif arg >= to_signed(-120, fixed_point'length) and arg < to_signed(-117, fixed_point'length) then
			ret := to_signed(8, fixed_point'length);
		elsif arg >= to_signed(-117, fixed_point'length) and arg < to_signed(-115, fixed_point'length) then
			ret := to_signed(8, fixed_point'length);
		elsif arg >= to_signed(-115, fixed_point'length) and arg < to_signed(-112, fixed_point'length) then
			ret := to_signed(9, fixed_point'length);
		elsif arg >= to_signed(-112, fixed_point'length) and arg < to_signed(-109, fixed_point'length) then
			ret := to_signed(9, fixed_point'length);
		elsif arg >= to_signed(-109, fixed_point'length) and arg < to_signed(-107, fixed_point'length) then
			ret := to_signed(9, fixed_point'length);
		elsif arg >= to_signed(-107, fixed_point'length) and arg < to_signed(-104, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-104, fixed_point'length) and arg < to_signed(-102, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-102, fixed_point'length) and arg < to_signed(-99, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-99, fixed_point'length) and arg < to_signed(-96, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-96, fixed_point'length) and arg < to_signed(-94, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-94, fixed_point'length) and arg < to_signed(-91, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-91, fixed_point'length) and arg < to_signed(-89, fixed_point'length) then
			ret := to_signed(12, fixed_point'length);
		elsif arg >= to_signed(-89, fixed_point'length) and arg < to_signed(-86, fixed_point'length) then
			ret := to_signed(12, fixed_point'length);
		elsif arg >= to_signed(-86, fixed_point'length) and arg < to_signed(-84, fixed_point'length) then
			ret := to_signed(13, fixed_point'length);
		elsif arg >= to_signed(-84, fixed_point'length) and arg < to_signed(-81, fixed_point'length) then
			ret := to_signed(13, fixed_point'length);
		elsif arg >= to_signed(-81, fixed_point'length) and arg < to_signed(-78, fixed_point'length) then
			ret := to_signed(14, fixed_point'length);
		elsif arg >= to_signed(-78, fixed_point'length) and arg < to_signed(-76, fixed_point'length) then
			ret := to_signed(14, fixed_point'length);
		elsif arg >= to_signed(-76, fixed_point'length) and arg < to_signed(-73, fixed_point'length) then
			ret := to_signed(14, fixed_point'length);
		elsif arg >= to_signed(-73, fixed_point'length) and arg < to_signed(-71, fixed_point'length) then
			ret := to_signed(15, fixed_point'length);
		elsif arg >= to_signed(-71, fixed_point'length) and arg < to_signed(-68, fixed_point'length) then
			ret := to_signed(15, fixed_point'length);
		elsif arg >= to_signed(-68, fixed_point'length) and arg < to_signed(-65, fixed_point'length) then
			ret := to_signed(16, fixed_point'length);
		elsif arg >= to_signed(-65, fixed_point'length) and arg < to_signed(-63, fixed_point'length) then
			ret := to_signed(17, fixed_point'length);
		elsif arg >= to_signed(-63, fixed_point'length) and arg < to_signed(-60, fixed_point'length) then
			ret := to_signed(17, fixed_point'length);
		elsif arg >= to_signed(-60, fixed_point'length) and arg < to_signed(-58, fixed_point'length) then
			ret := to_signed(18, fixed_point'length);
		elsif arg >= to_signed(-58, fixed_point'length) and arg < to_signed(-55, fixed_point'length) then
			ret := to_signed(18, fixed_point'length);
		elsif arg >= to_signed(-55, fixed_point'length) and arg < to_signed(-53, fixed_point'length) then
			ret := to_signed(19, fixed_point'length);
		elsif arg >= to_signed(-53, fixed_point'length) and arg < to_signed(-50, fixed_point'length) then
			ret := to_signed(19, fixed_point'length);
		elsif arg >= to_signed(-50, fixed_point'length) and arg < to_signed(-47, fixed_point'length) then
			ret := to_signed(20, fixed_point'length);
		elsif arg >= to_signed(-47, fixed_point'length) and arg < to_signed(-45, fixed_point'length) then
			ret := to_signed(20, fixed_point'length);
		elsif arg >= to_signed(-45, fixed_point'length) and arg < to_signed(-42, fixed_point'length) then
			ret := to_signed(21, fixed_point'length);
		elsif arg >= to_signed(-42, fixed_point'length) and arg < to_signed(-40, fixed_point'length) then
			ret := to_signed(21, fixed_point'length);
		elsif arg >= to_signed(-40, fixed_point'length) and arg < to_signed(-37, fixed_point'length) then
			ret := to_signed(22, fixed_point'length);
		elsif arg >= to_signed(-37, fixed_point'length) and arg < to_signed(-34, fixed_point'length) then
			ret := to_signed(22, fixed_point'length);
		elsif arg >= to_signed(-34, fixed_point'length) and arg < to_signed(-32, fixed_point'length) then
			ret := to_signed(23, fixed_point'length);
		elsif arg >= to_signed(-32, fixed_point'length) and arg < to_signed(-29, fixed_point'length) then
			ret := to_signed(24, fixed_point'length);
		elsif arg >= to_signed(-29, fixed_point'length) and arg < to_signed(-27, fixed_point'length) then
			ret := to_signed(24, fixed_point'length);
		elsif arg >= to_signed(-27, fixed_point'length) and arg < to_signed(-24, fixed_point'length) then
			ret := to_signed(25, fixed_point'length);
		elsif arg >= to_signed(-24, fixed_point'length) and arg < to_signed(-21, fixed_point'length) then
			ret := to_signed(26, fixed_point'length);
		elsif arg >= to_signed(-21, fixed_point'length) and arg < to_signed(-19, fixed_point'length) then
			ret := to_signed(26, fixed_point'length);
		elsif arg >= to_signed(-19, fixed_point'length) and arg < to_signed(-16, fixed_point'length) then
			ret := to_signed(27, fixed_point'length);
		elsif arg >= to_signed(-16, fixed_point'length) and arg < to_signed(-14, fixed_point'length) then
			ret := to_signed(28, fixed_point'length);
		elsif arg >= to_signed(-14, fixed_point'length) and arg < to_signed(-11, fixed_point'length) then
			ret := to_signed(28, fixed_point'length);
		elsif arg >= to_signed(-11, fixed_point'length) and arg < to_signed(-9, fixed_point'length) then
			ret := to_signed(29, fixed_point'length);
		elsif arg >= to_signed(-9, fixed_point'length) and arg < to_signed(-6, fixed_point'length) then
			ret := to_signed(29, fixed_point'length);
		elsif arg >= to_signed(-6, fixed_point'length) and arg < to_signed(-3, fixed_point'length) then
			ret := to_signed(30, fixed_point'length);
		elsif arg >= to_signed(-3, fixed_point'length) and arg < to_signed(-1, fixed_point'length) then
			ret := to_signed(31, fixed_point'length);
		elsif arg >= to_signed(-1, fixed_point'length) and arg < to_signed(1, fixed_point'length) then
			ret := to_signed(31, fixed_point'length);
		elsif arg >= to_signed(1, fixed_point'length) and arg < to_signed(3, fixed_point'length) then
			ret := to_signed(32, fixed_point'length);
		elsif arg >= to_signed(3, fixed_point'length) and arg < to_signed(6, fixed_point'length) then
			ret := to_signed(32, fixed_point'length);
		elsif arg >= to_signed(6, fixed_point'length) and arg < to_signed(9, fixed_point'length) then
			ret := to_signed(33, fixed_point'length);
		elsif arg >= to_signed(9, fixed_point'length) and arg < to_signed(11, fixed_point'length) then
			ret := to_signed(34, fixed_point'length);
		elsif arg >= to_signed(11, fixed_point'length) and arg < to_signed(14, fixed_point'length) then
			ret := to_signed(34, fixed_point'length);
		elsif arg >= to_signed(14, fixed_point'length) and arg < to_signed(16, fixed_point'length) then
			ret := to_signed(35, fixed_point'length);
		elsif arg >= to_signed(16, fixed_point'length) and arg < to_signed(19, fixed_point'length) then
			ret := to_signed(35, fixed_point'length);
		elsif arg >= to_signed(19, fixed_point'length) and arg < to_signed(21, fixed_point'length) then
			ret := to_signed(36, fixed_point'length);
		elsif arg >= to_signed(21, fixed_point'length) and arg < to_signed(24, fixed_point'length) then
			ret := to_signed(37, fixed_point'length);
		elsif arg >= to_signed(24, fixed_point'length) and arg < to_signed(27, fixed_point'length) then
			ret := to_signed(37, fixed_point'length);
		elsif arg >= to_signed(27, fixed_point'length) and arg < to_signed(29, fixed_point'length) then
			ret := to_signed(38, fixed_point'length);
		elsif arg >= to_signed(29, fixed_point'length) and arg < to_signed(32, fixed_point'length) then
			ret := to_signed(39, fixed_point'length);
		elsif arg >= to_signed(32, fixed_point'length) and arg < to_signed(34, fixed_point'length) then
			ret := to_signed(39, fixed_point'length);
		elsif arg >= to_signed(34, fixed_point'length) and arg < to_signed(37, fixed_point'length) then
			ret := to_signed(40, fixed_point'length);
		elsif arg >= to_signed(37, fixed_point'length) and arg < to_signed(40, fixed_point'length) then
			ret := to_signed(41, fixed_point'length);
		elsif arg >= to_signed(40, fixed_point'length) and arg < to_signed(42, fixed_point'length) then
			ret := to_signed(41, fixed_point'length);
		elsif arg >= to_signed(42, fixed_point'length) and arg < to_signed(45, fixed_point'length) then
			ret := to_signed(42, fixed_point'length);
		elsif arg >= to_signed(45, fixed_point'length) and arg < to_signed(47, fixed_point'length) then
			ret := to_signed(42, fixed_point'length);
		elsif arg >= to_signed(47, fixed_point'length) and arg < to_signed(50, fixed_point'length) then
			ret := to_signed(43, fixed_point'length);
		elsif arg >= to_signed(50, fixed_point'length) and arg < to_signed(53, fixed_point'length) then
			ret := to_signed(43, fixed_point'length);
		elsif arg >= to_signed(53, fixed_point'length) and arg < to_signed(55, fixed_point'length) then
			ret := to_signed(44, fixed_point'length);
		elsif arg >= to_signed(55, fixed_point'length) and arg < to_signed(58, fixed_point'length) then
			ret := to_signed(44, fixed_point'length);
		elsif arg >= to_signed(58, fixed_point'length) and arg < to_signed(60, fixed_point'length) then
			ret := to_signed(45, fixed_point'length);
		elsif arg >= to_signed(60, fixed_point'length) and arg < to_signed(63, fixed_point'length) then
			ret := to_signed(45, fixed_point'length);
		elsif arg >= to_signed(63, fixed_point'length) and arg < to_signed(65, fixed_point'length) then
			ret := to_signed(46, fixed_point'length);
		elsif arg >= to_signed(65, fixed_point'length) and arg < to_signed(68, fixed_point'length) then
			ret := to_signed(46, fixed_point'length);
		elsif arg >= to_signed(68, fixed_point'length) and arg < to_signed(71, fixed_point'length) then
			ret := to_signed(47, fixed_point'length);
		elsif arg >= to_signed(71, fixed_point'length) and arg < to_signed(73, fixed_point'length) then
			ret := to_signed(48, fixed_point'length);
		elsif arg >= to_signed(73, fixed_point'length) and arg < to_signed(76, fixed_point'length) then
			ret := to_signed(48, fixed_point'length);
		elsif arg >= to_signed(76, fixed_point'length) and arg < to_signed(78, fixed_point'length) then
			ret := to_signed(49, fixed_point'length);
		elsif arg >= to_signed(78, fixed_point'length) and arg < to_signed(81, fixed_point'length) then
			ret := to_signed(49, fixed_point'length);
		elsif arg >= to_signed(81, fixed_point'length) and arg < to_signed(84, fixed_point'length) then
			ret := to_signed(49, fixed_point'length);
		elsif arg >= to_signed(84, fixed_point'length) and arg < to_signed(86, fixed_point'length) then
			ret := to_signed(50, fixed_point'length);
		elsif arg >= to_signed(86, fixed_point'length) and arg < to_signed(89, fixed_point'length) then
			ret := to_signed(50, fixed_point'length);
		elsif arg >= to_signed(89, fixed_point'length) and arg < to_signed(91, fixed_point'length) then
			ret := to_signed(51, fixed_point'length);
		elsif arg >= to_signed(91, fixed_point'length) and arg < to_signed(94, fixed_point'length) then
			ret := to_signed(51, fixed_point'length);
		elsif arg >= to_signed(94, fixed_point'length) and arg < to_signed(96, fixed_point'length) then
			ret := to_signed(52, fixed_point'length);
		elsif arg >= to_signed(96, fixed_point'length) and arg < to_signed(99, fixed_point'length) then
			ret := to_signed(52, fixed_point'length);
		elsif arg >= to_signed(99, fixed_point'length) and arg < to_signed(102, fixed_point'length) then
			ret := to_signed(52, fixed_point'length);
		elsif arg >= to_signed(102, fixed_point'length) and arg < to_signed(104, fixed_point'length) then
			ret := to_signed(53, fixed_point'length);
		elsif arg >= to_signed(104, fixed_point'length) and arg < to_signed(107, fixed_point'length) then
			ret := to_signed(53, fixed_point'length);
		elsif arg >= to_signed(107, fixed_point'length) and arg < to_signed(109, fixed_point'length) then
			ret := to_signed(53, fixed_point'length);
		elsif arg >= to_signed(109, fixed_point'length) and arg < to_signed(112, fixed_point'length) then
			ret := to_signed(54, fixed_point'length);
		elsif arg >= to_signed(112, fixed_point'length) and arg < to_signed(115, fixed_point'length) then
			ret := to_signed(54, fixed_point'length);
		elsif arg >= to_signed(115, fixed_point'length) and arg < to_signed(117, fixed_point'length) then
			ret := to_signed(54, fixed_point'length);
		elsif arg >= to_signed(117, fixed_point'length) and arg < to_signed(120, fixed_point'length) then
			ret := to_signed(55, fixed_point'length);
		elsif arg >= to_signed(120, fixed_point'length) and arg < to_signed(122, fixed_point'length) then
			ret := to_signed(55, fixed_point'length);
		elsif arg >= to_signed(122, fixed_point'length) and arg < to_signed(125, fixed_point'length) then
			ret := to_signed(55, fixed_point'length);
		elsif arg >= to_signed(125, fixed_point'length) and arg < to_signed(128, fixed_point'length) then
			ret := to_signed(56, fixed_point'length);
		else
			return factor;
		end if;
		return ret;
	end sigmoid;
end Sigmoid;
