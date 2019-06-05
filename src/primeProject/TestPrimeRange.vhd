-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library prime;
use prime.Prime;

ENTITY TestPrimeRange IS
END TestPrimeRange;


library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

ARCHITECTURE behavior OF TestPrimeRange IS 

	-- control interface
	signal clock			: std_logic := '0';
	signal reset			: std_logic := '0';
	signal enable			: std_logic := '0'; -- controls functionality (sleep)
	signal run				: std_logic; -- indicates the beginning and end
	signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
	
	-- data control interface
	signal inputReady, outputReady, outputAck, done		: std_logic;
	
	-- data interface
	signal startQuery, endQuery, outputValue			: int16_t;
	
	constant clock_period : time := 100 ns;
	signal sim_busy 		: boolean := true;
BEGIN

	-- Component Instantiation
	uut: entity prime.PrimeRange(Behavioral)
		port map (clock, reset, startQuery, endQuery, inputReady, outputValue, outputReady, outputAck, done);
	
	
	clock_process : process
	begin
		if sim_busy then
			wait for clock_period;
			clock <= not clock;
		else
			wait;
		end if;
	end process;

	--  Test Bench Statements
	tb : PROCESS
	BEGIN
		enable <= '1';
		inputReady <= '0';
		reset <= '1';
		wait for 200 ns; -- wait until global set/reset completes
		reset <= '0';
		outputAck <= '0';
	
		wait for clock_period * 4;

		-- startQuery <= to_signed(15, 16);
		-- endQuery <= to_signed(20, 16);
		-- inputReady <= '1';
		-- wait for clock_period * 4;
		-- inputReady <= '0';
		-- wait until outputReady = '1';
		-- wait for clock_period * 4;
		-- assert outputValue = to_signed(17,16);
		-- outputAck <= '1';
		-- wait for clock_period * 4;
		-- outputAck <= '0';
		-- wait until outputReady = '1';
		-- wait for clock_period * 4;
		-- assert outputValue = to_signed(19,16);
		-- outputAck <= '1';
		-- wait for clock_period * 4;
		-- outputAck <= '0';
		-- wait for clock_period * 16;

		-- startQuery <= to_signed(8, 16);
		-- endQuery <= to_signed(10, 16);
		-- inputReady <= '1';
		-- wait for clock_period * 4;
		-- inputReady <= '0';
		-- wait until done = '1';

		startQuery <= to_signed(17, 16);
		endQuery <= to_signed(50, 16);
		inputReady <= '1';
		wait for clock_period * 4;
		inputReady <= '0';
		wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(17,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1'; -- already ready
		wait for clock_period * 4;
		assert outputValue = to_signed(19,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(23,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(29,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(31,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(37,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(39,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(41,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(43,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		wait for clock_period * 4;
		assert outputValue = to_signed(47,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		wait for clock_period * 4;
		assert outputValue = to_signed(47,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		wait for clock_period * 4;
		assert outputValue = to_signed(47,16);
		outputAck <= '1';
		wait for clock_period * 2;
		outputAck <= '0';
		-- wait until outputReady = '1';
		-- wait for clock_period * 4;
		-- assert outputValue = to_signed(49,16);
		-- outputAck <= '1';
		-- wait for clock_period * 2;
		-- outputAck <= '0';

		wait for clock_period * 16;


		-- wait for clock_period * 4;
		-- assert outputValue = to_signed(17,16);
		-- outputAck <= '1';
		-- wait for clock_period * 4;
		-- outputAck <= '0';
		-- wait until outputReady = '1';
		-- wait for clock_period * 4;
		-- assert outputValue = to_signed(19,16);
		-- outputAck <= '1';
		-- wait for clock_period * 4;
		-- outputAck <= '0';


		-- query <= to_signed(13, 16);
		-- inputReady <= '1';
		-- wait for clock_period * 4;
		-- inputReady <= '0';
		-- wait until resultReady = '1';
		-- assert result = to_signed(13,16);


		
		enable <= '0';
		wait for 2 * clock_period;

		sim_busy <= false;

		wait; -- will wait forever
	END PROCESS tb;
	--  End Test Bench 

END;
