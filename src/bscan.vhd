----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:31:59 03/27/2018 
-- Design Name: 
-- Module Name:    bscan - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bscan is
port (
	-- CLOCKS
	CLK_32			: in std_logic;

	-- LEDs
	leds				: out std_logic_vector(3 downto 0) := (others => '0');


	-- SPI Flash
	flash_sck		: out std_logic;
	flash_miso		: in std_logic;
	flash_mosi		: out std_logic;
	flash_wp			: out std_logic;
	flash_ce 		: out std_logic;
	flash_hold		: out std_logic;

	-- SPI MCU
	mcu_sck			: in std_logic;
	mcu_miso			: out std_logic;
	mcu_mosi			: in std_logic;
	mcu_ce			: in std_logic
);
end bscan;

architecture Behavioral of bscan is
	signal leds_s : std_logic_vector(3 downto 0) := "1000"; 
	signal mcu_ce_s, mcu_mosi_s, mcu_miso_s, mcu_sck_s : std_logic;
begin

process (clk_32)
	variable leds_counter : integer range 0 to 5000000 := 0;
begin
	if rising_edge(clk_32) then
		leds_counter := leds_counter + 1;
		if leds_counter = 5000000 then
			leds_s <= std_logic_vector(shift_right(unsigned(leds_s), 1));
			if leds_s = "0000" then 
				leds_s <= "1000";
			end if;
		end if;
		mcu_ce_s <= mcu_ce;
		mcu_mosi_s <= mcu_mosi;
		mcu_miso_s <= flash_miso;
		mcu_sck_s <= mcu_sck;
		
	end if;
end process;

	leds <= leds_s;
	
	flash_sck <= mcu_sck_s;
	flash_mosi <= mcu_mosi_s;
	mcu_miso <= mcu_miso_s;
	flash_ce <= mcu_ce_s;
	
	flash_wp <= '1';
	flash_hold <= '1';

end Behavioral;

