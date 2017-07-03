library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library neuralnetwork;
use neuralnetwork.common.all;

entity Sigmoid is
port (
	arg 		: in fixed_point;
	output	: out fixed_point
	);
end Sigmoid;

architecture Behavioral of Sigmoid is 
	begin
	
	process (arg) is
			variable ret : fixed_point;

	begin
	 
		if arg < to_signed(-256, fixed_point'length) then
			ret := to_signed(5, fixed_point'length);
		elsif arg > to_signed(256, fixed_point'length) then
			ret := to_signed(59, fixed_point'length);
		elsif arg >= to_signed(-256, fixed_point'length) and arg < to_signed(-256, fixed_point'length) then
			ret := to_signed(6, fixed_point'length);
		elsif arg >= to_signed(-256, fixed_point'length) and arg < to_signed(-199, fixed_point'length) then
			ret := to_signed(7, fixed_point'length);
		elsif arg >= to_signed(-199, fixed_point'length) and arg < to_signed(-142, fixed_point'length) then
			ret := to_signed(10, fixed_point'length);
		elsif arg >= to_signed(-142, fixed_point'length) and arg < to_signed(-85, fixed_point'length) then
			ret := to_signed(16, fixed_point'length);
		elsif arg >= to_signed(-85, fixed_point'length) and arg < to_signed(-28, fixed_point'length) then
			ret := to_signed(26, fixed_point'length);
		elsif arg >= to_signed(-28, fixed_point'length) and arg < to_signed(28, fixed_point'length) then
			ret := to_signed(38, fixed_point'length);
		elsif arg >= to_signed(28, fixed_point'length) and arg < to_signed(85, fixed_point'length) then
			ret := to_signed(48, fixed_point'length);
		elsif arg >= to_signed(85, fixed_point'length) and arg < to_signed(142, fixed_point'length) then
			ret := to_signed(54, fixed_point'length);
		elsif arg >= to_signed(142, fixed_point'length) and arg < to_signed(199, fixed_point'length) then
			ret := to_signed(57, fixed_point'length);
		elsif arg >= to_signed(199, fixed_point'length) and arg < to_signed(256, fixed_point'length) then
			ret := to_signed(58, fixed_point'length);
		elsif arg >= to_signed(256, fixed_point'length) and arg < to_signed(256, fixed_point'length) then
			ret := to_signed(58, fixed_point'length);
		else
			ret := factor;
		end if;
		output <= ret;

	end process;
end Behavioral;
