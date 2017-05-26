-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

	library fpgamiddlewarelibs;
	use fpgamiddlewarelibs.UserLogicInterface.all;
  
  ENTITY TestDummy IS
  END TestDummy;
  
  

  ARCHITECTURE behavior OF TestDummy IS 

		-- control interface
		signal clock			: std_logic := '0';
		signal enable			: std_logic; -- controls functionality (sleep)
		signal run				: std_logic; -- indicates the beginning and end
		signal ready 			: std_logic; -- indicates the device is ready to begin
		signal done				: std_logic; 
		
		-- data control interface
		signal data_out_rdy	:  std_logic;
		signal data_out_done : std_logic;
		signal data_in_rdy	: std_logic;
		
		-- data interface
		signal data_in			: std_logic_vector(31 downto 0);
		signal data_out		: std_logic_vector(31 downto 0);
		
		constant clock_period : time := 100 ns;
		signal sim_busy 		: boolean := true;
	BEGIN

		-- Component Instantiation
		uut: entity work.Dummy(Behavioral)
			port map (clock, enable, ready, done, data_out_rdy, data_out_done, data_in_rdy, data_in, data_out);
      
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
			wait for 200 ns; -- wait until global set/reset completes
			
			enable <= '1';
			run <= '1';
			
			wait until ready = '1';
			wait for clock_period;
			data_in <= std_logic_vector(to_unsigned(2, 32));
			data_in_rdy <= '1';
			wait for clock_period * 2;
			data_in_rdy <= '0';

			-- result
			wait for clock_period * 10;

			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;