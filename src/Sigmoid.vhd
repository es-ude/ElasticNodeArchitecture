library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.Common.all;

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
			ret <= to_fixed_point(0);
		elsif arg > 4096 then
			ret <= to_fixed_point(1024);
		elsif arg >= to_fixed_point(-4096) and arg < to_fixed_point(-4096) then
			ret <= to_fixed_point(18);
		elsif arg >= to_fixed_point(-4096) and arg < to_fixed_point(-4013) then
			ret <= to_fixed_point(20);
		elsif arg >= to_fixed_point(-4013) and arg < to_fixed_point(-3930) then
			ret <= to_fixed_point(22);
		elsif arg >= to_fixed_point(-3930) and arg < to_fixed_point(-3847) then
			ret <= to_fixed_point(23);
		elsif arg >= to_fixed_point(-3847) and arg < to_fixed_point(-3765) then
			ret <= to_fixed_point(25);
		elsif arg >= to_fixed_point(-3765) and arg < to_fixed_point(-3682) then
			ret <= to_fixed_point(27);
		elsif arg >= to_fixed_point(-3682) and arg < to_fixed_point(-3599) then
			ret <= to_fixed_point(30);
		elsif arg >= to_fixed_point(-3599) and arg < to_fixed_point(-3516) then
			ret <= to_fixed_point(32);
		elsif arg >= to_fixed_point(-3516) and arg < to_fixed_point(-3434) then
			ret <= to_fixed_point(35);
		elsif arg >= to_fixed_point(-3434) and arg < to_fixed_point(-3351) then
			ret <= to_fixed_point(37);
		elsif arg >= to_fixed_point(-3351) and arg < to_fixed_point(-3268) then
			ret <= to_fixed_point(40);
		elsif arg >= to_fixed_point(-3268) and arg < to_fixed_point(-3185) then
			ret <= to_fixed_point(44);
		elsif arg >= to_fixed_point(-3185) and arg < to_fixed_point(-3103) then
			ret <= to_fixed_point(47);
		elsif arg >= to_fixed_point(-3103) and arg < to_fixed_point(-3020) then
			ret <= to_fixed_point(51);
		elsif arg >= to_fixed_point(-3020) and arg < to_fixed_point(-2937) then
			ret <= to_fixed_point(55);
		elsif arg >= to_fixed_point(-2937) and arg < to_fixed_point(-2854) then
			ret <= to_fixed_point(59);
		elsif arg >= to_fixed_point(-2854) and arg < to_fixed_point(-2772) then
			ret <= to_fixed_point(64);
		elsif arg >= to_fixed_point(-2772) and arg < to_fixed_point(-2689) then
			ret <= to_fixed_point(69);
		elsif arg >= to_fixed_point(-2689) and arg < to_fixed_point(-2606) then
			ret <= to_fixed_point(74);
		elsif arg >= to_fixed_point(-2606) and arg < to_fixed_point(-2523) then
			ret <= to_fixed_point(80);
		elsif arg >= to_fixed_point(-2523) and arg < to_fixed_point(-2441) then
			ret <= to_fixed_point(86);
		elsif arg >= to_fixed_point(-2441) and arg < to_fixed_point(-2358) then
			ret <= to_fixed_point(93);
		elsif arg >= to_fixed_point(-2358) and arg < to_fixed_point(-2275) then
			ret <= to_fixed_point(100);
		elsif arg >= to_fixed_point(-2275) and arg < to_fixed_point(-2192) then
			ret <= to_fixed_point(108);
		elsif arg >= to_fixed_point(-2192) and arg < to_fixed_point(-2110) then
			ret <= to_fixed_point(116);
		elsif arg >= to_fixed_point(-2110) and arg < to_fixed_point(-2027) then
			ret <= to_fixed_point(124);
		elsif arg >= to_fixed_point(-2027) and arg < to_fixed_point(-1944) then
			ret <= to_fixed_point(133);
		elsif arg >= to_fixed_point(-1944) and arg < to_fixed_point(-1861) then
			ret <= to_fixed_point(143);
		elsif arg >= to_fixed_point(-1861) and arg < to_fixed_point(-1779) then
			ret <= to_fixed_point(153);
		elsif arg >= to_fixed_point(-1779) and arg < to_fixed_point(-1696) then
			ret <= to_fixed_point(164);
		elsif arg >= to_fixed_point(-1696) and arg < to_fixed_point(-1613) then
			ret <= to_fixed_point(176);
		elsif arg >= to_fixed_point(-1613) and arg < to_fixed_point(-1530) then
			ret <= to_fixed_point(188);
		elsif arg >= to_fixed_point(-1530) and arg < to_fixed_point(-1448) then
			ret <= to_fixed_point(200);
		elsif arg >= to_fixed_point(-1448) and arg < to_fixed_point(-1365) then
			ret <= to_fixed_point(214);
		elsif arg >= to_fixed_point(-1365) and arg < to_fixed_point(-1282) then
			ret <= to_fixed_point(228);
		elsif arg >= to_fixed_point(-1282) and arg < to_fixed_point(-1199) then
			ret <= to_fixed_point(242);
		elsif arg >= to_fixed_point(-1199) and arg < to_fixed_point(-1117) then
			ret <= to_fixed_point(257);
		elsif arg >= to_fixed_point(-1117) and arg < to_fixed_point(-1034) then
			ret <= to_fixed_point(273);
		elsif arg >= to_fixed_point(-1034) and arg < to_fixed_point(-951) then
			ret <= to_fixed_point(290);
		elsif arg >= to_fixed_point(-951) and arg < to_fixed_point(-868) then
			ret <= to_fixed_point(307);
		elsif arg >= to_fixed_point(-868) and arg < to_fixed_point(-786) then
			ret <= to_fixed_point(325);
		elsif arg >= to_fixed_point(-786) and arg < to_fixed_point(-703) then
			ret <= to_fixed_point(343);
		elsif arg >= to_fixed_point(-703) and arg < to_fixed_point(-620) then
			ret <= to_fixed_point(361);
		elsif arg >= to_fixed_point(-620) and arg < to_fixed_point(-537) then
			ret <= to_fixed_point(381);
		elsif arg >= to_fixed_point(-537) and arg < to_fixed_point(-455) then
			ret <= to_fixed_point(400);
		elsif arg >= to_fixed_point(-455) and arg < to_fixed_point(-372) then
			ret <= to_fixed_point(420);
		elsif arg >= to_fixed_point(-372) and arg < to_fixed_point(-289) then
			ret <= to_fixed_point(440);
		elsif arg >= to_fixed_point(-289) and arg < to_fixed_point(-206) then
			ret <= to_fixed_point(460);
		elsif arg >= to_fixed_point(-206) and arg < to_fixed_point(-124) then
			ret <= to_fixed_point(481);
		elsif arg >= to_fixed_point(-124) and arg < to_fixed_point(-41) then
			ret <= to_fixed_point(502);
		elsif arg >= to_fixed_point(-41) and arg < to_fixed_point(41) then
			ret <= to_fixed_point(522);
		elsif arg >= to_fixed_point(41) and arg < to_fixed_point(124) then
			ret <= to_fixed_point(543);
		elsif arg >= to_fixed_point(124) and arg < to_fixed_point(206) then
			ret <= to_fixed_point(564);
		elsif arg >= to_fixed_point(206) and arg < to_fixed_point(289) then
			ret <= to_fixed_point(584);
		elsif arg >= to_fixed_point(289) and arg < to_fixed_point(372) then
			ret <= to_fixed_point(604);
		elsif arg >= to_fixed_point(372) and arg < to_fixed_point(455) then
			ret <= to_fixed_point(624);
		elsif arg >= to_fixed_point(455) and arg < to_fixed_point(537) then
			ret <= to_fixed_point(643);
		elsif arg >= to_fixed_point(537) and arg < to_fixed_point(620) then
			ret <= to_fixed_point(663);
		elsif arg >= to_fixed_point(620) and arg < to_fixed_point(703) then
			ret <= to_fixed_point(681);
		elsif arg >= to_fixed_point(703) and arg < to_fixed_point(786) then
			ret <= to_fixed_point(699);
		elsif arg >= to_fixed_point(786) and arg < to_fixed_point(868) then
			ret <= to_fixed_point(717);
		elsif arg >= to_fixed_point(868) and arg < to_fixed_point(951) then
			ret <= to_fixed_point(734);
		elsif arg >= to_fixed_point(951) and arg < to_fixed_point(1034) then
			ret <= to_fixed_point(751);
		elsif arg >= to_fixed_point(1034) and arg < to_fixed_point(1117) then
			ret <= to_fixed_point(767);
		elsif arg >= to_fixed_point(1117) and arg < to_fixed_point(1199) then
			ret <= to_fixed_point(782);
		elsif arg >= to_fixed_point(1199) and arg < to_fixed_point(1282) then
			ret <= to_fixed_point(796);
		elsif arg >= to_fixed_point(1282) and arg < to_fixed_point(1365) then
			ret <= to_fixed_point(810);
		elsif arg >= to_fixed_point(1365) and arg < to_fixed_point(1448) then
			ret <= to_fixed_point(824);
		elsif arg >= to_fixed_point(1448) and arg < to_fixed_point(1530) then
			ret <= to_fixed_point(836);
		elsif arg >= to_fixed_point(1530) and arg < to_fixed_point(1613) then
			ret <= to_fixed_point(848);
		elsif arg >= to_fixed_point(1613) and arg < to_fixed_point(1696) then
			ret <= to_fixed_point(860);
		elsif arg >= to_fixed_point(1696) and arg < to_fixed_point(1779) then
			ret <= to_fixed_point(871);
		elsif arg >= to_fixed_point(1779) and arg < to_fixed_point(1861) then
			ret <= to_fixed_point(881);
		elsif arg >= to_fixed_point(1861) and arg < to_fixed_point(1944) then
			ret <= to_fixed_point(891);
		elsif arg >= to_fixed_point(1944) and arg < to_fixed_point(2027) then
			ret <= to_fixed_point(900);
		elsif arg >= to_fixed_point(2027) and arg < to_fixed_point(2110) then
			ret <= to_fixed_point(908);
		elsif arg >= to_fixed_point(2110) and arg < to_fixed_point(2192) then
			ret <= to_fixed_point(916);
		elsif arg >= to_fixed_point(2192) and arg < to_fixed_point(2275) then
			ret <= to_fixed_point(924);
		elsif arg >= to_fixed_point(2275) and arg < to_fixed_point(2358) then
			ret <= to_fixed_point(931);
		elsif arg >= to_fixed_point(2358) and arg < to_fixed_point(2441) then
			ret <= to_fixed_point(938);
		elsif arg >= to_fixed_point(2441) and arg < to_fixed_point(2523) then
			ret <= to_fixed_point(944);
		elsif arg >= to_fixed_point(2523) and arg < to_fixed_point(2606) then
			ret <= to_fixed_point(950);
		elsif arg >= to_fixed_point(2606) and arg < to_fixed_point(2689) then
			ret <= to_fixed_point(955);
		elsif arg >= to_fixed_point(2689) and arg < to_fixed_point(2772) then
			ret <= to_fixed_point(960);
		elsif arg >= to_fixed_point(2772) and arg < to_fixed_point(2854) then
			ret <= to_fixed_point(965);
		elsif arg >= to_fixed_point(2854) and arg < to_fixed_point(2937) then
			ret <= to_fixed_point(969);
		elsif arg >= to_fixed_point(2937) and arg < to_fixed_point(3020) then
			ret <= to_fixed_point(973);
		elsif arg >= to_fixed_point(3020) and arg < to_fixed_point(3103) then
			ret <= to_fixed_point(977);
		elsif arg >= to_fixed_point(3103) and arg < to_fixed_point(3185) then
			ret <= to_fixed_point(980);
		elsif arg >= to_fixed_point(3185) and arg < to_fixed_point(3268) then
			ret <= to_fixed_point(984);
		elsif arg >= to_fixed_point(3268) and arg < to_fixed_point(3351) then
			ret <= to_fixed_point(987);
		elsif arg >= to_fixed_point(3351) and arg < to_fixed_point(3434) then
			ret <= to_fixed_point(989);
		elsif arg >= to_fixed_point(3434) and arg < to_fixed_point(3516) then
			ret <= to_fixed_point(992);
		elsif arg >= to_fixed_point(3516) and arg < to_fixed_point(3599) then
			ret <= to_fixed_point(994);
		elsif arg >= to_fixed_point(3599) and arg < to_fixed_point(3682) then
			ret <= to_fixed_point(997);
		elsif arg >= to_fixed_point(3682) and arg < to_fixed_point(3765) then
			ret <= to_fixed_point(999);
		elsif arg >= to_fixed_point(3765) and arg < to_fixed_point(3847) then
			ret <= to_fixed_point(1001);
		elsif arg >= to_fixed_point(3847) and arg < to_fixed_point(3930) then
			ret <= to_fixed_point(1002);
		elsif arg >= to_fixed_point(3930) and arg < to_fixed_point(4013) then
			ret <= to_fixed_point(1004);
		elsif arg >= to_fixed_point(4013) and arg < to_fixed_point(4096) then
			ret <= to_fixed_point(1006);
		elsif arg >= to_fixed_point(4096) and arg < to_fixed_point(4096) then
			ret <= to_fixed_point(1006);
		else
			ret <= factor;
		end if;
	end process;
end Behavioral;
