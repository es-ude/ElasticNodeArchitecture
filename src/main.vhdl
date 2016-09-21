----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:12:21 11/03/2015 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
Library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;

use UNISIM.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;




entity top is
	port (
		--ard_MISO1 : out bit;
		--fl_MISO1 : in bit;
		--ard_MOSI1 : in bit;
		--fl_MOSI1 : out bit;
		--ard_SCK1 : in bit;
		--fl_SCK1 : out bit;
		--ard_CS1 : in bit;
		--fl_CS1 : out bit;
		LED0 : out std_ulogic;
		CLK : in std_ulogic;
		--user_reset : in std_ulogic;
		--RESET : out bit;
		--REBOOT : in std_ulogic;
		--led_arr : out std_logic_vector(4 downto 0);
		arduino_47 : in std_logic
	);
end top;


architecture Behavioral of top is
signal BUSY : std_ulogic;
signal O : std_logic_vector(15 downto 0);
signal CE : std_ulogic;
signal I : std_logic_vector(15 downto 0);
signal WRITE : std_ulogic;
signal clk_divd : std_ulogic;
type state_type is (IDLE,NOOP,SYNC_H,SYNC_L,GENERAL_1,GENERAL_2,GENERAL_3,GENERAL_4,CMD_1,CMD_2,CMD_3,CMD_4,IPROG,WRITE_CMD);
signal current_s, next_s : state_type;
signal temp_led_arr : std_logic_vector(4 downto 0);
signal clk_divd_tmp1 : std_logic;
signal clk_divd_tmp2 : std_logic;
signal clk_divd_tmp3 : std_logic;
signal clk_divd_tmp4 : std_logic;
signal clk_divd_tmp5 : std_logic;
signal clk_divd_tmp6 : std_logic;
signal clk_divd_tmp7 : std_logic;
signal clk_divd_tmp8 : std_logic;
signal clk_divd_tmp9 : std_logic;
signal clk_divd_tmp10 : std_logic;
signal clk_divd_tmp11 : std_logic;
signal clk_divd_tmp12 : std_logic;
signal clk_icap : std_logic := '0';

begin
	--led_arr(1) <='0';
	--led_arr(2) <='0';
--led_arr(3) <='0';

	--cd41 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_led, clk_out => clk_divd_tmp1);
	--cd42 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp1, clk_out => clk_divd_tmp2);
	--cd43 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp2, clk_out => clk_divd_tmp3);
	--cd44 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp3, clk_out => clk_divd_tmp4);
	--cd45 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp4, clk_out => clk_divd_tmp5);
	--cd46 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp5, clk_out => clk_divd_tmp6);
	--cd47 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp6, clk_out => clk_divd_tmp7);
	--cd48 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp7, clk_out => clk_divd_tmp8);
	--cd49 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp8, clk_out => clk_divd_tmp9);
	--cd410 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp9, clk_out => clk_divd_tmp10);
	--cd411: entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp10, clk_out => clk_divd_tmp11);
	--cd412 : entity work.clkdiv_4(Behavioral) port map (clk_in => clk_divd_tmp11, clk_out => clk_divd_tmp12);
	
	--cd2 : entity work.clkdiv_2(Behavioral) port map (clk_in => clk_led, clk_out => clk_divd);
	--bridge : entity work.spibridge(Behavioral) port map (fl_MISO => fl_MISO1, ard_MISO => ard_MISO1, fl_MOSI => fl_MOSI1, ard_MOSI => ard_MOSI1, ard_SCK => ard_SCK1, fl_SCK => fl_SCK1, ard_CS => ard_CS1, fl_CS => fl_CS1);
	--sm : entity work.statemachine(Behavioral) port map (clk => clk_divd, areset => reset_but, out1=>temp_led_arr);
	
	process(clk)
	begin
		if clk'event and clk = '1' then
			clk_icap <= not clk_icap;
		end if;
	end process;
	
	ic : entity work.icap(Behavioral) port map (clk => clk_icap, areset => arduino_47, status_running => led0);
	--ledco : entity work.ledconn(Behavioral) port map (clk => '1', led_out => LED);
	--LED <= '1';
	--led_arr(4) <= '1';
	--led_arr(3) <= clk_divd;
	--temp_led_arr(1)<= clk_divd_tmp12;
	--temp_led_arr(4)<='1';
	--temp_led_arr(3)<=clk_divd;
	--temp_led_arr(2)<=not clk_divd;
	--led_arr <= temp_led_arr;
	--RESET <= user_reset;
end Behavioral;
