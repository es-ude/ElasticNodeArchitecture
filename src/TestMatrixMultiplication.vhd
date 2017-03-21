-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;

	library work;
	use work.MatrixMultiplication;
	use work.MatrixMultiplicationPackage;
	
	ENTITY TestMatrixMultiplication IS
	END TestMatrixMultiplication;



	ARCHITECTURE behavior OF TestMatrixMultiplication IS 

		-- control interface
		signal clock			: std_logic := '0';
		signal enable			: std_logic := '0'; -- controls functionality (sleep)
		signal run				: std_logic; -- indicates the beginning and end
		signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
		signal done				: std_logic; 
		
		-- data control interface
		signal data_out_rdy	: std_logic;
		signal data_out_done	: std_logic;
		signal data_in_rdy	: std_logic := '0';
		
		-- data interface
		signal matrixA			: MatrixMultiplicationPackage.inputMatrix1 := (others => (others => (others => '0')));
		signal matrixB			: MatrixMultiplicationPackage.inputMatrix2 := (others => (others => (others => '0')));
		signal matrixC			: MatrixMultiplicationPackage.outputMatrix;
		-- signal data_in			: std_logic_vector(31 downto 0);
		-- signal data_out		: std_logic_vector(31 downto 0);
		
		constant clock_period : time := 100 ns;
		signal sim_busy 		: boolean := true;
	BEGIN

		-- Component Instantiation
		uut: entity work.MatrixMultiplication(Behavioral)
			-- port map (clock, enable, ready, done, data_out_rdy, data_out_done, data_in_rdy, data_in, data_out);
			port map (clock, enable, data_out_rdy, matrixA, matrixB, matrixC);
		
--		uart_process : process
--			variable count : integer range 0 to 10;
--		begin
--			if sim_busy then
--				wait until data_out_rdy = '1';
--				while data_out_rdy = '1' loop
--					wait for clock_period * 10;
--					data_out_done <= '1';
--					wait for clock_period * 2;
--					data_out_done <= '0';
--				end loop;
--			else
--				wait;
--			end if;
--		end process;
		
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
			
			-- enable <= '1';
			-- run <= '1';
			
			-- N
			-- wait until ready = '1';
			wait for clock_period;
			--data_in <= std_logic_vector(to_unsigned(2, 32));
			-- ata_in_rdy <= '1';
			-- wait for clock_period * 2;

			-- input A
--			-- row 1
			matrixA(0)(0) <= to_unsigned(0, 16);
			matrixA(0)(1) <= to_unsigned(1, 16);
			matrixA(0)(2) <= to_unsigned(4, 16);
			matrixA(1)(0) <= to_unsigned(2, 16);
			matrixA(1)(1) <= to_unsigned(0, 16);
			matrixA(1)(2) <= to_unsigned(4, 16);
			matrixA(2)(0) <= to_unsigned(1, 16);
			matrixA(2)(1) <= to_unsigned(5, 16);
			matrixA(2)(2) <= to_unsigned(4, 16);
			matrixA(3)(0) <= to_unsigned(1, 16);
			matrixA(3)(1) <= to_unsigned(1, 16);
			matrixA(3)(2) <= to_unsigned(4, 16);
			
			-- input B
			matrixB(0)(0) <= to_unsigned(0, 16);
			matrixB(0)(1) <= to_unsigned(1, 16);
			matrixB(0)(2) <= to_unsigned(4, 16);
			matrixB(0)(3) <= to_unsigned(2, 16);
			matrixB(0)(4) <= to_unsigned(7, 16);
			matrixB(1)(0) <= to_unsigned(0, 16);
			matrixB(1)(1) <= to_unsigned(1, 16);
			matrixB(1)(2) <= to_unsigned(3, 16);
			matrixB(1)(3) <= to_unsigned(2, 16);
			matrixB(1)(4) <= to_unsigned(4, 16);
			matrixB(2)(0) <= to_unsigned(0, 16);
			matrixB(2)(1) <= to_unsigned(2, 16);
			matrixB(2)(2) <= to_unsigned(3, 16);
			matrixB(2)(3) <= to_unsigned(4, 16);
			matrixB(2)(4) <= to_unsigned(5, 16);
			
			--wait for 2 * clock_period;

			enable <= '1';
			
			-- result
			wait until data_out_rdy = '1';

			enable <= '0';
			wait for 2 * clock_period;

			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;
