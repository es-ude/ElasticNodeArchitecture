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
			ret <= to_fixed_point(5);
		elsif arg > 4096 then
			ret <= to_fixed_point(1019);
		elsif arg >= to_fixed_point(-4096) and arg < to_fixed_point(-4096) then
			ret <= to_fixed_point(23);
		elsif arg >= to_fixed_point(-4096) and arg < to_fixed_point(-4013) then
			ret <= to_fixed_point(25);
		elsif arg >= to_fixed_point(-4013) and arg < to_fixed_point(-3930) then
			ret <= to_fixed_point(26);
		elsif arg >= to_fixed_point(-3930) and arg < to_fixed_point(-3847) then
			ret <= to_fixed_point(28);
		elsif arg >= to_fixed_point(-3847) and arg < to_fixed_point(-3765) then
			ret <= to_fixed_point(30);
		elsif arg >= to_fixed_point(-3765) and arg < to_fixed_point(-3682) then
			ret <= to_fixed_point(32);
		elsif arg >= to_fixed_point(-3682) and arg < to_fixed_point(-3599) then
			ret <= to_fixed_point(34);
		elsif arg >= to_fixed_point(-3599) and arg < to_fixed_point(-3516) then
			ret <= to_fixed_point(37);
		elsif arg >= to_fixed_point(-3516) and arg < to_fixed_point(-3434) then
			ret <= to_fixed_point(39);
		elsif arg >= to_fixed_point(-3434) and arg < to_fixed_point(-3351) then
			ret <= to_fixed_point(42);
		elsif arg >= to_fixed_point(-3351) and arg < to_fixed_point(-3268) then
			ret <= to_fixed_point(45);
		elsif arg >= to_fixed_point(-3268) and arg < to_fixed_point(-3185) then
			ret <= to_fixed_point(48);
		elsif arg >= to_fixed_point(-3185) and arg < to_fixed_point(-3103) then
			ret <= to_fixed_point(52);
		elsif arg >= to_fixed_point(-3103) and arg < to_fixed_point(-3020) then
			ret <= to_fixed_point(55);
		elsif arg >= to_fixed_point(-3020) and arg < to_fixed_point(-2937) then
			ret <= to_fixed_point(59);
		elsif arg >= to_fixed_point(-2937) and arg < to_fixed_point(-2854) then
			ret <= to_fixed_point(64);
		elsif arg >= to_fixed_point(-2854) and arg < to_fixed_point(-2772) then
			ret <= to_fixed_point(68);
		elsif arg >= to_fixed_point(-2772) and arg < to_fixed_point(-2689) then
			ret <= to_fixed_point(73);
		elsif arg >= to_fixed_point(-2689) and arg < to_fixed_point(-2606) then
			ret <= to_fixed_point(79);
		elsif arg >= to_fixed_point(-2606) and arg < to_fixed_point(-2523) then
			ret <= to_fixed_point(84);
		elsif arg >= to_fixed_point(-2523) and arg < to_fixed_point(-2441) then
			ret <= to_fixed_point(91);
		elsif arg >= to_fixed_point(-2441) and arg < to_fixed_point(-2358) then
			ret <= to_fixed_point(97);
		elsif arg >= to_fixed_point(-2358) and arg < to_fixed_point(-2275) then
			ret <= to_fixed_point(104);
		elsif arg >= to_fixed_point(-2275) and arg < to_fixed_point(-2192) then
			ret <= to_fixed_point(112);
		elsif arg >= to_fixed_point(-2192) and arg < to_fixed_point(-2110) then
			ret <= to_fixed_point(120);
		elsif arg >= to_fixed_point(-2110) and arg < to_fixed_point(-2027) then
			ret <= to_fixed_point(128);
		elsif arg >= to_fixed_point(-2027) and arg < to_fixed_point(-1944) then
			ret <= to_fixed_point(137);
		elsif arg >= to_fixed_point(-1944) and arg < to_fixed_point(-1861) then
			ret <= to_fixed_point(147);
		elsif arg >= to_fixed_point(-1861) and arg < to_fixed_point(-1779) then
			ret <= to_fixed_point(157);
		elsif arg >= to_fixed_point(-1779) and arg < to_fixed_point(-1696) then
			ret <= to_fixed_point(167);
		elsif arg >= to_fixed_point(-1696) and arg < to_fixed_point(-1613) then
			ret <= to_fixed_point(179);
		elsif arg >= to_fixed_point(-1613) and arg < to_fixed_point(-1530) then
			ret <= to_fixed_point(191);
		elsif arg >= to_fixed_point(-1530) and arg < to_fixed_point(-1448) then
			ret <= to_fixed_point(203);
		elsif arg >= to_fixed_point(-1448) and arg < to_fixed_point(-1365) then
			ret <= to_fixed_point(217);
		elsif arg >= to_fixed_point(-1365) and arg < to_fixed_point(-1282) then
			ret <= to_fixed_point(230);
		elsif arg >= to_fixed_point(-1282) and arg < to_fixed_point(-1199) then
			ret <= to_fixed_point(245);
		elsif arg >= to_fixed_point(-1199) and arg < to_fixed_point(-1117) then
			ret <= to_fixed_point(260);
		elsif arg >= to_fixed_point(-1117) and arg < to_fixed_point(-1034) then
			ret <= to_fixed_point(276);
		elsif arg >= to_fixed_point(-1034) and arg < to_fixed_point(-951) then
			ret <= to_fixed_point(292);
		elsif arg >= to_fixed_point(-951) and arg < to_fixed_point(-868) then
			ret <= to_fixed_point(309);
		elsif arg >= to_fixed_point(-868) and arg < to_fixed_point(-786) then
			ret <= to_fixed_point(326);
		elsif arg >= to_fixed_point(-786) and arg < to_fixed_point(-703) then
			ret <= to_fixed_point(344);
		elsif arg >= to_fixed_point(-703) and arg < to_fixed_point(-620) then
			ret <= to_fixed_point(363);
		elsif arg >= to_fixed_point(-620) and arg < to_fixed_point(-537) then
			ret <= to_fixed_point(382);
		elsif arg >= to_fixed_point(-537) and arg < to_fixed_point(-455) then
			ret <= to_fixed_point(401);
		elsif arg >= to_fixed_point(-455) and arg < to_fixed_point(-372) then
			ret <= to_fixed_point(421);
		elsif arg >= to_fixed_point(-372) and arg < to_fixed_point(-289) then
			ret <= to_fixed_point(441);
		elsif arg >= to_fixed_point(-289) and arg < to_fixed_point(-206) then
			ret <= to_fixed_point(461);
		elsif arg >= to_fixed_point(-206) and arg < to_fixed_point(-124) then
			ret <= to_fixed_point(481);
		elsif arg >= to_fixed_point(-124) and arg < to_fixed_point(-41) then
			ret <= to_fixed_point(502);
		elsif arg >= to_fixed_point(-41) and arg < to_fixed_point(41) then
			ret <= to_fixed_point(522);
		elsif arg >= to_fixed_point(41) and arg < to_fixed_point(124) then
			ret <= to_fixed_point(543);
		elsif arg >= to_fixed_point(124) and arg < to_fixed_point(206) then
			ret <= to_fixed_point(563);
		elsif arg >= to_fixed_point(206) and arg < to_fixed_point(289) then
			ret <= to_fixed_point(583);
		elsif arg >= to_fixed_point(289) and arg < to_fixed_point(372) then
			ret <= to_fixed_point(603);
		elsif arg >= to_fixed_point(372) and arg < to_fixed_point(455) then
			ret <= to_fixed_point(623);
		elsif arg >= to_fixed_point(455) and arg < to_fixed_point(537) then
			ret <= to_fixed_point(642);
		elsif arg >= to_fixed_point(537) and arg < to_fixed_point(620) then
			ret <= to_fixed_point(661);
		elsif arg >= to_fixed_point(620) and arg < to_fixed_point(703) then
			ret <= to_fixed_point(680);
		elsif arg >= to_fixed_point(703) and arg < to_fixed_point(786) then
			ret <= to_fixed_point(698);
		elsif arg >= to_fixed_point(786) and arg < to_fixed_point(868) then
			ret <= to_fixed_point(715);
		elsif arg >= to_fixed_point(868) and arg < to_fixed_point(951) then
			ret <= to_fixed_point(732);
		elsif arg >= to_fixed_point(951) and arg < to_fixed_point(1034) then
			ret <= to_fixed_point(748);
		elsif arg >= to_fixed_point(1034) and arg < to_fixed_point(1117) then
			ret <= to_fixed_point(764);
		elsif arg >= to_fixed_point(1117) and arg < to_fixed_point(1199) then
			ret <= to_fixed_point(779);
		elsif arg >= to_fixed_point(1199) and arg < to_fixed_point(1282) then
			ret <= to_fixed_point(794);
		elsif arg >= to_fixed_point(1282) and arg < to_fixed_point(1365) then
			ret <= to_fixed_point(807);
		elsif arg >= to_fixed_point(1365) and arg < to_fixed_point(1448) then
			ret <= to_fixed_point(821);
		elsif arg >= to_fixed_point(1448) and arg < to_fixed_point(1530) then
			ret <= to_fixed_point(833);
		elsif arg >= to_fixed_point(1530) and arg < to_fixed_point(1613) then
			ret <= to_fixed_point(845);
		elsif arg >= to_fixed_point(1613) and arg < to_fixed_point(1696) then
			ret <= to_fixed_point(857);
		elsif arg >= to_fixed_point(1696) and arg < to_fixed_point(1779) then
			ret <= to_fixed_point(867);
		elsif arg >= to_fixed_point(1779) and arg < to_fixed_point(1861) then
			ret <= to_fixed_point(877);
		elsif arg >= to_fixed_point(1861) and arg < to_fixed_point(1944) then
			ret <= to_fixed_point(887);
		elsif arg >= to_fixed_point(1944) and arg < to_fixed_point(2027) then
			ret <= to_fixed_point(896);
		elsif arg >= to_fixed_point(2027) and arg < to_fixed_point(2110) then
			ret <= to_fixed_point(904);
		elsif arg >= to_fixed_point(2110) and arg < to_fixed_point(2192) then
			ret <= to_fixed_point(912);
		elsif arg >= to_fixed_point(2192) and arg < to_fixed_point(2275) then
			ret <= to_fixed_point(920);
		elsif arg >= to_fixed_point(2275) and arg < to_fixed_point(2358) then
			ret <= to_fixed_point(927);
		elsif arg >= to_fixed_point(2358) and arg < to_fixed_point(2441) then
			ret <= to_fixed_point(933);
		elsif arg >= to_fixed_point(2441) and arg < to_fixed_point(2523) then
			ret <= to_fixed_point(940);
		elsif arg >= to_fixed_point(2523) and arg < to_fixed_point(2606) then
			ret <= to_fixed_point(945);
		elsif arg >= to_fixed_point(2606) and arg < to_fixed_point(2689) then
			ret <= to_fixed_point(951);
		elsif arg >= to_fixed_point(2689) and arg < to_fixed_point(2772) then
			ret <= to_fixed_point(956);
		elsif arg >= to_fixed_point(2772) and arg < to_fixed_point(2854) then
			ret <= to_fixed_point(960);
		elsif arg >= to_fixed_point(2854) and arg < to_fixed_point(2937) then
			ret <= to_fixed_point(965);
		elsif arg >= to_fixed_point(2937) and arg < to_fixed_point(3020) then
			ret <= to_fixed_point(969);
		elsif arg >= to_fixed_point(3020) and arg < to_fixed_point(3103) then
			ret <= to_fixed_point(972);
		elsif arg >= to_fixed_point(3103) and arg < to_fixed_point(3185) then
			ret <= to_fixed_point(976);
		elsif arg >= to_fixed_point(3185) and arg < to_fixed_point(3268) then
			ret <= to_fixed_point(979);
		elsif arg >= to_fixed_point(3268) and arg < to_fixed_point(3351) then
			ret <= to_fixed_point(982);
		elsif arg >= to_fixed_point(3351) and arg < to_fixed_point(3434) then
			ret <= to_fixed_point(985);
		elsif arg >= to_fixed_point(3434) and arg < to_fixed_point(3516) then
			ret <= to_fixed_point(987);
		elsif arg >= to_fixed_point(3516) and arg < to_fixed_point(3599) then
			ret <= to_fixed_point(990);
		elsif arg >= to_fixed_point(3599) and arg < to_fixed_point(3682) then
			ret <= to_fixed_point(992);
		elsif arg >= to_fixed_point(3682) and arg < to_fixed_point(3765) then
			ret <= to_fixed_point(994);
		elsif arg >= to_fixed_point(3765) and arg < to_fixed_point(3847) then
			ret <= to_fixed_point(996);
		elsif arg >= to_fixed_point(3847) and arg < to_fixed_point(3930) then
			ret <= to_fixed_point(998);
		elsif arg >= to_fixed_point(3930) and arg < to_fixed_point(4013) then
			ret <= to_fixed_point(999);
		elsif arg >= to_fixed_point(4013) and arg < to_fixed_point(4096) then
			ret <= to_fixed_point(1001);
		elsif arg >= to_fixed_point(4096) and arg < to_fixed_point(4096) then
			ret <= to_fixed_point(1001);
		else
			ret <= factor;
		end if;
	end process;
end Behavioral;
