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
		if arg < to_signed(-640, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg > to_signed(640, fixed_point'length) then
			ret := to_signed(59, fixed_point'length);
		elsif arg >= to_signed(-640, fixed_point'length) and arg < to_signed(-290, fixed_point'length) then
			ret := to_signed(6, fixed_point'length);
		elsif arg >= to_signed(-290, fixed_point'length) and arg < to_signed(-226, fixed_point'length) then
			ret := to_signed(7, fixed_point'length);
		elsif arg >= to_signed(-226, fixed_point'length) and arg < to_signed(-187, fixed_point'length) then
			ret := to_signed(8, fixed_point'length);
		elsif arg >= to_signed(-187, fixed_point'length) and arg < to_signed(-161, fixed_point'length) then
			ret := to_signed(9, fixed_point'length);
		elsif arg >= to_signed(-161, fixed_point'length) and arg < to_signed(-148, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-148, fixed_point'length) and arg < to_signed(-135, fixed_point'length) then
			ret := to_signed(11, fixed_point'length);
		elsif arg >= to_signed(-135, fixed_point'length) and arg < to_signed(-122, fixed_point'length) then
			ret := to_signed(12, fixed_point'length);
		elsif arg >= to_signed(-122, fixed_point'length) and arg < to_signed(-109, fixed_point'length) then
			ret := to_signed(13, fixed_point'length);
		elsif arg >= to_signed(-109, fixed_point'length) and arg < to_signed(-96, fixed_point'length) then
			ret := to_signed(15, fixed_point'length);
		elsif arg >= to_signed(-96, fixed_point'length) and arg < to_signed(-84, fixed_point'length) then
			ret := to_signed(16, fixed_point'length);
		elsif arg >= to_signed(-84, fixed_point'length) and arg < to_signed(-71, fixed_point'length) then
			ret := to_signed(18, fixed_point'length);
		elsif arg >= to_signed(-71, fixed_point'length) and arg < to_signed(-58, fixed_point'length) then
			ret := to_signed(21, fixed_point'length);
		elsif arg >= to_signed(-58, fixed_point'length) and arg < to_signed(-45, fixed_point'length) then
			ret := to_signed(23, fixed_point'length);
		elsif arg >= to_signed(-45, fixed_point'length) and arg < to_signed(-32, fixed_point'length) then
			ret := to_signed(25, fixed_point'length);
		elsif arg >= to_signed(-32, fixed_point'length) and arg < to_signed(-19, fixed_point'length) then
			ret := to_signed(28, fixed_point'length);
		elsif arg >= to_signed(-19, fixed_point'length) and arg < to_signed(-6, fixed_point'length) then
			ret := to_signed(31, fixed_point'length);
		elsif arg >= to_signed(-6, fixed_point'length) and arg < to_signed(6, fixed_point'length) then
			ret := to_signed(33, fixed_point'length);
		elsif arg >= to_signed(6, fixed_point'length) and arg < to_signed(19, fixed_point'length) then
			ret := to_signed(36, fixed_point'length);
		elsif arg >= to_signed(19, fixed_point'length) and arg < to_signed(32, fixed_point'length) then
			ret := to_signed(39, fixed_point'length);
		elsif arg >= to_signed(32, fixed_point'length) and arg < to_signed(45, fixed_point'length) then
			ret := to_signed(41, fixed_point'length);
		elsif arg >= to_signed(45, fixed_point'length) and arg < to_signed(58, fixed_point'length) then
			ret := to_signed(43, fixed_point'length);
		elsif arg >= to_signed(58, fixed_point'length) and arg < to_signed(71, fixed_point'length) then
			ret := to_signed(46, fixed_point'length);
		elsif arg >= to_signed(71, fixed_point'length) and arg < to_signed(84, fixed_point'length) then
			ret := to_signed(48, fixed_point'length);
		elsif arg >= to_signed(84, fixed_point'length) and arg < to_signed(96, fixed_point'length) then
			ret := to_signed(49, fixed_point'length);
		elsif arg >= to_signed(96, fixed_point'length) and arg < to_signed(109, fixed_point'length) then
			ret := to_signed(51, fixed_point'length);
		elsif arg >= to_signed(109, fixed_point'length) and arg < to_signed(122, fixed_point'length) then
			ret := to_signed(52, fixed_point'length);
		elsif arg >= to_signed(122, fixed_point'length) and arg < to_signed(135, fixed_point'length) then
			ret := to_signed(53, fixed_point'length);
		elsif arg >= to_signed(135, fixed_point'length) and arg < to_signed(148, fixed_point'length) then
			ret := to_signed(54, fixed_point'length);
		elsif arg >= to_signed(148, fixed_point'length) and arg < to_signed(161, fixed_point'length) then
			ret := to_signed(55, fixed_point'length);
		elsif arg >= to_signed(161, fixed_point'length) and arg < to_signed(174, fixed_point'length) then
			ret := to_signed(56, fixed_point'length);
		elsif arg >= to_signed(174, fixed_point'length) and arg < to_signed(200, fixed_point'length) then
			ret := to_signed(57, fixed_point'length);
		elsif arg >= to_signed(200, fixed_point'length) and arg < to_signed(239, fixed_point'length) then
			ret := to_signed(58, fixed_point'length);
		elsif arg >= to_signed(239, fixed_point'length) and arg < to_signed(303, fixed_point'length) then
			ret := to_signed(59, fixed_point'length);
		elsif arg >= to_signed(303, fixed_point'length) and arg < to_signed(640, fixed_point'length) then
			ret := to_signed(59, fixed_point'length);
		else
			return factor;
		end if;
		return ret;
	end sigmoid;
end Sigmoid;
