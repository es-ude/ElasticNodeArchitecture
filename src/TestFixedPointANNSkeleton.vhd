-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;
	
	library neuralnetwork;
	use neuralnetwork.common.all;
	
	ENTITY TestFixedPointANNSkeleton IS
	END TestFixedPointANNSkeleton;

	library fpgamiddlewarelibs;
	use fpgamiddlewarelibs.userlogicinterface.all;
	use fpgamiddlewarelibs.procedures.all;

	ARCHITECTURE behavior OF TestFixedPointANNSkeleton IS 

		-- control interface
		signal clock			: std_logic := '0';
		signal reset			: std_logic; -- controls functionality (sleep)
		signal run				: std_logic; -- indicates the beginning and end
		signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
		signal done				: std_logic; 
		signal busy 			: std_logic;
		
		-- data control interface
		signal rd				: std_logic := '1';
		signal wr				: std_logic := '1';
		
		-- data interface
		signal address_in		: uint16_t;
		signal data_in			: uint8_t;
		signal data_out			: uint8_t;

		constant clock_period : time := 20 ns;
		signal sim_busy 		: boolean := true;

		signal results			: fixed_point_vector;
		signal errors			: fixed_point;
	BEGIN

		-- Component Instantiation
		uut: entity neuralnetwork.FixedPointANNSkeleton(Behavioral)
			generic map (1) port map (clock, reset, busy, rd, wr, data_in, address_in, data_out);
		
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
			variable address : uint16_t := (others => '0');
			variable data_fp : fixed_point; 
			variable error_fp : fixed_point;
			--variable data_uint8		: uint8_t;
		BEGIN
			reset <= '1';

			wait for clock_period * 20; -- wait until global set/reset completes
			
			reset <= '0';
			
			for i in 0 to 4000 loop
				wait for clock_period * 2; -- wait until global set/reset completes
				
				-- inputs
				-- connections in
				write_fixed_point16_t(0.0, x"0000", address_in, data_in, wr); 
				write_fixed_point16_t(0.0, x"0002", address_in, data_in, wr); 
				-- wanted
				write_fixed_point16_t(0.0, x"0004", address_in, data_in, wr); 
				write_uint8_t(1, x"0006", address_in, data_in, wr); -- control
				write_uint8_t(1, x"0007", address_in, data_in, wr); -- start
				
				wait until busy = '0';
				read_fixed_point16_t(x"0002", address_in, rd, data_out, error_fp);
				errors <= error_fp;
				wait for clock_period * 2;

				-- connections in
				write_fixed_point16_t(0.0, x"0000", address_in, data_in, wr); 
				write_fixed_point16_t(1.0, x"0002", address_in, data_in, wr); 
				-- wanted
				write_fixed_point16_t(1.0, x"0004", address_in, data_in, wr); 
				write_uint8_t(1, x"0006", address_in, data_in, wr); -- control
				write_uint8_t(1, x"0007", address_in, data_in, wr); -- start
				
				wait until busy = '0';
				read_fixed_point16_t(x"0002", address_in, rd, data_out, error_fp);
				errors <= error_fp;
				wait for clock_period * 2;
				
				-- connections in
				write_fixed_point16_t(1.0, x"0000", address_in, data_in, wr); 
				write_fixed_point16_t(1.0, x"0002", address_in, data_in, wr); 
				-- wanted
				write_fixed_point16_t(0.0, x"0004", address_in, data_in, wr); 
				write_uint8_t(1, x"0006", address_in, data_in, wr); -- control
				write_uint8_t(1, x"0007", address_in, data_in, wr); -- start
				
				wait until busy = '0';
				read_fixed_point16_t(x"0002", address_in, rd, data_out, error_fp);
				errors <= error_fp;
				wait for clock_period * 2;
				
				-- connections in
				write_fixed_point16_t(1.0, x"0000", address_in, data_in, wr); 
				write_fixed_point16_t(0.0, x"0002", address_in, data_in, wr); 
				-- wanted
				write_fixed_point16_t(1.0, x"0004", address_in, data_in, wr); 
				write_uint8_t(1, x"0006", address_in, data_in, wr); -- control
				write_uint8_t(1, x"0007", address_in, data_in, wr); -- start
				
				wait until busy = '0';
				read_fixed_point16_t(x"0002", address_in, rd, data_out, error_fp);
				errors <= error_fp;
				wait for clock_period * 2;
			end loop;

			-- check learned results
			-- connections in
			write_fixed_point16_t(1.0, x"0000", address_in, data_in, wr); 
			write_fixed_point16_t(1.0, x"0002", address_in, data_in, wr); 
			-- wanted
			write_fixed_point16_t(0.0, x"0004", address_in, data_in, wr); 
			write_uint8_t(0, x"0006", address_in, data_in, wr); -- control
			write_uint8_t(1, x"0007", address_in, data_in, wr); -- start
			
			wait until busy = '0';
			wait for clock_period * 2;
			
			-- outputs
			read_fixed_point16_t(x"0000", address_in, rd, data_out, data_fp);
			results(0) <= data_fp;
			
			-- check learned results
			-- connections in
			write_fixed_point16_t(0.0, x"0000", address_in, data_in, wr); 
			write_fixed_point16_t(1.0, x"0002", address_in, data_in, wr); 
			-- wanted
			write_fixed_point16_t(1.0, x"0004", address_in, data_in, wr); 
			write_uint8_t(0, x"0006", address_in, data_in, wr); -- control
			write_uint8_t(1, x"0007", address_in, data_in, wr); -- start
			
			wait until busy = '0';
			wait for clock_period * 2;
			
			-- outputs
			read_fixed_point16_t(x"0000", address_in, rd, data_out, data_fp);
			results(1) <= data_fp;
			
			-- check learned results
			-- connections in
			write_fixed_point16_t(0.0, x"0000", address_in, data_in, wr); 
			write_fixed_point16_t(0.0, x"0002", address_in, data_in, wr); 
			-- wanted
			write_fixed_point16_t(0.0, x"0004", address_in, data_in, wr); 
			write_uint8_t(0, x"0006", address_in, data_in, wr); -- control
			write_uint8_t(1, x"0007", address_in, data_in, wr); -- start
			
			wait until busy = '0';
			wait for clock_period * 2;
			
			-- outputs
			read_fixed_point16_t(x"0000", address_in, rd, data_out, data_fp);
			results(2) <= data_fp;
			
			-- check learned results
			-- connections in
			write_fixed_point16_t(1.0, x"0000", address_in, data_in, wr); 
			write_fixed_point16_t(0.0, x"0002", address_in, data_in, wr); 
			-- wanted
			write_fixed_point16_t(1.0, x"0004", address_in, data_in, wr); 
			write_uint8_t(0, x"0006", address_in, data_in, wr); -- control
			write_uint8_t(1, x"0007", address_in, data_in, wr); -- start
			
			wait until busy = '0';
			wait for clock_period * 2;
			
			-- outputs
			read_fixed_point16_t(x"0000", address_in, rd, data_out, data_fp);
			results(3) <= data_fp;
			
			--write_uint8_t(1, x"0000", address_in, data_in, wr); -- connections in
			--write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
			--write_uint8_t(0, x"0002", address_in, data_in, wr); -- control
			--write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
			
			--wait until busy = '0';
			--wait for clock_period * 2;
			
			---- outputs
			--read_uint8_t(x"0002", address_in, rd);
			--data <= data_out;

			--write_uint8_t(0, x"0000", address_in, data_in, wr); -- connections in
			--write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
			--write_uint8_t(0, x"0002", address_in, data_in, wr); -- control
			--write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
			
			--wait until busy = '0';
			--wait for clock_period * 2;
			
			---- outputs
			--read_uint8_t(x"0002", address_in, rd);
			--data <= data_out;

			--write_uint8_t(2, x"0000", address_in, data_in, wr); -- connections in
			--write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
			--write_uint8_t(0, x"0002", address_in, data_in, wr); -- control
			--write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
			
			--wait until busy = '0';
			--wait for clock_period * 2;
			
			---- outputs
			--read_uint8_t(x"0002", address_in, rd);
			--data <= data_out;


			wait for clock_period * 20;
			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;
