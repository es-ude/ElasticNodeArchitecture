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
		if arg < -1280 then
			ret := to_signed(10, fixed_point'length);
		elsif arg > 1280 then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(-1280, fixed_point'length) and arg < to_signed(-1254, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1254, fixed_point'length) and arg < to_signed(-1228, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1228, fixed_point'length) and arg < to_signed(-1202, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1202, fixed_point'length) and arg < to_signed(-1176, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1176, fixed_point'length) and arg < to_signed(-1150, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1150, fixed_point'length) and arg < to_signed(-1124, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1124, fixed_point'length) and arg < to_signed(-1098, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1098, fixed_point'length) and arg < to_signed(-1073, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1073, fixed_point'length) and arg < to_signed(-1047, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1047, fixed_point'length) and arg < to_signed(-1021, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-1021, fixed_point'length) and arg < to_signed(-995, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-995, fixed_point'length) and arg < to_signed(-969, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-969, fixed_point'length) and arg < to_signed(-943, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-943, fixed_point'length) and arg < to_signed(-917, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-917, fixed_point'length) and arg < to_signed(-892, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-892, fixed_point'length) and arg < to_signed(-866, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-866, fixed_point'length) and arg < to_signed(-840, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-840, fixed_point'length) and arg < to_signed(-814, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-814, fixed_point'length) and arg < to_signed(-788, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-788, fixed_point'length) and arg < to_signed(-762, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-762, fixed_point'length) and arg < to_signed(-736, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-736, fixed_point'length) and arg < to_signed(-711, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-711, fixed_point'length) and arg < to_signed(-685, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-685, fixed_point'length) and arg < to_signed(-659, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-659, fixed_point'length) and arg < to_signed(-633, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-633, fixed_point'length) and arg < to_signed(-607, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-607, fixed_point'length) and arg < to_signed(-581, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-581, fixed_point'length) and arg < to_signed(-555, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-555, fixed_point'length) and arg < to_signed(-530, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-530, fixed_point'length) and arg < to_signed(-504, fixed_point'length) then
			ret := to_signed(12, fixed_point'length);
		elsif arg >= to_signed(-504, fixed_point'length) and arg < to_signed(-478, fixed_point'length) then
			ret := to_signed(12, fixed_point'length);
		elsif arg >= to_signed(-478, fixed_point'length) and arg < to_signed(-452, fixed_point'length) then
			ret := to_signed(13, fixed_point'length);
		elsif arg >= to_signed(-452, fixed_point'length) and arg < to_signed(-426, fixed_point'length) then
			ret := to_signed(13, fixed_point'length);
		elsif arg >= to_signed(-426, fixed_point'length) and arg < to_signed(-400, fixed_point'length) then
			ret := to_signed(14, fixed_point'length);
		elsif arg >= to_signed(-400, fixed_point'length) and arg < to_signed(-374, fixed_point'length) then
			ret := to_signed(15, fixed_point'length);
		elsif arg >= to_signed(-374, fixed_point'length) and arg < to_signed(-349, fixed_point'length) then
			ret := to_signed(15, fixed_point'length);
		elsif arg >= to_signed(-349, fixed_point'length) and arg < to_signed(-323, fixed_point'length) then
			ret := to_signed(17, fixed_point'length);
		elsif arg >= to_signed(-323, fixed_point'length) and arg < to_signed(-297, fixed_point'length) then
			ret := to_signed(18, fixed_point'length);
		elsif arg >= to_signed(-297, fixed_point'length) and arg < to_signed(-271, fixed_point'length) then
			ret := to_signed(20, fixed_point'length);
		elsif arg >= to_signed(-271, fixed_point'length) and arg < to_signed(-245, fixed_point'length) then
			ret := to_signed(22, fixed_point'length);
		elsif arg >= to_signed(-245, fixed_point'length) and arg < to_signed(-219, fixed_point'length) then
			ret := to_signed(24, fixed_point'length);
		elsif arg >= to_signed(-219, fixed_point'length) and arg < to_signed(-193, fixed_point'length) then
			ret := to_signed(26, fixed_point'length);
		elsif arg >= to_signed(-193, fixed_point'length) and arg < to_signed(-168, fixed_point'length) then
			ret := to_signed(29, fixed_point'length);
		elsif arg >= to_signed(-168, fixed_point'length) and arg < to_signed(-142, fixed_point'length) then
			ret := to_signed(33, fixed_point'length);
		elsif arg >= to_signed(-142, fixed_point'length) and arg < to_signed(-116, fixed_point'length) then
			ret := to_signed(37, fixed_point'length);
		elsif arg >= to_signed(-116, fixed_point'length) and arg < to_signed(-90, fixed_point'length) then
			ret := to_signed(41, fixed_point'length);
		elsif arg >= to_signed(-90, fixed_point'length) and arg < to_signed(-64, fixed_point'length) then
			ret := to_signed(46, fixed_point'length);
		elsif arg >= to_signed(-64, fixed_point'length) and arg < to_signed(-38, fixed_point'length) then
			ret := to_signed(51, fixed_point'length);
		elsif arg >= to_signed(-38, fixed_point'length) and arg < to_signed(-12, fixed_point'length) then
			ret := to_signed(56, fixed_point'length);
		elsif arg >= to_signed(-12, fixed_point'length) and arg < to_signed(12, fixed_point'length) then
			ret := to_signed(61, fixed_point'length);
		elsif arg >= to_signed(12, fixed_point'length) and arg < to_signed(38, fixed_point'length) then
			ret := to_signed(67, fixed_point'length);
		elsif arg >= to_signed(38, fixed_point'length) and arg < to_signed(64, fixed_point'length) then
			ret := to_signed(72, fixed_point'length);
		elsif arg >= to_signed(64, fixed_point'length) and arg < to_signed(90, fixed_point'length) then
			ret := to_signed(77, fixed_point'length);
		elsif arg >= to_signed(90, fixed_point'length) and arg < to_signed(116, fixed_point'length) then
			ret := to_signed(82, fixed_point'length);
		elsif arg >= to_signed(116, fixed_point'length) and arg < to_signed(142, fixed_point'length) then
			ret := to_signed(87, fixed_point'length);
		elsif arg >= to_signed(142, fixed_point'length) and arg < to_signed(168, fixed_point'length) then
			ret := to_signed(91, fixed_point'length);
		elsif arg >= to_signed(168, fixed_point'length) and arg < to_signed(193, fixed_point'length) then
			ret := to_signed(95, fixed_point'length);
		elsif arg >= to_signed(193, fixed_point'length) and arg < to_signed(219, fixed_point'length) then
			ret := to_signed(99, fixed_point'length);
		elsif arg >= to_signed(219, fixed_point'length) and arg < to_signed(245, fixed_point'length) then
			ret := to_signed(102, fixed_point'length);
		elsif arg >= to_signed(245, fixed_point'length) and arg < to_signed(271, fixed_point'length) then
			ret := to_signed(104, fixed_point'length);
		elsif arg >= to_signed(271, fixed_point'length) and arg < to_signed(297, fixed_point'length) then
			ret := to_signed(106, fixed_point'length);
		elsif arg >= to_signed(297, fixed_point'length) and arg < to_signed(323, fixed_point'length) then
			ret := to_signed(108, fixed_point'length);
		elsif arg >= to_signed(323, fixed_point'length) and arg < to_signed(349, fixed_point'length) then
			ret := to_signed(110, fixed_point'length);
		elsif arg >= to_signed(349, fixed_point'length) and arg < to_signed(374, fixed_point'length) then
			ret := to_signed(111, fixed_point'length);
		elsif arg >= to_signed(374, fixed_point'length) and arg < to_signed(400, fixed_point'length) then
			ret := to_signed(113, fixed_point'length);
		elsif arg >= to_signed(400, fixed_point'length) and arg < to_signed(426, fixed_point'length) then
			ret := to_signed(113, fixed_point'length);
		elsif arg >= to_signed(426, fixed_point'length) and arg < to_signed(452, fixed_point'length) then
			ret := to_signed(114, fixed_point'length);
		elsif arg >= to_signed(452, fixed_point'length) and arg < to_signed(478, fixed_point'length) then
			ret := to_signed(115, fixed_point'length);
		elsif arg >= to_signed(478, fixed_point'length) and arg < to_signed(504, fixed_point'length) then
			ret := to_signed(115, fixed_point'length);
		elsif arg >= to_signed(504, fixed_point'length) and arg < to_signed(530, fixed_point'length) then
			ret := to_signed(116, fixed_point'length);
		elsif arg >= to_signed(530, fixed_point'length) and arg < to_signed(555, fixed_point'length) then
			ret := to_signed(116, fixed_point'length);
		elsif arg >= to_signed(555, fixed_point'length) and arg < to_signed(581, fixed_point'length) then
			ret := to_signed(117, fixed_point'length);
		elsif arg >= to_signed(581, fixed_point'length) and arg < to_signed(607, fixed_point'length) then
			ret := to_signed(117, fixed_point'length);
		elsif arg >= to_signed(607, fixed_point'length) and arg < to_signed(633, fixed_point'length) then
			ret := to_signed(117, fixed_point'length);
		elsif arg >= to_signed(633, fixed_point'length) and arg < to_signed(659, fixed_point'length) then
			ret := to_signed(117, fixed_point'length);
		elsif arg >= to_signed(659, fixed_point'length) and arg < to_signed(685, fixed_point'length) then
			ret := to_signed(117, fixed_point'length);
		elsif arg >= to_signed(685, fixed_point'length) and arg < to_signed(711, fixed_point'length) then
			ret := to_signed(117, fixed_point'length);
		elsif arg >= to_signed(711, fixed_point'length) and arg < to_signed(736, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(736, fixed_point'length) and arg < to_signed(762, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(762, fixed_point'length) and arg < to_signed(788, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(788, fixed_point'length) and arg < to_signed(814, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(814, fixed_point'length) and arg < to_signed(840, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(840, fixed_point'length) and arg < to_signed(866, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(866, fixed_point'length) and arg < to_signed(892, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(892, fixed_point'length) and arg < to_signed(917, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(917, fixed_point'length) and arg < to_signed(943, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(943, fixed_point'length) and arg < to_signed(969, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(969, fixed_point'length) and arg < to_signed(995, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(995, fixed_point'length) and arg < to_signed(1021, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1021, fixed_point'length) and arg < to_signed(1047, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1047, fixed_point'length) and arg < to_signed(1073, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1073, fixed_point'length) and arg < to_signed(1098, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1098, fixed_point'length) and arg < to_signed(1124, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1124, fixed_point'length) and arg < to_signed(1150, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1150, fixed_point'length) and arg < to_signed(1176, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1176, fixed_point'length) and arg < to_signed(1202, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1202, fixed_point'length) and arg < to_signed(1228, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1228, fixed_point'length) and arg < to_signed(1254, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(1254, fixed_point'length) and arg < to_signed(1280, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		else
			return factor;
		end if;
		return ret;
	end sigmoid;
end Sigmoid;
