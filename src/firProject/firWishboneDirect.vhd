----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:29:45 08/10/2018 
-- Design Name: 
-- Module Name:    firWishbone - Behavioral 
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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity firWishbone is
	port(
		-- generic interface
		clk				: in std_logic;
		reset 			: in std_logic;
		
		-- streaming interface
		dataIn			: in int16_t;
		dataInValid		: in std_logic;
		dataOut			: out int32_t;
		dataOutValid	: out std_logic
	);
end firWishbone;

architecture Behavioral of firWishbone is

signal filterClock : std_logic;
signal dataOutSignal : int32_t;

begin
filter : entity work.fir(rtl)
	port map (reset, filterClock, dataIn, dataOutSignal);

	dataOut <= dataOutSignal;
	filterClock <= clk and dataInValid and not reset;
	
dataoutvalidprocess: 
	process(clk) is
	begin
		if rising_edge(clk) then
			dataOutValid <= dataInValid;
		end if;
	end process;

end Behavioral;

