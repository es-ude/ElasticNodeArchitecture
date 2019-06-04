library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.Common.all;
library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

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
			ret <= to_fixed_point(10);
		elsif arg > 4096 then
			ret <= to_fixed_point(1014);
		elsif arg > to_fixed_point(-4095) and arg <= to_fixed_point(-3797) then
			ret <= to_fixed_point(20);
		elsif arg > to_fixed_point(-3797) and arg <= to_fixed_point(-3436) then
			ret <= to_fixed_point(30);
		elsif arg > to_fixed_point(-3436) and arg <= to_fixed_point(-3165) then
			ret <= to_fixed_point(40);
		elsif arg > to_fixed_point(-3165) and arg <= to_fixed_point(-2947) then
			ret <= to_fixed_point(50);
		elsif arg > to_fixed_point(-2947) and arg <= to_fixed_point(-2764) then
			ret <= to_fixed_point(60);
		elsif arg > to_fixed_point(-2764) and arg <= to_fixed_point(-2606) then
			ret <= to_fixed_point(70);
		elsif arg > to_fixed_point(-2606) and arg <= to_fixed_point(-2466) then
			ret <= to_fixed_point(80);
		elsif arg > to_fixed_point(-2466) and arg <= to_fixed_point(-2340) then
			ret <= to_fixed_point(90);
		elsif arg > to_fixed_point(-2340) and arg <= to_fixed_point(-2226) then
			ret <= to_fixed_point(100);
		elsif arg > to_fixed_point(-2226) and arg <= to_fixed_point(-2122) then
			ret <= to_fixed_point(110);
		elsif arg > to_fixed_point(-2122) and arg <= to_fixed_point(-2024) then
			ret <= to_fixed_point(120);
		elsif arg > to_fixed_point(-2024) and arg <= to_fixed_point(-1934) then
			ret <= to_fixed_point(130);
		elsif arg > to_fixed_point(-1934) and arg <= to_fixed_point(-1849) then
			ret <= to_fixed_point(140);
		elsif arg > to_fixed_point(-1849) and arg <= to_fixed_point(-1769) then
			ret <= to_fixed_point(150);
		elsif arg > to_fixed_point(-1769) and arg <= to_fixed_point(-1693) then
			ret <= to_fixed_point(160);
		elsif arg > to_fixed_point(-1693) and arg <= to_fixed_point(-1620) then
			ret <= to_fixed_point(170);
		elsif arg > to_fixed_point(-1620) and arg <= to_fixed_point(-1551) then
			ret <= to_fixed_point(180);
		elsif arg > to_fixed_point(-1551) and arg <= to_fixed_point(-1485) then
			ret <= to_fixed_point(190);
		elsif arg > to_fixed_point(-1485) and arg <= to_fixed_point(-1421) then
			ret <= to_fixed_point(200);
		elsif arg > to_fixed_point(-1421) and arg <= to_fixed_point(-1359) then
			ret <= to_fixed_point(210);
		elsif arg > to_fixed_point(-1359) and arg <= to_fixed_point(-1300) then
			ret <= to_fixed_point(220);
		elsif arg > to_fixed_point(-1300) and arg <= to_fixed_point(-1243) then
			ret <= to_fixed_point(230);
		elsif arg > to_fixed_point(-1243) and arg <= to_fixed_point(-1187) then
			ret <= to_fixed_point(240);
		elsif arg > to_fixed_point(-1187) and arg <= to_fixed_point(-1132) then
			ret <= to_fixed_point(250);
		elsif arg > to_fixed_point(-1132) and arg <= to_fixed_point(-1080) then
			ret <= to_fixed_point(260);
		elsif arg > to_fixed_point(-1080) and arg <= to_fixed_point(-1028) then
			ret <= to_fixed_point(270);
		elsif arg > to_fixed_point(-1028) and arg <= to_fixed_point(-978) then
			ret <= to_fixed_point(280);
		elsif arg > to_fixed_point(-978) and arg <= to_fixed_point(-928) then
			ret <= to_fixed_point(290);
		elsif arg > to_fixed_point(-928) and arg <= to_fixed_point(-880) then
			ret <= to_fixed_point(300);
		elsif arg > to_fixed_point(-880) and arg <= to_fixed_point(-833) then
			ret <= to_fixed_point(310);
		elsif arg > to_fixed_point(-833) and arg <= to_fixed_point(-786) then
			ret <= to_fixed_point(320);
		elsif arg > to_fixed_point(-786) and arg <= to_fixed_point(-740) then
			ret <= to_fixed_point(330);
		elsif arg > to_fixed_point(-740) and arg <= to_fixed_point(-695) then
			ret <= to_fixed_point(340);
		elsif arg > to_fixed_point(-695) and arg <= to_fixed_point(-651) then
			ret <= to_fixed_point(350);
		elsif arg > to_fixed_point(-651) and arg <= to_fixed_point(-607) then
			ret <= to_fixed_point(360);
		elsif arg > to_fixed_point(-607) and arg <= to_fixed_point(-563) then
			ret <= to_fixed_point(370);
		elsif arg > to_fixed_point(-563) and arg <= to_fixed_point(-520) then
			ret <= to_fixed_point(380);
		elsif arg > to_fixed_point(-520) and arg <= to_fixed_point(-478) then
			ret <= to_fixed_point(390);
		elsif arg > to_fixed_point(-478) and arg <= to_fixed_point(-436) then
			ret <= to_fixed_point(400);
		elsif arg > to_fixed_point(-436) and arg <= to_fixed_point(-394) then
			ret <= to_fixed_point(410);
		elsif arg > to_fixed_point(-394) and arg <= to_fixed_point(-353) then
			ret <= to_fixed_point(420);
		elsif arg > to_fixed_point(-353) and arg <= to_fixed_point(-312) then
			ret <= to_fixed_point(430);
		elsif arg > to_fixed_point(-312) and arg <= to_fixed_point(-271) then
			ret <= to_fixed_point(440);
		elsif arg > to_fixed_point(-271) and arg <= to_fixed_point(-230) then
			ret <= to_fixed_point(450);
		elsif arg > to_fixed_point(-230) and arg <= to_fixed_point(-190) then
			ret <= to_fixed_point(460);
		elsif arg > to_fixed_point(-190) and arg <= to_fixed_point(-150) then
			ret <= to_fixed_point(470);
		elsif arg > to_fixed_point(-150) and arg <= to_fixed_point(-110) then
			ret <= to_fixed_point(480);
		elsif arg > to_fixed_point(-110) and arg <= to_fixed_point(-70) then
			ret <= to_fixed_point(490);
		elsif arg > to_fixed_point(-70) and arg <= to_fixed_point(-30) then
			ret <= to_fixed_point(500);
		elsif arg > to_fixed_point(-30) and arg <= to_fixed_point(11) then
			ret <= to_fixed_point(510);
		elsif arg > to_fixed_point(11) and arg <= to_fixed_point(51) then
			ret <= to_fixed_point(520);
		elsif arg > to_fixed_point(51) and arg <= to_fixed_point(91) then
			ret <= to_fixed_point(530);
		elsif arg > to_fixed_point(91) and arg <= to_fixed_point(131) then
			ret <= to_fixed_point(540);
		elsif arg > to_fixed_point(131) and arg <= to_fixed_point(171) then
			ret <= to_fixed_point(550);
		elsif arg > to_fixed_point(171) and arg <= to_fixed_point(211) then
			ret <= to_fixed_point(560);
		elsif arg > to_fixed_point(211) and arg <= to_fixed_point(252) then
			ret <= to_fixed_point(570);
		elsif arg > to_fixed_point(252) and arg <= to_fixed_point(292) then
			ret <= to_fixed_point(580);
		elsif arg > to_fixed_point(292) and arg <= to_fixed_point(333) then
			ret <= to_fixed_point(590);
		elsif arg > to_fixed_point(333) and arg <= to_fixed_point(375) then
			ret <= to_fixed_point(600);
		elsif arg > to_fixed_point(375) and arg <= to_fixed_point(416) then
			ret <= to_fixed_point(610);
		elsif arg > to_fixed_point(416) and arg <= to_fixed_point(458) then
			ret <= to_fixed_point(620);
		elsif arg > to_fixed_point(458) and arg <= to_fixed_point(500) then
			ret <= to_fixed_point(630);
		elsif arg > to_fixed_point(500) and arg <= to_fixed_point(543) then
			ret <= to_fixed_point(640);
		elsif arg > to_fixed_point(543) and arg <= to_fixed_point(586) then
			ret <= to_fixed_point(650);
		elsif arg > to_fixed_point(586) and arg <= to_fixed_point(630) then
			ret <= to_fixed_point(660);
		elsif arg > to_fixed_point(630) and arg <= to_fixed_point(674) then
			ret <= to_fixed_point(670);
		elsif arg > to_fixed_point(674) and arg <= to_fixed_point(719) then
			ret <= to_fixed_point(680);
		elsif arg > to_fixed_point(719) and arg <= to_fixed_point(764) then
			ret <= to_fixed_point(690);
		elsif arg > to_fixed_point(764) and arg <= to_fixed_point(810) then
			ret <= to_fixed_point(700);
		elsif arg > to_fixed_point(810) and arg <= to_fixed_point(857) then
			ret <= to_fixed_point(710);
		elsif arg > to_fixed_point(857) and arg <= to_fixed_point(905) then
			ret <= to_fixed_point(720);
		elsif arg > to_fixed_point(905) and arg <= to_fixed_point(954) then
			ret <= to_fixed_point(730);
		elsif arg > to_fixed_point(954) and arg <= to_fixed_point(1004) then
			ret <= to_fixed_point(740);
		elsif arg > to_fixed_point(1004) and arg <= to_fixed_point(1055) then
			ret <= to_fixed_point(750);
		elsif arg > to_fixed_point(1055) and arg <= to_fixed_point(1107) then
			ret <= to_fixed_point(760);
		elsif arg > to_fixed_point(1107) and arg <= to_fixed_point(1160) then
			ret <= to_fixed_point(770);
		elsif arg > to_fixed_point(1160) and arg <= to_fixed_point(1215) then
			ret <= to_fixed_point(780);
		elsif arg > to_fixed_point(1215) and arg <= to_fixed_point(1272) then
			ret <= to_fixed_point(790);
		elsif arg > to_fixed_point(1272) and arg <= to_fixed_point(1331) then
			ret <= to_fixed_point(800);
		elsif arg > to_fixed_point(1331) and arg <= to_fixed_point(1391) then
			ret <= to_fixed_point(810);
		elsif arg > to_fixed_point(1391) and arg <= to_fixed_point(1454) then
			ret <= to_fixed_point(820);
		elsif arg > to_fixed_point(1454) and arg <= to_fixed_point(1519) then
			ret <= to_fixed_point(830);
		elsif arg > to_fixed_point(1519) and arg <= to_fixed_point(1586) then
			ret <= to_fixed_point(840);
		elsif arg > to_fixed_point(1586) and arg <= to_fixed_point(1657) then
			ret <= to_fixed_point(850);
		elsif arg > to_fixed_point(1657) and arg <= to_fixed_point(1731) then
			ret <= to_fixed_point(860);
		elsif arg > to_fixed_point(1731) and arg <= to_fixed_point(1809) then
			ret <= to_fixed_point(870);
		elsif arg > to_fixed_point(1809) and arg <= to_fixed_point(1892) then
			ret <= to_fixed_point(880);
		elsif arg > to_fixed_point(1892) and arg <= to_fixed_point(1979) then
			ret <= to_fixed_point(890);
		elsif arg > to_fixed_point(1979) and arg <= to_fixed_point(2073) then
			ret <= to_fixed_point(900);
		elsif arg > to_fixed_point(2073) and arg <= to_fixed_point(2174) then
			ret <= to_fixed_point(910);
		elsif arg > to_fixed_point(2174) and arg <= to_fixed_point(2283) then
			ret <= to_fixed_point(920);
		elsif arg > to_fixed_point(2283) and arg <= to_fixed_point(2403) then
			ret <= to_fixed_point(930);
		elsif arg > to_fixed_point(2403) and arg <= to_fixed_point(2535) then
			ret <= to_fixed_point(940);
		elsif arg > to_fixed_point(2535) and arg <= to_fixed_point(2683) then
			ret <= to_fixed_point(950);
		elsif arg > to_fixed_point(2683) and arg <= to_fixed_point(2853) then
			ret <= to_fixed_point(960);
		elsif arg > to_fixed_point(2853) and arg <= to_fixed_point(3052) then
			ret <= to_fixed_point(970);
		elsif arg > to_fixed_point(3052) and arg <= to_fixed_point(3294) then
			ret <= to_fixed_point(980);
		elsif arg > to_fixed_point(3294) and arg <= to_fixed_point(3603) then
			ret <= to_fixed_point(990);
		elsif arg > to_fixed_point(3603) and arg <= to_fixed_point(4037) then
			ret <= to_fixed_point(1000);
		elsif arg > to_fixed_point(4037) and arg <= to_fixed_point(4095) then
			ret <= to_fixed_point(1010);
		else
			ret <= factor;
		end if;
	end process;
end Behavioral;
