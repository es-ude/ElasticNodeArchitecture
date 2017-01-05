LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
library work;
use work.mat_ply.all;

ENTITY mat_tb IS
END mat_tb;

ARCHITECTURE behavior OF mat_tb IS
	--signals declared and initialized to zero.
	signal clk : std_logic := '0';
	signal a : t1:=(others => (others => (others => '0')));
	signal b : t2:=(others => (others => (others => '0')));
	signal x: unsigned(15 downto 0):=(others => '0'); --temporary variable
	signal prod : t3:=(others => (others => (others => '0')));
	-- Clock period definitions
	constant clk_period : time := 1 ns;
	
	signal busy : boolean := true;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut: entity work.test_mat PORT MAP (clk, a, b, prod);

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
		--first set of inputs..
		a <= ((x,x+1,x+4),(x+2,x,x+1),(x+1,x+5,x),(x+1,x+1,x));
		b <= ((x,x+1,x+4,x+2,x+7),(x,x+1,x+3,x+2,x+4),(x,x+2,x+3,x+4,x+5));
		wait for 2 ns;
		busy <= false;
		wait;
		--second set of inputs can be given here and so on.
	end process;

END;