-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;

	library work;
	use work.MatrixMultiplication;
	
	ENTITY TestMatrixMultiplicationSkeleton IS
	END TestMatrixMultiplicationSkeleton;

	library fpgamiddlewarelibs;
	use fpgamiddlewarelibs.userlogicinterface.all;

	ARCHITECTURE behavior OF TestMatrixMultiplicationSkeleton IS 

		-- control interface
		signal clock			: std_logic := '0';
		signal reset			: std_logic; -- controls functionality (sleep)
		signal run				: std_logic; -- indicates the beginning and end
		signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
		signal done				: std_logic; 
		
		-- data control interface
		signal rd				: std_logic;
		signal wr				: std_logic;
		
		-- data interface
		signal address_in		: uint16_t;
		signal data_in			: uint8_t;
		signal data_out		: uint8_t;
		
		constant clock_period : time := 100 ns;
		signal sim_busy 		: boolean := true;
	BEGIN

		-- Component Instantiation
		uut: entity work.MatrixMultiplicationSkeleton(Behavioral)
			port map (clock, reset, done, rd, wr, data_in, address_in, data_out);
		
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
			reset <= '1';

			wait for 200 ns; -- wait until global set/reset completes
			
			reset <= '0';
			
			
--			-- N
--			wait until ready = '1';
--			wait for clock_period;
--			--data_in <= std_logic_vector(to_unsigned(2, 32));
--			data_in_rdy <= '1';
--			-- wait for clock_period * 2;
--
--			-- input A
--			-- row 1
--			data_in <= std_logic_vector(to_unsigned(0, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(1, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(4, 32));
--			wait for clock_period * 2;
--			-- row 2
--			data_in <= std_logic_vector(to_unsigned(2, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(0, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(1, 32));
--			wait for clock_period * 2;
--			-- row 3
--			data_in <= std_logic_vector(to_unsigned(1, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(5, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(0, 32));
--			wait for clock_period * 2;
--			-- row 4
--			data_in <= std_logic_vector(to_unsigned(1, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(1, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(0, 32));
--			wait for clock_period * 2;
--			
--			-- input B
--			-- row 1
--			data_in <= std_logic_vector(to_unsigned(0, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(1, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(4, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(2, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(7, 32));
--			wait for clock_period * 2;
--			-- row 2
--			data_in <= std_logic_vector(to_unsigned(0, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(1, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(3, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(2, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(4, 32));
--			wait for clock_period * 2;
--			-- row 3
--			data_in <= std_logic_vector(to_unsigned(0, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(2, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(3, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(4, 32));
--			wait for clock_period * 2;
--			data_in <= std_logic_vector(to_unsigned(5, 32));
--			wait for clock_period * 2;
--			data_in_rdy <= '0';
			
			-- result
			-- wait until ready = '1';

			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;
