-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;
	
	ENTITY TestPrimeSkeleton IS
	END TestPrimeSkeleton;

	library fpgamiddlewarelibs;
	use fpgamiddlewarelibs.userlogicinterface.all;
	use fpgamiddlewarelibs.procedures.all;

	library prime;
	use prime.primeSkeleton;

	ARCHITECTURE behavior OF TestPrimeSkeleton IS 

		-- control interface
		signal clock			: std_logic := '0';
		signal reset			: std_logic; -- controls functionality (sleep)
		signal run				: std_logic; -- indicates the beginning and end
		signal ready 			: std_logic := '0'; -- indicates the device is ready to begin
		signal done				: std_logic; 
		
		-- data control interface
		signal rd				: std_logic := '0';
		signal wr				: std_logic := '0';
		
		-- data interface
		signal address_in		: uint16_t;
		signal data_in			: uint8_t;
		signal data_out			: uint8_t;

		-- signal data 			: int16_t;
		
		constant clock_period : time := 20 ns;
		signal sim_busy 		: boolean := true;
	BEGIN

		-- Component Instantiation
		uut: entity prime.primeSkeleton(Behavioral)
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
			variable address : uint16_t := (others => '0');
			variable data : int16_t;
			variable data8 : uint8_t;
		BEGIN
			reset <= '1';

			wait for clock_period * 2; -- wait until global set/reset completes
			
			reset <= '0';
			
			-- write start query
			write_uint16_t(to_unsigned(10, 16), to_unsigned(0, 16), address_in, data_in, wr);
			-- write start query
			write_uint16_t(to_unsigned(20, 16), to_unsigned(2, 16), address_in, data_in, wr);
			-- begin
			write_uint8_t(x"01", to_unsigned(4, 16), address_in, data_in, wr);
			write_uint8_t(x"00", to_unsigned(4, 16), address_in, data_in, wr);
			
			-- result
			-- wait until done = '1';
			wait for clock_period * 128;

			-- check data available
			read_uint8_t(to_unsigned(4, 16), address_in, rd, data_out, data8);
			assert data8(1) = '1';

			-- check outputs
			read_int16_t(to_unsigned(5, 16), address_in, rd, data_out, data);
			assert data = to_signed(11, 16);
			read_int16_t(to_unsigned(5, 16), address_in, rd, data_out, data);
			assert data = to_signed(13, 16);
			read_int16_t(to_unsigned(5, 16), address_in, rd, data_out, data);
			assert data = to_signed(17, 16);
			read_int16_t(to_unsigned(5, 16), address_in, rd, data_out, data);
			assert data = to_signed(19, 16);
			
			-- check done
			read_uint8_t(to_unsigned(4, 16), address_in, rd, data_out, data8);
			assert data8(2) = '1';

			wait for clock_period * 128;
			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;