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
		elsif arg >= to_signed(-4096, fixed_point'length) and arg < to_signed(-4013, fixed_point'length) then
			ret := to_signed(25, fixed_point'length);
		elsif arg >= to_signed(-4013, fixed_point'length) and arg < to_signed(-3930, fixed_point'length) then
			ret := to_signed(26, fixed_point'length);
		elsif arg >= to_signed(-3930, fixed_point'length) and arg < to_signed(-3847, fixed_point'length) then
			ret := to_signed(28, fixed_point'length);
		elsif arg >= to_signed(-3847, fixed_point'length) and arg < to_signed(-3765, fixed_point'length) then
			ret := to_signed(30, fixed_point'length);
		elsif arg >= to_signed(-3765, fixed_point'length) and arg < to_signed(-3682, fixed_point'length) then
			ret := to_signed(32, fixed_point'length);
		elsif arg >= to_signed(-3682, fixed_point'length) and arg < to_signed(-3599, fixed_point'length) then
			ret := to_signed(34, fixed_point'length);
		elsif arg >= to_signed(-3599, fixed_point'length) and arg < to_signed(-3516, fixed_point'length) then
			ret := to_signed(37, fixed_point'length);
		elsif arg >= to_signed(-3516, fixed_point'length) and arg < to_signed(-3434, fixed_point'length) then
			ret := to_signed(39, fixed_point'length);
		elsif arg >= to_signed(-3434, fixed_point'length) and arg < to_signed(-3351, fixed_point'length) then
			ret := to_signed(42, fixed_point'length);
		elsif arg >= to_signed(-3351, fixed_point'length) and arg < to_signed(-3268, fixed_point'length) then
			ret := to_signed(45, fixed_point'length);
		elsif arg >= to_signed(-3268, fixed_point'length) and arg < to_signed(-3185, fixed_point'length) then
			ret := to_signed(48, fixed_point'length);
		elsif arg >= to_signed(-3185, fixed_point'length) and arg < to_signed(-3103, fixed_point'length) then
			ret := to_signed(52, fixed_point'length);
		elsif arg >= to_signed(-3103, fixed_point'length) and arg < to_signed(-3020, fixed_point'length) then
			ret := to_signed(55, fixed_point'length);
		elsif arg >= to_signed(-3020, fixed_point'length) and arg < to_signed(-2937, fixed_point'length) then
			ret := to_signed(59, fixed_point'length);
		elsif arg >= to_signed(-2937, fixed_point'length) and arg < to_signed(-2854, fixed_point'length) then
			ret := to_signed(64, fixed_point'length);
		elsif arg >= to_signed(-2854, fixed_point'length) and arg < to_signed(-2772, fixed_point'length) then
			ret := to_signed(68, fixed_point'length);
		elsif arg >= to_signed(-2772, fixed_point'length) and arg < to_signed(-2689, fixed_point'length) then
			ret := to_signed(73, fixed_point'length);
		elsif arg >= to_signed(-2689, fixed_point'length) and arg < to_signed(-2606, fixed_point'length) then
			ret := to_signed(79, fixed_point'length);
		elsif arg >= to_signed(-2606, fixed_point'length) and arg < to_signed(-2523, fixed_point'length) then
			ret := to_signed(84, fixed_point'length);
		elsif arg >= to_signed(-2523, fixed_point'length) and arg < to_signed(-2441, fixed_point'length) then
			ret := to_signed(91, fixed_point'length);
		elsif arg >= to_signed(-2441, fixed_point'length) and arg < to_signed(-2358, fixed_point'length) then
			ret := to_signed(97, fixed_point'length);
		elsif arg >= to_signed(-2358, fixed_point'length) and arg < to_signed(-2275, fixed_point'length) then
			ret := to_signed(104, fixed_point'length);
		elsif arg >= to_signed(-2275, fixed_point'length) and arg < to_signed(-2192, fixed_point'length) then
			ret := to_signed(112, fixed_point'length);
		elsif arg >= to_signed(-2192, fixed_point'length) and arg < to_signed(-2110, fixed_point'length) then
			ret := to_signed(120, fixed_point'length);
		elsif arg >= to_signed(-2110, fixed_point'length) and arg < to_signed(-2027, fixed_point'length) then
			ret := to_signed(128, fixed_point'length);
		elsif arg >= to_signed(-2027, fixed_point'length) and arg < to_signed(-1944, fixed_point'length) then
			ret := to_signed(137, fixed_point'length);
		elsif arg >= to_signed(-1944, fixed_point'length) and arg < to_signed(-1861, fixed_point'length) then
			ret := to_signed(147, fixed_point'length);
		elsif arg >= to_signed(-1861, fixed_point'length) and arg < to_signed(-1779, fixed_point'length) then
			ret := to_signed(157, fixed_point'length);
		elsif arg >= to_signed(-1779, fixed_point'length) and arg < to_signed(-1696, fixed_point'length) then
			ret := to_signed(167, fixed_point'length);
		elsif arg >= to_signed(-1696, fixed_point'length) and arg < to_signed(-1613, fixed_point'length) then
			ret := to_signed(179, fixed_point'length);
		elsif arg >= to_signed(-1613, fixed_point'length) and arg < to_signed(-1530, fixed_point'length) then
			ret := to_signed(191, fixed_point'length);
		elsif arg >= to_signed(-1530, fixed_point'length) and arg < to_signed(-1448, fixed_point'length) then
			ret := to_signed(203, fixed_point'length);
		elsif arg >= to_signed(-1448, fixed_point'length) and arg < to_signed(-1365, fixed_point'length) then
			ret := to_signed(217, fixed_point'length);
		elsif arg >= to_signed(-1365, fixed_point'length) and arg < to_signed(-1282, fixed_point'length) then
			ret := to_signed(230, fixed_point'length);
		elsif arg >= to_signed(-1282, fixed_point'length) and arg < to_signed(-1199, fixed_point'length) then
			ret := to_signed(245, fixed_point'length);
		elsif arg >= to_signed(-1199, fixed_point'length) and arg < to_signed(-1117, fixed_point'length) then
			ret := to_signed(260, fixed_point'length);
		elsif arg >= to_signed(-1117, fixed_point'length) and arg < to_signed(-1034, fixed_point'length) then
			ret := to_signed(276, fixed_point'length);
		elsif arg >= to_signed(-1034, fixed_point'length) and arg < to_signed(-951, fixed_point'length) then
			ret := to_signed(292, fixed_point'length);
		elsif arg >= to_signed(-951, fixed_point'length) and arg < to_signed(-868, fixed_point'length) then
			ret := to_signed(309, fixed_point'length);
		elsif arg >= to_signed(-868, fixed_point'length) and arg < to_signed(-786, fixed_point'length) then
			ret := to_signed(326, fixed_point'length);
		elsif arg >= to_signed(-786, fixed_point'length) and arg < to_signed(-703, fixed_point'length) then
			ret := to_signed(344, fixed_point'length);
		elsif arg >= to_signed(-703, fixed_point'length) and arg < to_signed(-620, fixed_point'length) then
			ret := to_signed(363, fixed_point'length);
		elsif arg >= to_signed(-620, fixed_point'length) and arg < to_signed(-537, fixed_point'length) then
			ret := to_signed(382, fixed_point'length);
		elsif arg >= to_signed(-537, fixed_point'length) and arg < to_signed(-455, fixed_point'length) then
			ret := to_signed(401, fixed_point'length);
		elsif arg >= to_signed(-455, fixed_point'length) and arg < to_signed(-372, fixed_point'length) then
			ret := to_signed(421, fixed_point'length);
		elsif arg >= to_signed(-372, fixed_point'length) and arg < to_signed(-289, fixed_point'length) then
			ret := to_signed(441, fixed_point'length);
		elsif arg >= to_signed(-289, fixed_point'length) and arg < to_signed(-206, fixed_point'length) then
			ret := to_signed(461, fixed_point'length);
		elsif arg >= to_signed(-206, fixed_point'length) and arg < to_signed(-124, fixed_point'length) then
			ret := to_signed(481, fixed_point'length);
		elsif arg >= to_signed(-124, fixed_point'length) and arg < to_signed(-41, fixed_point'length) then
			ret := to_signed(502, fixed_point'length);
		elsif arg >= to_signed(-41, fixed_point'length) and arg < to_signed(41, fixed_point'length) then
			ret := to_signed(522, fixed_point'length);
		elsif arg >= to_signed(41, fixed_point'length) and arg < to_signed(124, fixed_point'length) then
			ret := to_signed(543, fixed_point'length);
		elsif arg >= to_signed(124, fixed_point'length) and arg < to_signed(206, fixed_point'length) then
			ret := to_signed(563, fixed_point'length);
		elsif arg >= to_signed(206, fixed_point'length) and arg < to_signed(289, fixed_point'length) then
			ret := to_signed(583, fixed_point'length);
		elsif arg >= to_signed(289, fixed_point'length) and arg < to_signed(372, fixed_point'length) then
			ret := to_signed(603, fixed_point'length);
		elsif arg >= to_signed(372, fixed_point'length) and arg < to_signed(455, fixed_point'length) then
			ret := to_signed(623, fixed_point'length);
		elsif arg >= to_signed(455, fixed_point'length) and arg < to_signed(537, fixed_point'length) then
			ret := to_signed(642, fixed_point'length);
		elsif arg >= to_signed(537, fixed_point'length) and arg < to_signed(620, fixed_point'length) then
			ret := to_signed(661, fixed_point'length);
		elsif arg >= to_signed(620, fixed_point'length) and arg < to_signed(703, fixed_point'length) then
			ret := to_signed(680, fixed_point'length);
		elsif arg >= to_signed(703, fixed_point'length) and arg < to_signed(786, fixed_point'length) then
			ret := to_signed(698, fixed_point'length);
		elsif arg >= to_signed(786, fixed_point'length) and arg < to_signed(868, fixed_point'length) then
			ret := to_signed(715, fixed_point'length);
		elsif arg >= to_signed(868, fixed_point'length) and arg < to_signed(951, fixed_point'length) then
			ret := to_signed(732, fixed_point'length);
		elsif arg >= to_signed(951, fixed_point'length) and arg < to_signed(1034, fixed_point'length) then
			ret := to_signed(748, fixed_point'length);
		elsif arg >= to_signed(1034, fixed_point'length) and arg < to_signed(1117, fixed_point'length) then
			ret := to_signed(764, fixed_point'length);
		elsif arg >= to_signed(1117, fixed_point'length) and arg < to_signed(1199, fixed_point'length) then
			ret := to_signed(779, fixed_point'length);
		elsif arg >= to_signed(1199, fixed_point'length) and arg < to_signed(1282, fixed_point'length) then
			ret := to_signed(794, fixed_point'length);
		elsif arg >= to_signed(1282, fixed_point'length) and arg < to_signed(1365, fixed_point'length) then
			ret := to_signed(807, fixed_point'length);
		elsif arg >= to_signed(1365, fixed_point'length) and arg < to_signed(1448, fixed_point'length) then
			ret := to_signed(821, fixed_point'length);
		elsif arg >= to_signed(1448, fixed_point'length) and arg < to_signed(1530, fixed_point'length) then
			ret := to_signed(833, fixed_point'length);
		elsif arg >= to_signed(1530, fixed_point'length) and arg < to_signed(1613, fixed_point'length) then
			ret := to_signed(845, fixed_point'length);
		elsif arg >= to_signed(1613, fixed_point'length) and arg < to_signed(1696, fixed_point'length) then
			ret := to_signed(857, fixed_point'length);
		elsif arg >= to_signed(1696, fixed_point'length) and arg < to_signed(1779, fixed_point'length) then
			ret := to_signed(867, fixed_point'length);
		elsif arg >= to_signed(1779, fixed_point'length) and arg < to_signed(1861, fixed_point'length) then
			ret := to_signed(877, fixed_point'length);
		elsif arg >= to_signed(1861, fixed_point'length) and arg < to_signed(1944, fixed_point'length) then
			ret := to_signed(887, fixed_point'length);
		elsif arg >= to_signed(1944, fixed_point'length) and arg < to_signed(2027, fixed_point'length) then
			ret := to_signed(896, fixed_point'length);
		elsif arg >= to_signed(2027, fixed_point'length) and arg < to_signed(2110, fixed_point'length) then
			ret := to_signed(904, fixed_point'length);
		elsif arg >= to_signed(2110, fixed_point'length) and arg < to_signed(2192, fixed_point'length) then
			ret := to_signed(912, fixed_point'length);
		elsif arg >= to_signed(2192, fixed_point'length) and arg < to_signed(2275, fixed_point'length) then
			ret := to_signed(920, fixed_point'length);
		elsif arg >= to_signed(2275, fixed_point'length) and arg < to_signed(2358, fixed_point'length) then
			ret := to_signed(927, fixed_point'length);
		elsif arg >= to_signed(2358, fixed_point'length) and arg < to_signed(2441, fixed_point'length) then
			ret := to_signed(933, fixed_point'length);
		elsif arg >= to_signed(2441, fixed_point'length) and arg < to_signed(2523, fixed_point'length) then
			ret := to_signed(940, fixed_point'length);
		elsif arg >= to_signed(2523, fixed_point'length) and arg < to_signed(2606, fixed_point'length) then
			ret := to_signed(945, fixed_point'length);
		elsif arg >= to_signed(2606, fixed_point'length) and arg < to_signed(2689, fixed_point'length) then
			ret := to_signed(951, fixed_point'length);
		elsif arg >= to_signed(2689, fixed_point'length) and arg < to_signed(2772, fixed_point'length) then
			ret := to_signed(956, fixed_point'length);
		elsif arg >= to_signed(2772, fixed_point'length) and arg < to_signed(2854, fixed_point'length) then
			ret := to_signed(960, fixed_point'length);
		elsif arg >= to_signed(2854, fixed_point'length) and arg < to_signed(2937, fixed_point'length) then
			ret := to_signed(965, fixed_point'length);
		elsif arg >= to_signed(2937, fixed_point'length) and arg < to_signed(3020, fixed_point'length) then
			ret := to_signed(969, fixed_point'length);
		elsif arg >= to_signed(3020, fixed_point'length) and arg < to_signed(3103, fixed_point'length) then
			ret := to_signed(972, fixed_point'length);
		elsif arg >= to_signed(3103, fixed_point'length) and arg < to_signed(3185, fixed_point'length) then
			ret := to_signed(976, fixed_point'length);
		elsif arg >= to_signed(3185, fixed_point'length) and arg < to_signed(3268, fixed_point'length) then
			ret := to_signed(979, fixed_point'length);
		elsif arg >= to_signed(3268, fixed_point'length) and arg < to_signed(3351, fixed_point'length) then
			ret := to_signed(982, fixed_point'length);
		elsif arg >= to_signed(3351, fixed_point'length) and arg < to_signed(3434, fixed_point'length) then
			ret := to_signed(985, fixed_point'length);
		elsif arg >= to_signed(3434, fixed_point'length) and arg < to_signed(3516, fixed_point'length) then
			ret := to_signed(987, fixed_point'length);
		elsif arg >= to_signed(3516, fixed_point'length) and arg < to_signed(3599, fixed_point'length) then
			ret := to_signed(990, fixed_point'length);
		elsif arg >= to_signed(3599, fixed_point'length) and arg < to_signed(3682, fixed_point'length) then
			ret := to_signed(992, fixed_point'length);
		elsif arg >= to_signed(3682, fixed_point'length) and arg < to_signed(3765, fixed_point'length) then
			ret := to_signed(994, fixed_point'length);
		elsif arg >= to_signed(3765, fixed_point'length) and arg < to_signed(3847, fixed_point'length) then
			ret := to_signed(996, fixed_point'length);
		elsif arg >= to_signed(3847, fixed_point'length) and arg < to_signed(3930, fixed_point'length) then
			ret := to_signed(998, fixed_point'length);
		elsif arg >= to_signed(3930, fixed_point'length) and arg < to_signed(4013, fixed_point'length) then
			ret := to_signed(999, fixed_point'length);
		elsif arg >= to_signed(4013, fixed_point'length) and arg < to_signed(4096, fixed_point'length) then
			ret := to_signed(1001, fixed_point'length);
		elsif arg >= to_signed(4096, fixed_point'length) and arg < to_signed(4096, fixed_point'length) then
			ret := to_signed(1001, fixed_point'length);
		else
			return factor;
		end if;
		return ret;
	end sigmoid;
end Sigmoid;
