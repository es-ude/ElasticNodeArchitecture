library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
--!
--! @brief      Wrapping class for the Papilio DUO
--!
entity papilioDuoProject is
	port 
	(
		user_reset	: in std_logic; -- SW1
	
		arduino_13 	: out std_ulogic;	--! Pin D13 (connected to onboard LED)
		arduino_11	: out std_logic;
		CLK 			: in std_ulogic;	--! PLL clock signal @ 32 MHz
		ICAP_CLK 			: in std_ulogic;	--! PLL clock signal @ 20 MHz

		--! SPI
--		arduino_0	: out std_logic;
--		arduino_1	: out std_logic;
--		arduino_2	: out std_logic;
--		arduino_3	: in std_logic;

		arduino_4	: out std_logic;
		arduino_5	: out std_logic;
		arduino_6	: in std_logic;
		arduino_7	: out std_logic;

		arduino_16	: out std_logic;
		arduino_17	: out std_logic;

		arduino_18	: out std_logic;
		arduino_19	: out std_logic;
		arduino_20	: out std_logic;
		arduino_21	: out std_logic;

		arduino_22	: out std_logic;
		arduino_23	: out std_logic;
		arduino_24	: out std_logic;
		arduino_26	: out std_logic;
		arduino_28	: out std_logic;

		arduino_47 	: in std_logic--;		--! Pin D47,
		
		-- flash access
--		spi_cs		: out std_logic;
--		spi_sck		: out std_logic;
--		spi_miso		: in std_logic;
--		spi_mosi		: out std_logic
	);
end entity;

architecture arch of papilioDuoProject is 

--!
--! @brief      Wrapping class that allows instantiation of the 
--! 			middleware component on the Papilio DUO hardware
--!

begin

proj: entity work.genericProject(Behavioral)
	port map(
		-- spi_en => arduino_13, 
		-- uart_en => Arduino_11,
		
		config_sleep => Arduino_4, 
		task_complete => Arduino_5,
		
		userlogic_rdy => Arduino_17,
		userlogic_done	=> Arduino_16,

--		spi_switch => user_reset,
--		flash_cs => spi_cs, 
--		flash_sck => spi_sck, 
--		flash_mosi => spi_mosi, 
--		flash_miso => spi_miso, 
--				
--		ext_cs => Arduino_0, 
--		ext_sck => Arduino_1, 
--		ext_mosi => arduino_2, 
--		ext_miso => arduino_3, 
		
		rec_state_leds(3) => arduino_21,
		rec_state_leds(2) => arduino_20,
		rec_state_leds(1) => arduino_19,
		rec_state_leds(0) => arduino_18,
		
		send_state_leds(3) => arduino_22,
		send_state_leds(2) => arduino_24,
		send_state_leds(1) => arduino_26,
		send_state_leds(0) => arduino_28,
		
		status_out => arduino_23,
		
		clk => CLK, 
		icap_clk => ICAP_CLK, 
		rx => Arduino_6, 
		tx => Arduino_7, 
		button => Arduino_47
	);


end architecture;