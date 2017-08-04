----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:51:08 04/24/2017 
-- Design Name: 
-- Module Name:    sramPassthrough - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sramSlave is
	generic
	(
		OFFSET			: unsigned(15 downto 0) := x"2000"
	);
	port
	(
		clk				: in std_logic;
		
		mcu_ad			: in std_logic_vector(7 downto 0);
		mcu_ale			: in std_logic;
		mcu_a				: in std_logic_vector(15 downto 8);
		mcu_rd			: in std_logic;
		mcu_wr			: in std_logic;
		
		-- higher level ports
		address			: out uint16_t;
		data_out			: out uint8_t;
		data_in 			: in uint8_t;
		rd					: out std_logic;
		wr					: out std_logic
	);
	attribute IOB : string;
end sramSlave;

architecture Behavioral of sramSlave is

signal q : std_logic_vector(7 downto 0) := (others => '0');
signal address_s : std_logic_vector(15 downto 0);
signal data : std_logic_vector(7 downto 0);
-- attribute IOB of ad : signal is "TRUE";

begin
	
	-- extra address lines
	--sram_addr(20 downto 16) <= (others => '0');
	
	---- passthrough
	--sram_ce <= '0';
	--sram_we <= mcu_wr;
	--sram_oe <= mcu_rd;
	--sram_addr(7 downto 0) <= q;
	
	-- sram_data <= ad when mcu_rd /= '0' else (others => 'Z');
	-- sram_data <= mcu_ad when mcu_rd = '0' else (others => 'Z');
	-- mcu_ad <= sram_data when mcu_rd /= '0' else (others => 'Z');
	--sram_addr(15 downto 8) <= mcu_a(15 downto 8);

	-- lower address latch
	process (mcu_ale) is 
	begin
		if falling_edge(mcu_ale) then
			address_s <= std_logic_vector(unsigned(mcu_a & mcu_ad) - OFFSET);
		end if;
	end process;
	address <= unsigned(address_s);
	
	-- main process
	process (clk) is 
		variable counter : integer range 0 to 255;
		variable read_data : std_logic_vector(7 downto 0);
		variable led_on : std_logic;
	begin
		if rising_edge(clk) then
			if mcu_rd = '0' then
				-- ad <= data_in;
				rd <= '1';
				wr <= '0';
			elsif mcu_wr = '0' then
				data_out <= unsigned(mcu_ad);
				wr <= '1';
				rd <= '0';
			else
				wr <= '0'; 
				rd <= '0';
			end if;
		end if;
				
	end process;

	
end Behavioral;

