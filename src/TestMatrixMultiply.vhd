-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;

	library work;
	use work.MatrixMultiplication;
	
	ENTITY TestMatrixMultiplication IS
	END TestMatrixMultiplication;



	ARCHITECTURE behavior OF TestMatrixMultiplication IS 

		-- control interface
		signal clock			: std_logic := '0';
		signal enable			: std_logic; -- controls functionality (sleep)
		signal run				: std_logic; -- indicates the beginning and end
		signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
		signal done				: std_logic; 
		
		-- data control interface
		signal data_out_rdy	: std_logic;
		signal data_out_done	: std_logic;
		signal data_in_rdy	: std_logic := '0';
		
		-- data interface
		signal data_in			: std_logic_vector(31 downto 0);
		signal data_out		: std_logic_vector(31 downto 0);
		
		constant clock_period : time := 100 ns;
		signal sim_busy 		: boolean := true;
	BEGIN

		-- Component Instantiation
		uut: entity work.MatrixMultiplication(Behavioral)
			port map (clock, enable, ready, done, data_out_rdy, data_out_done, data_in_rdy, data_in, data_out);
		
		uart_process : process
			variable count : integer range 0 to 10;
		begin
			if sim_busy then
				wait until data_out_rdy = '1';
				while data_out_rdy = '1' loop
					wait for clock_period * 10;
					data_out_done <= '1';
					wait for clock_period * 2;
					data_out_done <= '0';
				end loop;
			else
				wait;
			end if;
		end process;
		
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
			
			-- N
			wait until ready = '1';
			wait for clock_period;
			--data_in <= std_logic_vector(to_unsigned(2, 32));
			data_in_rdy <= '1';
			-- wait for clock_period * 2;

			-- input A
			-- row 1
			data_in <= std_logic_vector(to_unsigned(0, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(1, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(4, 32));
			wait for clock_period * 2;
			-- row 2
			data_in <= std_logic_vector(to_unsigned(2, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(0, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(1, 32));
			wait for clock_period * 2;
			-- row 3
			data_in <= std_logic_vector(to_unsigned(1, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(5, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(0, 32));
			wait for clock_period * 2;
			-- row 4
			data_in <= std_logic_vector(to_unsigned(1, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(1, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(0, 32));
			wait for clock_period * 2;
			
			-- input B
			-- row 1
			data_in <= std_logic_vector(to_unsigned(0, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(1, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(4, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(2, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(7, 32));
			wait for clock_period * 2;
			-- row 2
			data_in <= std_logic_vector(to_unsigned(0, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(1, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(3, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(2, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(4, 32));
			wait for clock_period * 2;
			-- row 3
			data_in <= std_logic_vector(to_unsigned(0, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(2, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(3, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(4, 32));
			wait for clock_period * 2;
			data_in <= std_logic_vector(to_unsigned(5, 32));
			wait for clock_period * 2;
			data_in_rdy <= '0';
			
			-- result
			wait until ready = '1';

			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;
