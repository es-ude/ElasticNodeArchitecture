LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;
use fpgamiddlewarelibs.procedures.all;

ENTITY TestGenericProject IS
END TestGenericProject;
 
ARCHITECTURE behavior OF TestGenericProject IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT genericProject
    PORT(
		userlogic_busy	: out std_logic;
		userlogic_sleep: out std_logic;
		
		ARD_RESET 	: out std_logic;
		--		spi_switch	: in std_logic;
		--		flash_cs		: out std_logic;
		--		flash_sck	: out std_logic;
		--		flash_mosi	: out std_logic;
		--		flash_miso	: in std_logic;
		--
		--		ext_cs		: out std_logic;
		--		ext_sck		: out std_logic;
		--		ext_mosi		: out std_logic;
		--		ext_miso		: in std_logic;
		
		leds			: out std_logic_vector(3 downto 0);
		
		clk 			: in std_ulogic;	--! Clock 32 MHz
		rx				: in std_logic;
		tx 			: out std_logic;
		
		-- sram
		mcu_ad		: inout std_logic_vector(7 downto 0) := (others => 'Z');
		mcu_ale		: in std_logic;
		mcu_a		: in std_logic_vector(15 downto 8);
		mcu_rd		: in std_logic;
		mcu_wr		: in std_logic--;
		
		-- kb_leds		: out kb_led_vector
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rx : std_logic := '0';
   signal mcu_ale : std_logic := '0';
   signal mcu_a : std_logic_vector(15 downto 8) := (others => '0');
   signal mcu_rd : std_logic := '1';
   signal mcu_wr : std_logic := '1';

	--BiDirs
   signal mcu_ad : std_logic_vector(7 downto 0);
	signal mcu_ad_s : std_logic_vector(7 downto 0);

 	--Outputs
   signal userlogic_busy : std_logic;
   signal userlogic_sleep : std_logic;
   signal leds : std_logic_vector(3 downto 0);
   signal tx : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
	constant mcu_clk : time := 125 ns;

	signal busy : boolean := true;
	signal waiting : boolean := false;

BEGIN
	mcu_ad <= mcu_ad_s when mcu_rd = '1' else (others => 'Z');
	
	-- Instantiate the Unit Under Test (UUT)
   uut: genericProject PORT MAP (
		userlogic_busy => userlogic_busy,
		userlogic_sleep => userlogic_sleep,
		
		ARD_RESET => open,
		leds => leds,
		
		clk => clk,
		rx => rx,
		tx => tx,
		
		mcu_ad => mcu_ad,
		mcu_ale => mcu_ale,
		mcu_a => mcu_a,
		mcu_rd => mcu_rd,
		mcu_wr => mcu_wr
        );

   -- Clock process definitions
   clk_process :process
   begin
		if busy then
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		else
			wait;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      -- reset <= '1';
		wait for clk_period;
		-- reset <= '0';

      -- insert stimulus here 
		write_uint8_t_ext(x"02", x"2203", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --leds
		write_uint8_t_ext(x"00", x"2204", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- sleep
		
		wait for clk_period * 2;
--		-- vdp ul
--		write_uint32_t_ext(to_unsigned(1, 32), x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
--		write_uint32_t_ext(to_unsigned(2, 32), x"2304", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
--		write_uint32_t_ext(to_unsigned(3, 32), x"2308", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);

--		wait for clk_period * 2;
		
--		read_uint32_t_ext(x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
--		read_uint32_t_ext(x"2304", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
--		read_uint32_t_ext(x"2308", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
--		read_uint32_t_ext(x"230C", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
		
		
--		write_uint8_t_ext(x"03", x"2203", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --leds
--		write_uint8_t_ext(x"01", x"2204", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- sleep
--		write_uint8_t_ext(x"00", x"2204", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- sleep
		
--		wait for clk_period * 2;
		
		-- ann ul
		write_uint8_t_ext(to_unsigned(1, 8), x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- conn_in
		write_uint8_t_ext(to_unsigned(3, 8), x"2301", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- wanted
		write_uint8_t_ext(to_unsigned(1, 8), x"2302", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- control
		
		waiting <= true;
		
		wait for clk_period * 2;
		
		wait until userlogic_busy = '0';
		waiting <= false;
		
		read_uint8_t_ext(x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- conn_in 
		read_uint8_t_ext(x"2301", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- wanted
		read_uint8_t_ext(x"2302", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- control
		read_uint8_t_ext(x"2303", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- conn_out
		
				
		-- ann ul
		write_uint8_t_ext(to_unsigned(1, 8), x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- conn_in
		write_uint8_t_ext(to_unsigned(2, 8), x"2301", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- wanted
		write_uint8_t_ext(to_unsigned(0, 8), x"2302", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- control
		
		wait for clk_period * 2;
		
		read_uint8_t_ext(x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- conn_in 
		read_uint8_t_ext(x"2301", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- wanted
		read_uint8_t_ext(x"2302", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- control
		read_uint8_t_ext(x"2303", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- conn_out
		
		
		write_uint8_t_ext(x"02", x"2203", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --leds

--		-- kb ul
--		write_uint24_t_ext(x"25fe01", x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
--		write_uint24_t_ext(x"26ff02", x"2303", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
--		wait for clk_period * 256;
--		
--		wait for clk_period * 4;
--		read_uint32_t_ext(x"230C", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
		
		wait for clk_period * 4;
		
		busy <= false;
      wait;
   end process;

END;
