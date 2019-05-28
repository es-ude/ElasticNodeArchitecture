-- TestBench Template 

	LIBRARY ieee;
	USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;
	use ieee.std_logic_unsigned.all;
	
	library neuralnetwork;
	use neuralnetwork.all;
    use neuralnetwork.common.all; 
    
	
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
		
		-- sram interface
		signal ext_sram_addr                : std_logic_vector(hw_sram_addr_width-1 downto 0);
        signal ext_sram_data                : std_logic_vector(hw_sram_data_width-1 downto 0);
        signal ext_sram_cs_1                : std_logic;
        signal ext_sram_cs_2                : std_logic;
        signal ext_sram_output_enable       : std_logic;
        signal ext_sram_write_enable        : std_logic;
        signal ext_sram_upper_byte_select   : std_logic;
        signal ext_sram_lower_byte_select   : std_logic;
		
		constant clock_period 	: time := 20 ns;
		signal sim_busy 		: boolean := true;

	BEGIN

		-- Component Instantiation
		uut: entity neuralnetwork.SignedANNSkeleton(Behavioral)
			generic map (1, hw_sram_addr_width, hw_sram_data_width) port map (
			clock => clock, 
			reset => reset, 
			busy => busy, 
			rd => rd, 
			wr => wr, 
			data_in => data_in, 
			address_in => address_in, 
			data_out => data_out, 
			
			ext_sram_addr => ext_sram_addr,
			ext_sram_data => ext_sram_data,
			ext_sram_cs_1 => ext_sram_cs_1,
			ext_sram_cs_2 => ext_sram_cs_2,
			ext_sram_output_enable => ext_sram_output_enable,
			ext_sram_write_enable => ext_sram_write_enable,
			ext_sram_upper_byte_select => ext_sram_upper_byte_select,
			ext_sram_lower_byte_select => ext_sram_lower_byte_select
			);
			
		-- soft Sram instaniation
		mSoftSRAM: entity neuralnetwork.SoftSRAM 
		generic map (
            16, 24)
		port map(
                address => ext_sram_addr,
                data_io => ext_sram_data,
                cs_1 => ext_sram_cs_1,
                cs_2 => ext_sram_cs_2,
                output_enable => ext_sram_output_enable,
                write_enable => ext_sram_write_enable,
                upper_byte_select => ext_sram_upper_byte_select,
                lower_byte_select => ext_sram_upper_byte_select
            );
		
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

			wait for clock_period * 32; -- wait until global set/reset completes

			reset <= '0';

            -- restet weights
            write_uint8_t(16, x"0007", address_in, data_in, wr); -- restet weights
            wait for clock_period * 400;
            write_uint8_t(0, x"0007", address_in, data_in, wr);  -- disable restet weights function
            wait for clock_period * 10;

--			-- request storing of weights
--			write_uint8_t(123456, x"0004", address_in, data_in, wr); -- connections in
--			write_uint8_t(1, x"0007", address_in, data_in, wr); -- connections in

--			wait for clock_period * 16;

--			wait for 350 us;
			
			
			
			--write_uint8_t(0, x"0007", address_in, data_in, wr); -- connections in

			--wait for clock_period * 3000;




--			read_uint8_t(x"0007", address_in, rd, data_out, data);

--			write_uint8_t(0, x"0007", address_in, data_in, wr); -- connections in

--			write_uint8_t(0, x"0007", address_in, data_in, wr); -- connections in

--			wait for clock_period * 16;



			for i in 0 to 2000 loop
				wait for clock_period * 2; -- wait until global set/reset completes
				
				-- inputs
				write_uint8_t(3, x"0000", address_in, data_in, wr); -- connections in
				write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
				write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
--				wait for clock_period * 2; -- wait connection_in to be saved in SRAM
				write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
				wait until busy = '0';
				wait for clock_period * 2;

				write_uint8_t(1, x"0000", address_in, data_in, wr); -- connections in
				write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
				write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
--				wait for clock_period * 2; -- wait connection_in to be saved in SRAM
				write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
				wait until busy = '0';
				wait for clock_period * 2;
				
				write_uint8_t(0, x"0000", address_in, data_in, wr); -- connections in
				write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
				write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
--				wait for clock_period * 2; -- wait connection_in to be saved in SRAM
				write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
				wait until busy = '0';
				wait for clock_period * 2;
				
				write_uint8_t(2, x"0000", address_in, data_in, wr); -- connections in
				write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
				write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
--				wait for clock_period * 2; -- wait connection_in to be saved in SRAM
				write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
				
				wait until busy = '0';
				wait for clock_period * 2;
			end loop;

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
