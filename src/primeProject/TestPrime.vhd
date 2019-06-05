-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library prime;
use prime.Prime;

ENTITY TestPrime IS
END TestPrime;


library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

ARCHITECTURE behavior OF TestPrime IS 

	-- control interface
	signal clock			: std_logic := '0';
	signal reset			: std_logic := '0';
	signal enable			: std_logic := '0'; -- controls functionality (sleep)
	signal run				: std_logic; -- indicates the beginning and end
	signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
	signal done				: std_logic; 
	
	-- data control interface
	signal data_out_rdy	: std_logic;
	signal data_out_done	: std_logic;
	signal data_in_rdy	: std_logic := '0';
	
	-- data interface
	signal query, result	: int16_t;
	signal queryReady, queryWait, resultReady, ack : std_logic;
	
	constant clock_period : time := 100 ns;
	signal sim_busy 		: boolean := true;
BEGIN

	-- Component Instantiation
	uut: entity prime.Prime(Behavioral)
		port map (clock, reset, query, queryReady, queryWait, result, resultReady, ack);
	
	
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
		queryReady <= '0';
		wait for 200 ns; -- wait until global set/reset completes
		
		wait for clock_period * 4;

		query <= to_signed(15, 16);
		queryReady <= '1';
		wait for clock_period * 4;
		queryReady <= '0';
		wait until resultReady = '1';
		assert result = to_signed(0,16);
		ack <= '1';
		wait for clock_period * 4;
		ack <= '0';

		query <= to_signed(13, 16);
		queryReady <= '1';
		wait for clock_period * 4;
		queryReady <= '0';
		wait until resultReady = '1';
		assert result = to_signed(13,16);


		
		enable <= '0';
		wait for 2 * clock_period;

		sim_busy <= false;

		wait; -- will wait forever
	END PROCESS tb;
	--  End Test Bench 

END;
