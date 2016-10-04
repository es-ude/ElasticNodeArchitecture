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

		--! SPI
		arduino_0	: out std_logic;
		arduino_1	: out std_logic;
		arduino_2	: out std_logic;
		arduino_3	: in std_logic;

		arduino_4	: out std_logic;
		arduino_5	: in std_logic;
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
		status_out		: out std_ulogic; 	--! Output to indicate activity

		config_sleep	: out std_logic; 	--! Configuration control to cause sleep for energy saving
		task_complete	: in std_logic;		--! Feedback from configuration about task completion
		
		spi_cs		: out std_logic;
		spi_clk		: out std_logic;
		spi_mosi	: out std_logic;
		spi_miso	: in std_logic;


		clk 			: in std_ulogic;	--! Clock 32 MHz
		rx				: in std_logic;
		tx 				: out std_logic;
		button			: in std_logic
	);
end component;

begin

middle: middleware 
	port map(status_out => LED0, config_sleep => Arduino_4, task_complete => Arduino_5, spi_cs => Arduino_0, spi_clk => Arduino_1, spi_mosi => arduino_2, spi_miso => arduino_3, clk => CLK, rx => Arduino_6, tx => Arduino_7, button => Arduino_47);


end architecture;