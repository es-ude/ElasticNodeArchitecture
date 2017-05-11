-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

	library fpgamiddlewarelibs;
	use fpgamiddlewarelibs.UserLogicInterface.all;
  
  ENTITY TestVectorDotproductSkeleton IS
  END TestVectorDotproductSkeleton;
  
  

  ARCHITECTURE behavior OF TestVectorDotproductSkeleton IS 
		-- control interface
		signal clock			: std_logic := '0';
		signal reset			: std_logic := '0'; -- controls functionality (sleep)
		
		signal done				: std_logic; 
		
		-- data control
		signal rd, wr			: std_logic;
		
		-- data interface
		signal data_in			: uint8_t;
		signal address_in		: uint16_t;
		signal data_out		: uint8_t;
		
		constant clock_period : time := 100 ns;
		signal sim_busy 		: boolean := true;
		
		procedure write_uint32_t(constant data : in uint32_t; constant address : in uint16_t; signal address_out : out uint16_t; signal data_out : out uint8_t; signal wr : out std_logic) is
		begin
			wait for clock_period;
			address_out <= address;
			data_out <= data(7 downto 0);
			wr <= '1';
			wait for clock_period * 2;
			wr <= '0';
			wait for clock_period;
			
			wait for clock_period;
			address_out <= address + x"0001";
			data_out <= data(15 downto 8);
			wr <= '1';
			wait for clock_period * 2;
			wr <= '0';
			wait for clock_period;
			
			wait for clock_period;
			address_out <= address + x"0002";
			data_out <= data(23 downto 16);
			wr <= '1';
			wait for clock_period * 2;
			wr <= '0';
			wait for clock_period;
			
			wait for clock_period;
			address_out <= address + x"0003";
			data_out <= data(31 downto 24);
			wr <= '1';
			wait for clock_period * 2;
			wr <= '0';
			wait for clock_period;
		end write_uint32_t;
	BEGIN

		-- Component Instantiation
		uut: entity work.VectorDotproductSkeleton(Behavioral)
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
			wait for clock_period*3; -- wait until global set/reset completes
			
			reset <= '0';
			-- run <= '1';
			
			-- N
			write_uint32_t(little_endian(2), x"0000", address_in, data_in, wr);
			-- first num
			write_uint32_t(little_endian(50), to_unsigned(4, 16), address_in, data_in, wr);
			-- first num
			write_uint32_t(little_endian(60), to_unsigned(8, 16), address_in, data_in, wr);
			-- third num
			write_uint32_t(little_endian(20), to_unsigned(4, 16), address_in, data_in, wr);
			-- fourth num
			write_uint32_t(little_endian(30), to_unsigned(8, 16), address_in, data_in, wr);


--			-- first num
--			data_in.data <= (to_unsigned(10, 32));
--			wait for clock_period * 2;
--			
--			-- second num
--			data_in.data <= (to_unsigned(5, 32));
--			wait for clock_period * 2;
--			
--			-- third num
--			data_in.data <= (to_unsigned(7, 32));
--			wait for clock_period * 2;
--			
--			-- fourth num
--			data_in.data <= (to_unsigned(6, 32));
--			wait for clock_period * 2;
--			data_in_rdy <= '0';

			-- result
			wait for clock_period * 10;

			sim_busy <= false;

			wait; -- will wait forever
		END PROCESS tb;
		--  End Test Bench 

	END;