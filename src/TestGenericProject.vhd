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
         userlogic_done : OUT  std_logic;
         leds : OUT  std_logic_vector(3 downto 0);
         clk : IN  std_logic;
         rx : IN  std_logic;
         tx : OUT  std_logic;
         mcu_ad : INOUT  std_logic_vector(7 downto 0);
         mcu_ale : IN  std_logic;
         mcu_a : IN  std_logic_vector(15 downto 8);
         mcu_rd : IN  std_logic;
         mcu_wr : IN  std_logic
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
   signal userlogic_done : std_logic;
   signal leds : std_logic_vector(3 downto 0);
   signal tx : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
	constant mcu_clk : time := 125 ns;

	signal busy : boolean := true;

BEGIN
	mcu_ad <= mcu_ad_s when mcu_rd = '1' else (others => 'Z');
	
	-- Instantiate the Unit Under Test (UUT)
   uut: genericProject PORT MAP (
          userlogic_done => userlogic_done,
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
		
		wait for clk_period * 2;
--		-- vdp ul
--		write_uint32_t(x"01000000", x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
--		write_uint32_t(x"02000000", x"2304", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
--		write_uint32_t(x"02000000", x"2308", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);

		-- kb ul
		write_uint24_t_ext(x"25fe01", x"2300", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
		write_uint24_t_ext(x"26ff02", x"2303", mcu_ad_s, mcu_a, mcu_ale, mcu_wr);
		wait for clk_period * 256;
		
		wait for clk_period * 4;
		read_uint32_t_ext(x"230C", mcu_ad_s, mcu_a, mcu_ale, mcu_rd);
		
		wait for clk_period * 4;
		
		busy <= false;
      wait;
   end process;

END;
