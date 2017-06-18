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
			ret := to_signed(5, fixed_point'length);
		elsif arg > 1280 then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(-1280, fixed_point'length) and arg < to_signed(-1254, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1254, fixed_point'length) and arg < to_signed(-1228, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1228, fixed_point'length) and arg < to_signed(-1202, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1202, fixed_point'length) and arg < to_signed(-1176, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1176, fixed_point'length) and arg < to_signed(-1150, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1150, fixed_point'length) and arg < to_signed(-1124, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1124, fixed_point'length) and arg < to_signed(-1098, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1098, fixed_point'length) and arg < to_signed(-1073, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1073, fixed_point'length) and arg < to_signed(-1047, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1047, fixed_point'length) and arg < to_signed(-1021, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-1021, fixed_point'length) and arg < to_signed(-995, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-995, fixed_point'length) and arg < to_signed(-969, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-969, fixed_point'length) and arg < to_signed(-943, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-943, fixed_point'length) and arg < to_signed(-917, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-917, fixed_point'length) and arg < to_signed(-892, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-892, fixed_point'length) and arg < to_signed(-866, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-866, fixed_point'length) and arg < to_signed(-840, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-840, fixed_point'length) and arg < to_signed(-814, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-814, fixed_point'length) and arg < to_signed(-788, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-788, fixed_point'length) and arg < to_signed(-762, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-762, fixed_point'length) and arg < to_signed(-736, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-736, fixed_point'length) and arg < to_signed(-711, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-711, fixed_point'length) and arg < to_signed(-685, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg >= to_signed(-685, fixed_point'length) and arg < to_signed(-659, fixed_point'length) then
			ret := to_signed(6, fixed_point'length);
		elsif arg >= to_signed(-659, fixed_point'length) and arg < to_signed(-633, fixed_point'length) then
			ret := to_signed(6, fixed_point'length);
		elsif arg >= to_signed(-633, fixed_point'length) and arg < to_signed(-607, fixed_point'length) then
			ret := to_signed(6, fixed_point'length);
		elsif arg >= to_signed(-607, fixed_point'length) and arg < to_signed(-581, fixed_point'length) then
			ret := to_signed(6, fixed_point'length);
		elsif arg >= to_signed(-581, fixed_point'length) and arg < to_signed(-555, fixed_point'length) then
			ret := to_signed(6, fixed_point'length);
		elsif arg >= to_signed(-555, fixed_point'length) and arg < to_signed(-530, fixed_point'length) then
			ret := to_signed(7, fixed_point'length);
		elsif arg >= to_signed(-530, fixed_point'length) and arg < to_signed(-504, fixed_point'length) then
			ret := to_signed(7, fixed_point'length);
		elsif arg >= to_signed(-504, fixed_point'length) and arg < to_signed(-478, fixed_point'length) then
			ret := to_signed(7, fixed_point'length);
		elsif arg >= to_signed(-478, fixed_point'length) and arg < to_signed(-452, fixed_point'length) then
			ret := to_signed(8, fixed_point'length);
		elsif arg >= to_signed(-452, fixed_point'length) and arg < to_signed(-426, fixed_point'length) then
			ret := to_signed(8, fixed_point'length);
		elsif arg >= to_signed(-426, fixed_point'length) and arg < to_signed(-400, fixed_point'length) then
			ret := to_signed(9, fixed_point'length);
		elsif arg >= to_signed(-400, fixed_point'length) and arg < to_signed(-374, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-374, fixed_point'length) and arg < to_signed(-349, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-349, fixed_point'length) and arg < to_signed(-323, fixed_point'length) then
			ret := to_signed(12, fixed_point'length);
		elsif arg >= to_signed(-323, fixed_point'length) and arg < to_signed(-297, fixed_point'length) then
			ret := to_signed(14, fixed_point'length);
		elsif arg >= to_signed(-297, fixed_point'length) and arg < to_signed(-271, fixed_point'length) then
			ret := to_signed(16, fixed_point'length);
		elsif arg >= to_signed(-271, fixed_point'length) and arg < to_signed(-245, fixed_point'length) then
			ret := to_signed(18, fixed_point'length);
		elsif arg >= to_signed(-245, fixed_point'length) and arg < to_signed(-219, fixed_point'length) then
			ret := to_signed(20, fixed_point'length);
		elsif arg >= to_signed(-219, fixed_point'length) and arg < to_signed(-193, fixed_point'length) then
			ret := to_signed(23, fixed_point'length);
		elsif arg >= to_signed(-193, fixed_point'length) and arg < to_signed(-168, fixed_point'length) then
			ret := to_signed(26, fixed_point'length);
		elsif arg >= to_signed(-168, fixed_point'length) and arg < to_signed(-142, fixed_point'length) then
			ret := to_signed(30, fixed_point'length);
		elsif arg >= to_signed(-142, fixed_point'length) and arg < to_signed(-116, fixed_point'length) then
			ret := to_signed(34, fixed_point'length);
		elsif arg >= to_signed(-116, fixed_point'length) and arg < to_signed(-90, fixed_point'length) then
			ret := to_signed(39, fixed_point'length);
		elsif arg >= to_signed(-90, fixed_point'length) and arg < to_signed(-64, fixed_point'length) then
			ret := to_signed(44, fixed_point'length);
		elsif arg >= to_signed(-64, fixed_point'length) and arg < to_signed(-38, fixed_point'length) then
			ret := to_signed(49, fixed_point'length);
		elsif arg >= to_signed(-38, fixed_point'length) and arg < to_signed(-12, fixed_point'length) then
			ret := to_signed(55, fixed_point'length);
		elsif arg >= to_signed(-12, fixed_point'length) and arg < to_signed(12, fixed_point'length) then
			ret := to_signed(61, fixed_point'length);
		elsif arg >= to_signed(12, fixed_point'length) and arg < to_signed(38, fixed_point'length) then
			ret := to_signed(67, fixed_point'length);
		elsif arg >= to_signed(38, fixed_point'length) and arg < to_signed(64, fixed_point'length) then
			ret := to_signed(73, fixed_point'length);
		elsif arg >= to_signed(64, fixed_point'length) and arg < to_signed(90, fixed_point'length) then
			ret := to_signed(79, fixed_point'length);
		elsif arg >= to_signed(90, fixed_point'length) and arg < to_signed(116, fixed_point'length) then
			ret := to_signed(84, fixed_point'length);
		elsif arg >= to_signed(116, fixed_point'length) and arg < to_signed(142, fixed_point'length) then
			ret := to_signed(89, fixed_point'length);
		elsif arg >= to_signed(142, fixed_point'length) and arg < to_signed(168, fixed_point'length) then
			ret := to_signed(94, fixed_point'length);
		elsif arg >= to_signed(168, fixed_point'length) and arg < to_signed(193, fixed_point'length) then
			ret := to_signed(98, fixed_point'length);
		elsif arg >= to_signed(193, fixed_point'length) and arg < to_signed(219, fixed_point'length) then
			ret := to_signed(102, fixed_point'length);
		elsif arg >= to_signed(219, fixed_point'length) and arg < to_signed(245, fixed_point'length) then
			ret := to_signed(105, fixed_point'length);
		elsif arg >= to_signed(245, fixed_point'length) and arg < to_signed(271, fixed_point'length) then
			ret := to_signed(108, fixed_point'length);
		elsif arg >= to_signed(271, fixed_point'length) and arg < to_signed(297, fixed_point'length) then
			ret := to_signed(110, fixed_point'length);
		elsif arg >= to_signed(297, fixed_point'length) and arg < to_signed(323, fixed_point'length) then
			ret := to_signed(112, fixed_point'length);
		elsif arg >= to_signed(323, fixed_point'length) and arg < to_signed(349, fixed_point'length) then
			ret := to_signed(114, fixed_point'length);
		elsif arg >= to_signed(349, fixed_point'length) and arg < to_signed(374, fixed_point'length) then
			ret := to_signed(116, fixed_point'length);
		elsif arg >= to_signed(374, fixed_point'length) and arg < to_signed(400, fixed_point'length) then
			ret := to_signed(117, fixed_point'length);
		elsif arg >= to_signed(400, fixed_point'length) and arg < to_signed(426, fixed_point'length) then
			ret := to_signed(118, fixed_point'length);
		elsif arg >= to_signed(426, fixed_point'length) and arg < to_signed(452, fixed_point'length) then
			ret := to_signed(119, fixed_point'length);
		elsif arg >= to_signed(452, fixed_point'length) and arg < to_signed(478, fixed_point'length) then
			ret := to_signed(120, fixed_point'length);
		elsif arg >= to_signed(478, fixed_point'length) and arg < to_signed(504, fixed_point'length) then
			ret := to_signed(120, fixed_point'length);
		elsif arg >= to_signed(504, fixed_point'length) and arg < to_signed(530, fixed_point'length) then
			ret := to_signed(121, fixed_point'length);
		elsif arg >= to_signed(530, fixed_point'length) and arg < to_signed(555, fixed_point'length) then
			ret := to_signed(121, fixed_point'length);
		elsif arg >= to_signed(555, fixed_point'length) and arg < to_signed(581, fixed_point'length) then
			ret := to_signed(121, fixed_point'length);
		elsif arg >= to_signed(581, fixed_point'length) and arg < to_signed(607, fixed_point'length) then
			ret := to_signed(122, fixed_point'length);
		elsif arg >= to_signed(607, fixed_point'length) and arg < to_signed(633, fixed_point'length) then
			ret := to_signed(122, fixed_point'length);
		elsif arg >= to_signed(633, fixed_point'length) and arg < to_signed(659, fixed_point'length) then
			ret := to_signed(122, fixed_point'length);
		elsif arg >= to_signed(659, fixed_point'length) and arg < to_signed(685, fixed_point'length) then
			ret := to_signed(122, fixed_point'length);
		elsif arg >= to_signed(685, fixed_point'length) and arg < to_signed(711, fixed_point'length) then
			ret := to_signed(122, fixed_point'length);
		elsif arg >= to_signed(711, fixed_point'length) and arg < to_signed(736, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(736, fixed_point'length) and arg < to_signed(762, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(762, fixed_point'length) and arg < to_signed(788, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(788, fixed_point'length) and arg < to_signed(814, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(814, fixed_point'length) and arg < to_signed(840, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(840, fixed_point'length) and arg < to_signed(866, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(866, fixed_point'length) and arg < to_signed(892, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(892, fixed_point'length) and arg < to_signed(917, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(917, fixed_point'length) and arg < to_signed(943, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(943, fixed_point'length) and arg < to_signed(969, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(969, fixed_point'length) and arg < to_signed(995, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(995, fixed_point'length) and arg < to_signed(1021, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1021, fixed_point'length) and arg < to_signed(1047, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1047, fixed_point'length) and arg < to_signed(1073, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1073, fixed_point'length) and arg < to_signed(1098, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1098, fixed_point'length) and arg < to_signed(1124, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1124, fixed_point'length) and arg < to_signed(1150, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1150, fixed_point'length) and arg < to_signed(1176, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1176, fixed_point'length) and arg < to_signed(1202, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1202, fixed_point'length) and arg < to_signed(1228, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1228, fixed_point'length) and arg < to_signed(1254, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		elsif arg >= to_signed(1254, fixed_point'length) and arg < to_signed(1280, fixed_point'length) then
			ret := to_signed(123, fixed_point'length);
		else
			return factor;
		end if;
		return ret;
	end sigmoid;
end Sigmoid;
