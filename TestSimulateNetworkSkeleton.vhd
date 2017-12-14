-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;
	
	library neuralnetwork;
	
	ENTITY TestNetworkSkeleton IS
	END TestNetworkSkeleton;

	library fpgamiddlewarelibs;
	use fpgamiddlewarelibs.userlogicinterface.all;
	use fpgamiddlewarelibs.procedures.all;

	ARCHITECTURE behavior OF TestNetworkSkeleton IS 

		-- control interface
		signal clock			: std_logic := '0';
		signal reset			: std_logic; -- controls functionality (sleep)
		signal run				: std_logic; -- indicates the beginning and end
		signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
		signal done				: std_logic; 
		
		-- data control interface
		signal rd				: std_logic := '1';
		signal wr				: std_logic := '1';
		
		-- data interface
		signal address_in		: uint16_t;
		signal data_in			: uint8_t;
		signal data_out		: uint8_t;
		
		constant clock_period : time := 20 ns;
		signal sim_busy 		: boolean := true;
	BEGIN

		-- Component Instantiation
		uut: entity neuralnetwork.NetworkSkeleton(Behavioral)
			generic map (1) port map (clock, reset, done, rd, wr, data_in, address_in, data_out);
		
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
		BEGIN
			reset <= '1';

			wait for clock_period * 100; -- wait until global set/reset completes
			
			reset <= '0';
			
			for i in 0 to 1000 loop
				wait for clock_period * 20; -- wait until global set/reset completes
				
				-- inputs
				write_uint8_t(3, x"0000", address_in, data_in, wr); -- connections in
				write_uint8_t(4, x"0001", address_in, data_in, wr); -- wanted
				write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
				write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
				-- wait until done = '1';
				wait for clock_period * 20;
				-- write_uint8_t(0, x"0002", address_in, data_in, wr); -- wanted
				
				-- wait until done = '1';
				
				-- outputs
				read_uint8_t(x"0100", address_in, rd);
				read_uint8_t(x"0101", address_in, rd);
				read_uint8_t(x"0102", address_in, rd);
				read_uint8_t(x"0103", address_in, rd);
			end loop;
			
			wait for clock_period * 4;
			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;
