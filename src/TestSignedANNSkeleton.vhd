-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;
	
	library neuralnetwork;
	
	ENTITY TestSignedANNSkeleton IS
	END TestSignedANNSkeleton;

	library fpgamiddlewarelibs;
	use fpgamiddlewarelibs.userlogicinterface.all;
	use fpgamiddlewarelibs.procedures.all;

	ARCHITECTURE behavior OF TestSignedANNSkeleton IS 

		-- control interface
		signal clock			: std_logic := '0';
		signal reset			: std_logic; -- controls functionality (sleep)
		signal run				: std_logic; -- indicates the beginning and end
		signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
		signal busy				: std_logic; 
		
		-- data control interface
		signal rd				: std_logic := '1';
		signal wr				: std_logic := '1';
		
		-- data interface
		signal address_in		: uint16_t;
		signal data_in			: uint8_t;
		signal data_out			: uint8_t;
		
		constant clock_period 	: time := 20 ns;
		signal sim_busy 		: boolean := true;

		signal flash_available, spi_cs, spi_clk, spi_mosi, spi_miso : std_logic;--signal data 			: uint8_t;
	BEGIN

		-- Component Instantiation
		uut: entity neuralnetwork.SignedANNSkeleton(Behavioral)
			generic map (2) port map (clock, reset, busy, rd, wr, data_in, address_in, data_out, flash_available, spi_cs, spi_clk, spi_mosi, spi_miso);
		
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
			variable data : uint8_t;
		BEGIN
			reset <= '1';
			flash_available <= '0';
			spi_miso <= '1';

			--wait for clock_period * 32; -- wait until global set/reset completes

			--wait until flash_ready = '1';
			wait for clock_period * 8;

			reset <= '0';

			--wait for clock_period * 10;
			--write_uint8_t(16, x"0007", address_in, data_in, wr); -- connections in
			--wait for clock_period * 32;
			--write_uint8_t(0, x"0007", address_in, data_in, wr); -- connections in
			--wait for clock_period * 10;

			
			wait for clock_period * 20;

			-- request storing of weights
			write_uint24_t(123456, x"0004", address_in, data_in, wr); -- connections in
			write_uint8_t(1, x"0007", address_in, data_in, wr); -- connections in

			wait for clock_period * 16;
			flash_available <= '1';

			wait for 350 us;
			--write_uint8_t(0, x"0007", address_in, data_in, wr); -- connections in

			--wait for clock_period * 3000;
			flash_available <= '0';


			read_uint8_t(x"0007", address_in, rd, data_out, data);

			write_uint8_t(0, x"0007", address_in, data_in, wr); -- connections in

			write_uint8_t(0, x"0007", address_in, data_in, wr); -- connections in

			wait for clock_period * 16;

			--for i in 0 to 4000 loop
			--	wait for clock_period * 2; -- wait until global set/reset completes
				
			--	-- inputs
			--	write_uint8_t(3, x"0000", address_in, data_in, wr); -- connections in
			--	write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
			--	write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
			--	write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
			--	wait until busy = '0';
			--	wait for clock_period * 2;

			--	write_uint8_t(1, x"0000", address_in, data_in, wr); -- connections in
			--	write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
			--	write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
			--	write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
			--	wait until busy = '0';
			--	wait for clock_period * 2;
				
			--	write_uint8_t(0, x"0000", address_in, data_in, wr); -- connections in
			--	write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
			--	write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
			--	write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
			--	wait until busy = '0';
			--	wait for clock_period * 2;
				
			--	write_uint8_t(2, x"0000", address_in, data_in, wr); -- connections in
			--	write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
			--	write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
			--	write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
			--	wait until busy = '0';
			--	wait for clock_period * 2;
			--end loop;

			---- check learned results
			--write_uint8_t(3, x"0000", address_in, data_in, wr); -- connections in
			--write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
			--write_uint8_t(0, x"0002", address_in, data_in, wr); -- control
			--write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
			
			--wait until busy = '0';
			--wait for clock_period * 2;
			
			---- outputs
			--read_uint8_t(x"0002", address_in, rd, data_out, data);
			----data <= data_out;

			--write_uint8_t(1, x"0000", address_in, data_in, wr); -- connections in
			--write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
			--write_uint8_t(0, x"0002", address_in, data_in, wr); -- control
			--write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
			
			--wait until busy = '0';
			--wait for clock_period * 2;
			
			---- outputs
			--read_uint8_t(x"0002", address_in, rd, data_out, data);
			----data <= data_out;

			--write_uint8_t(0, x"0000", address_in, data_in, wr); -- connections in
			--write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
			--write_uint8_t(0, x"0002", address_in, data_in, wr); -- control
			--write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
			
			--wait until busy = '0';
			--wait for clock_period * 2;
			
			---- outputs
			--read_uint8_t(x"0002", address_in, rd, data_out, data);
			----data <= data_out;

			--write_uint8_t(2, x"0000", address_in, data_in, wr); -- connections in
			--write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
			--write_uint8_t(0, x"0002", address_in, data_in, wr); -- control
			--write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
			
			--wait until busy = '0';
			--wait for clock_period * 2;
			
			---- outputs
			--read_uint8_t(x"0002", address_in, rd, data_out, data);
			----data <= data_out;


			wait for clock_period * 4;
			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;
