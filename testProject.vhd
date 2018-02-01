library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity testProject is
port 
(
	leds				: out std_logic_vector(3 downto 0) := (others => '0');
	clk_32			: in std_logic;
	clk_50			: in std_logic;
	
	gpio 				: in std_logic_vector(19 downto 0);
	
	-- xmem
	mcu_ad			: in std_logic_vector(7 downto 0);
	mcu_a				: in std_logic_vector(15 downto 8);
	mcu_ale			: in std_logic;
	mcu_wr, mcu_rd	: in std_logic;
	cclk				: in std_logic --;
	
	-- selectmap		: in std_logic_vector(7 downto 0)
);
end testProject;

architecture Behavioral of testProject is
--	signal led0, led1 : std_logic := '0';
	signal counter50_vector, counter32_vector : std_logic_vector(3 downto 0);
	signal counter50_unsigned : unsigned(3 downto 0) := x"1";
	signal counter32_unsigned : unsigned(3 downto 0) := x"1";
	signal counter50 : integer range 0 to 5000000 := 0;
	signal counter32 : integer range 0 to 3200000 := 0;
begin
--	leds(3) <= '1'; --counter50_vector(3);
--	leds(2) <= counter50_vector(2);
--	leds(1) <= '1'; --counter32_vector(1);
--	leds(0) <= counter32_vector(0);

--	leds(0) <= mcu_a(8) xor mcu_a(12) xor mcu_ale  xor selectmap(0) xor selectmap(4); --  xor gpio(0) xor gpio(4) xor gpio(8) xor gpio(12) xor gpio(16);
--	leds(1) <= mcu_a(9) xor mcu_a(13) xor mcu_wr xor selectmap(1) xor selectmap(5); --  xor gpio(1) xor gpio(5) xor gpio(9) xor gpio(13) xor gpio(17);
--	leds(2) <= mcu_a(10) xor mcu_a(14) xor mcu_rd xor selectmap(2) xor selectmap(6); --  xor gpio(2) xor gpio(6) xor gpio(10) xor gpio(14) xor gpio(18);
--	leds(3) <= mcu_a(11) xor mcu_a(15) xor cclk xor selectmap(3) xor selectmap(7); --  xor gpio(3) xor gpio(7) xor gpio(11) xor gpio(15) xor gpio(19);

	leds(0) <= mcu_ad(0) xor mcu_ad(4) xor mcu_a(8) xor mcu_a(12) xor mcu_ale;
	leds(1) <= mcu_ad(1) xor mcu_ad(5) xor mcu_a(9) xor mcu_a(13) xor mcu_wr;
	leds(2) <= mcu_ad(2) xor mcu_ad(6) xor mcu_a(10) xor mcu_a(14) xor mcu_rd;
	leds(3) <= mcu_ad(3) xor mcu_ad(7) xor mcu_a(11) xor mcu_a(15) xor cclk;

	counter50_vector <= std_logic_vector(counter50_unsigned);
	counter32_vector <= std_logic_vector(counter32_unsigned);
	
	process (clk_32) is
		-- variable counter : integer range 0 to 16000000 := 0;
	begin
		if rising_edge(clk_32) then
			if counter32 = 3200000 then
				counter32 <= 0;
				if counter32_unsigned = x"8" then
					counter32_unsigned <= x"1";
				else
					counter32_unsigned <= counter32_unsigned rol 1; -- to_unsigned(counter32_unsigned * 2, counter32_unsigned'length);
				end if;
			else
				counter32 <= counter32 + 1;
			end if;
		end if;
	end process;
	
	process (clk_50) is 
	begin
		if rising_edge(clk_50) then
			if counter50 = 5000000 then
				counter50 <= 0;
				if counter50_unsigned = x"8" then
					counter50_unsigned <= x"1";
				else
					counter50_unsigned <= counter50_unsigned rol 1; --* 2;
				end if;
			else
				counter50 <= counter50 + 1;
			end if;
		end if;
	end process;
	
	

end Behavioral;

