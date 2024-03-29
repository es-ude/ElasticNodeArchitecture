-- TestBench Template 

	LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;
	USE ieee.numeric_std.ALL;
    use ieee.std_logic_signed.all;
	

    library fpgamiddlewarelibs;
    use fpgamiddlewarelibs.userlogicinterface.all;
    
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
		
		constant clock_period 	: time := 1 ns;
		signal sim_busy 		: boolean := true;
		signal times_s : integer;
		
		signal address : uint24_t;

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
			    clk => clock,
	            reset => reset,
                address => ext_sram_addr,
                data_io => ext_sram_data,
                cs_1 => ext_sram_cs_1,
                cs_2 => ext_sram_cs_2,
                output_enable => ext_sram_output_enable,
                write_enable => ext_sram_write_enable,
                upper_byte_select => ext_sram_upper_byte_select,
                lower_byte_select => ext_sram_lower_byte_select
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
			variable parameter : uint16_t;
			variable parameter_v : std_logic_vector(15 downto 0);
			variable times: integer;
			variable weights_per_layer:fixed_point_matrix;
			variable sram_address : uint24_t;
			variable layer_count, neuron_coun, weight_count: integer;
		BEGIN
			reset <= '1';

			wait for clock_period * 32; -- wait until global set/reset completes

			reset <= '0';

            wait for clock_period * 10; -- a few delay for reset weights start.
            
            wait until busy = '0';  -- wait for reset finished.
            
            times :=0;
            
            -- Read_out weights in first hidden_layer
            layer_count := 0;
            for neuron_coun in 0 to hiddenWidth-1 loop
                for weight_count in 0 to paramsPerNeuronWeights loop
                    sram_address := to_unsigned((layer_count+1) * totalParamsPerLayer + neuron_coun * totalParamsPerNeuron + weight_count, sram_address'length);
                    
                    -- set the address
                    write_uint8_t(sram_address(23 downto 16)   , x"0004", address_in, data_in, wr); -- SRAM_address[23:16]
                    write_uint8_t(sram_address(15 downto 8)  , x"0005", address_in, data_in, wr); -- SRAM_address[15:8]
                    write_uint8_t(sram_address(7 downto 0) , x"0006", address_in, data_in, wr); -- SRAM_address[7:0]
                    
                    
                    read_uint8_t(x"0006", address_in, rd, data_out, data); 
                    address(7 downto 0) := data;


                    read_uint8_t(x"000B", address_in, rd, data_out, data); 
                    parameter(15 downto 8) := data;
                    read_uint8_t(x"000C", address_in, rd, data_out, data); 
                    parameter(7 downto 0) := data;
                    
                    -- The line below doesn't work, my question is how can I convert a unsigned data to signed data.
                    -- parameter_v := std_logic_vector(parameter);
                    -- weights_per_layer(layer_count)(neuron_coun)(weight_count) := SIGNED(parameter_v);
                    
                end loop;
            end loop;
            
            -- ToDo: Change to little endian.
            -- example: a uint16_t value in mcu is:
            -- uint16_t a=0x1028;(4128)
            -- with little endian: a_L==0x10  a_H==0x28
            -- when mcu send a_L and a_H to me, which one comes the first?
            -- when send data to mcu which shold be sent the first?
            
            
              
            -- for testing write data to sram and read data to sram.
--            for i in 0 to 4 loop
--                -- read_uint8_t(x"0002", address_in, rd, data_out, data);
--                write_uint8_t(0, x"0004", address_in, data_in, wr); -- SRAM_address[7:0]
--                write_uint8_t(0, x"0005", address_in, data_in, wr); -- SRAM_address[15:8]
--                write_uint8_t(24+i, x"0006", address_in, data_in, wr); -- SRAM_address[23:16]
                
--                write_uint8_t(10, x"000B", address_in, data_in, wr); -- data[15:8]
--                write_uint8_t(5+i, x"000C", address_in, data_in, wr); -- data[7:0]
--                wait for clock_period * 1;
--            end loop;
                        
--            for i in 0 to 4 loop
--                -- read_uint8_t(x"0002", address_in, rd, data_out, data);
--                write_uint8_t(0, x"0004", address_in, data_in, wr); -- SRAM_address[7:0]
--                write_uint8_t(0, x"0005", address_in, data_in, wr); -- SRAM_address[15:8]
--                write_uint8_t(24+i, x"0006", address_in, data_in, wr); -- SRAM_address[23:16]
--                read_uint8_t(x"000B", address_in, rd, data_out, data); -- SRAM_address[7:0]
--                parameter(15 downto 8) := data;
--                read_uint8_t(x"000C", address_in, rd, data_out, data); -- SRAM_address[15:8]
--                parameter(7 downto 0) := data;
--            end loop;

			for i in 1 to 4000 loop
                -- inputs
                write_uint8_t(3, x"0000", address_in, data_in, wr); -- connections in
                write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
                write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
                write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
                wait until busy = '0';
                
                -- inputs
                write_uint8_t(2, x"0000", address_in, data_in, wr); -- connections in
                write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
                write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
                write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
                wait until busy = '0';
                
                -- inputs
                write_uint8_t(1, x"0000", address_in, data_in, wr); -- connections in
                write_uint8_t(1, x"0001", address_in, data_in, wr); -- wanted
                write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
                write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
                
                wait until busy = '0';
                
                -- inputs
                write_uint8_t(0, x"0000", address_in, data_in, wr); -- connections in
                write_uint8_t(0, x"0001", address_in, data_in, wr); -- wanted
                write_uint8_t(1, x"0002", address_in, data_in, wr); -- control
                write_uint8_t(1, x"0003", address_in, data_in, wr); -- start
                
                wait until busy = '0';

                times := times+4;
                times_s <= times;
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
