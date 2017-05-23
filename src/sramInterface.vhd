----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:27:06 04/28/2017 
-- Design Name: 
-- Module Name:    sramInterface - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- converts async sram interfaces to more useful interface
entity sramInterface is
	port
	(
		
	);
end sramInterface;

architecture Behavioral of sramInterface is

begin

sram: entity work.sramSlave(Behavioral)
generic map 
	(
		x"0000"
	)
	port map
	(
		clk,
		
		mcu_ad,			: inout std_logic_vector(7 downto 0) := (others => 'Z');
		mcu_ale			: in std_logic;
		mcu_a				: in std_logic_vector(15 downto 8);
		mcu_rd			: in std_logic;
		mcu_wr			: in std_logic;
		
		-- higher level ports
		address			: out std_logic_vector(15 downto 0);
		data_out			: out std_logic_vector(7 downto 0); -- for reading from ext ram
		data_in 			: in std_logic_vector(7 downto 0); 	-- for writing to ext ram
		rd					: out std_logic;
		wr					: out std_logic;
		
		leds				: out std_logic_vector(3 downto 0)
	);
	attribute IOB : string;

end Behavioral;

