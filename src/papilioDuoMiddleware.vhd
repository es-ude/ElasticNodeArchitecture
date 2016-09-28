library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--!
--! @brief      Wrapping class for the Papilio DUO
--!
entity papilioDuoMiddleware is
	port 
	(
		LED0 		: out std_ulogic;	--! Pin D13 (connected to onboard LED)
		CLK 		: in std_ulogic;	--! PLL clock signal @ 32 MHz
		arduino_6	: in std_logic;
		arduino_7	: out std_logic;
		arduino_47 	: in std_logic		--! Pin D47,
	);
end entity;

architecture arch of papilioDuoMiddleware is 

--!
--! @brief      Wrapping class that allows instantiation of the 
--! 			middleware component on the Papilio DUO hardware
--!
component middleware is
	port (
		status_out	: out std_ulogic;
		clk 		: in std_ulogic;
		rx			: in std_logic;
		tx 			: out std_logic;
		button	 	: in std_logic
	);
end component;

begin

middle: middleware port map(LED0, CLK, arduino_6, arduino_7, arduino_47);

end architecture;