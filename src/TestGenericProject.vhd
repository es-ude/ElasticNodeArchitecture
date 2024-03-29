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
    --GENERIC (
    --	reset_delay			: integer
    --	);
    PORT(
		--userlogic_busy	: out std_logic;
		--userlogic_sleep: out std_logic;
		--flash_ce			: out std_logic;
		flash_si			: out std_logic;
		flash_available		: in std_logic;

		leds				: out std_logic_vector(3 downto 0);
		
		clk_32				: in std_ulogic;	--! Clock 32 MHz
		clk_50				: in std_ulogic;
		
		--rx				: in std_logic;
		--tx 			: out std_logic;
		
		-- xmem
		mcu_ad				: inout std_logic_vector(7 downto 0) := (others => 'Z');
		mcu_ale				: in std_logic;
		mcu_a				: in std_logic_vector(14 downto 8);
		mcu_rd				: in std_logic;
		mcu_wr				: in std_logic;
		
		-- gpio
		gpio				: out std_logic_vector(19 downto 0) := (others => '0');

		-- flash
		flash_cs			:	out std_logic;
		cclk_flash_clk		: 	out std_logic;
		--spi_clk				:	out std_logic;
		flash_mosi			:	out std_logic
		--flash_miso			:	in std_logic (ad<7)
		-- kb_leds		: out kb_led_vector
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rx : std_logic := '0';
   signal mcu_ale : std_logic := '0';
   signal mcu_a : std_logic_vector(14 downto 8) := (others => '0');
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
   constant clk_period : time := 31.25 ns;
	constant mcu_clk : time := 83.3333333333333333333 ns;

	signal busy : boolean := true;
	signal waiting : boolean := false;

	signal flash_available, flash_cs, cclk_flash_clk, flash_mosi, flash_si : std_logic;

BEGIN
	mcu_ad <= mcu_ad_s when mcu_rd = '1' else (others => 'Z');
	
	-- Instantiate the Unit Under Test (UUT)
   uut: genericProject 
   --GENERIC MAP (
   --		reset_delay => 100
   --	)
   	 PORT MAP (
--		userlogic_busy => userlogic_busy,
--		userlogic_sleep => userlogic_sleep,
--		
--		ARD_RESET => open,
		flash_si => flash_si,
		flash_available => flash_available,

		leds => leds,
		
		clk_32 => clk,
		clk_50 => clk,
		
		-- selectmap => (others => '0'),
		--cclk => '0',
--		rx => rx,
--		tx => tx,
		
		mcu_ad => mcu_ad,
		mcu_ale => mcu_ale,
		mcu_a => mcu_a,
		mcu_rd => mcu_rd,
		mcu_wr => mcu_wr,
		
		gpio => open,

		cclk_flash_clk => cclk_flash_clk,
		flash_mosi => flash_mosi,
		flash_cs => flash_cs
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
       --reset <= '1';
		wait for clk_period * 100;
		-- reset <= '0';

		-- reset ul
		--write_uint8_t_ext(x"01", x"2004", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --reset
		write_uint8_t_ext(x"00", x"2004", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --reset

		-- test flash
		write_uint24_t_ext(x"3aff01", x"2104", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --flash address
		write_uint8_t_ext(x"02", x"2107", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --flash control
 
		wait for 10 us;
		flash_available <= '1';

		wait for 250 us;
		--wait until uut/ul/nn/flash_ready = '1';
		write_uint8_t_ext(x"00", x"2107", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --flash control
		flash_available <= '0';
		wait for 100 us;

		-- test flash
		write_uint24_t_ext(x"3aff00", x"2104", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --flash address
		write_uint8_t_ext(x"02", x"2107", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --flash control

		wait for 100 us;
		flash_available <= '1';

		wait for 250 us;
		--wait until uut/ul/nn/flash_ready = '1';
		flash_available <= '0';

		read_uint8_t_ext(x"2107", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
		write_uint8_t_ext(x"00", x"2107", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --flash control

		wait for 100 us;
		-- test flash
		write_uint24_t_ext(x"123456", x"2104", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --flash address
		write_uint8_t_ext(x"02", x"2107", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --flash control

		wait for 210 us;
		--wait until uut/ul/nn/flash_ready = '1';

		read_uint8_t_ext(x"2107", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);

		
      -- insert stimulus here 
--		write_uint8_t_ext(x"02", x"2003", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --leds
--		write_uint8_t_ext(x"00", x"2004", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- sleep
		
--		wait for clk_period * 2;
----		-- vdp ul
----		write_uint32_t_ext(to_unsigned(1, 32), x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
----		write_uint32_t_ext(to_unsigned(2, 32), x"2304", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
----		write_uint32_t_ext(to_unsigned(3, 32), x"2308", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);

----		wait for clk_period * 2;
		
----		read_uint32_t_ext(x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
----		read_uint32_t_ext(x"2304", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
----		read_uint32_t_ext(x"2308", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
----		read_uint32_t_ext(x"230C", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
		
		
----		write_uint8_t_ext(x"03", x"2203", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --leds
----		write_uint8_t_ext(x"01", x"2204", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- sleep
----		write_uint8_t_ext(x"00", x"2204", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- sleep
		
----		wait for clk_period * 2;
		
--		-- ann ul
--		write_uint8_t_ext(x"01", x"2100", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- conn_in
--		write_uint8_t_ext(x"AA", x"2101", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- wanted
--		write_uint8_t_ext(x"01", x"2102", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- control
--		write_uint8_t_ext(x"01", x"2103", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- start
		
--		waiting <= true;
		
--		wait for clk_period * 2;
		
--		wait for clk_period*300;

--		waiting <= false;
		
--		read_uint8_t_ext(x"2100", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- conn_in 
--		read_uint8_t_ext(x"2101", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- wanted
--		read_uint8_t_ext(x"2102", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- control
--		read_uint8_t_ext(x"2103", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- conn_out
		
				
--		-- ann ul
--		write_uint8_t_ext(x"01", x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- conn_in
--		write_uint8_t_ext(x"02", x"2301", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- wanted
--		write_uint8_t_ext(x"00", x"2302", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- control
--		write_uint8_t_ext(x"01", x"2103", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); -- start

		
--		wait for 110ns;
		
--		read_uint8_t_ext(x"2100", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- conn_in 
--		read_uint8_t_ext(x"2101", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- wanted
--		read_uint8_t_ext(x"2102", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- control
--		read_uint8_t_ext(x"2103", mcu_ad_s, mcu_a, mcu_ale, mcu_rd); -- conn_out
		
		
--		write_uint8_t_ext(x"02", x"2203", mcu_ad_s, mcu_a, mcu_ale, mcu_wr); --leds

----		-- kb ul
----		write_uint24_t_ext(x"25fe01", x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
----		write_uint24_t_ext(x"26ff02", x"2303", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
----		wait for clk_period * 256;
----		
----		wait for clk_period * 4;
----		read_uint32_t_ext(x"230C", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
		
		wait for clk_period * 4;
		
		busy <= false;
      wait;
   end process;

END;
