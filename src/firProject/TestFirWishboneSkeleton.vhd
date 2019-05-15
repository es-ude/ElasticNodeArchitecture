-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;
	
	ENTITY TestFirWishboneSkeleton IS
	END TestFirWishboneSkeleton;

	library fpgamiddlewarelibs;
	use fpgamiddlewarelibs.userlogicinterface.all;
	use fpgamiddlewarelibs.procedures.all;

	ARCHITECTURE behavior OF TestFirWishboneSkeleton IS 

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
		
		constant clock_period : time := 20 ns;
		signal sim_busy 		: boolean := true;


	BEGIN

		-- Component Instantiation
		uut: entity work.firWishboneSkeleton(Behavioral)
			port map (clock, reset, busy, rd, wr, data_in, address_in, data_out); -- , '1', open, open, open, '0' );
		
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
			variable data32           : uint32_t;
		BEGIN
			reset <= '1';

			wait for clock_period * 10; -- wait until global set/reset completes
			
			reset <= '0';
			
--			-- set coefficients
--			write_uint16_t(x"0108", to_unsigned(2, 16), address_in, data_in, wr);
--			write_uint16_t(x"057D", to_unsigned(4, 16), address_in, data_in, wr);
--			write_uint16_t(x"0D02", to_unsigned(6, 16), address_in, data_in, wr);
--			write_uint16_t(x"0D02", to_unsigned(8, 16), address_in, data_in, wr);
--			write_uint16_t(x"057D", to_unsigned(10, 16), address_in, data_in, wr);
--			write_uint16_t(x"0108", to_unsigned(12, 16), address_in, data_in, wr);

			-- write one input
			write_uint16_t(to_unsigned(1, 16), to_unsigned(0, 16), address_in, data_in, wr);
			-- read its output
			read_uint32_t(to_unsigned(0, 16), address_in, rd, data_out, data32);

			write_uint16_t(to_unsigned(0, 16), to_unsigned(0, 16), address_in, data_in, wr);
			-- read its output
			read_uint32_t(to_unsigned(0, 16), address_in, rd, data_out, data32);

			-- write a bunch of zeros
			for i in 0 to 30 loop
				write_uint16_t(to_unsigned(0, 16), to_unsigned(0, 16), address_in, data_in, wr);
			end loop;
			-- read its output
			for i in 0 to 32 loop
				read_uint32_t(to_unsigned(0, 16), address_in, rd, data_out, data32);
			end loop;
				-- procedure read_uint32_t(constant address : uint16_t; signal address_out : out uint16_t; signal rd : out std_logic; signal data_out : in uint8_t; data : out uint32_t);

			-- result
			-- wait until done = '1';
			
			wait for clock_period * 4;
			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;