----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:27:33 06/06/2017 
-- Design Name: 
-- Module Name:    HiddenLayers - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

library neuralnetwork;
use neuralnetwork.common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HiddenLayers is
    generic (
        sram_addr_width : integer := hw_sram_addr_width;
        sram_data_width : integer := hw_sram_data_width
    );
	port (
			clk						:	in std_logic;
			reset 					: 	in std_logic; -- reset all variables and memory

			n_feedback				:	in integer range 0 to 2;
			current_layer			:	in uint8_t;
			current_neuron			:	in uint8_t;
			
			dist_mode				:	in distributor_mode;
					
			connections_in			:	in fixed_point_vector;
			connections_out			:	out fixed_point_vector;

			wanted					:	in fixed_point_vector;

			reset_weights 			:	in std_logic;
			sram_address			:	in uint24_t;
			load_weights			:	in std_logic;
			store_weights			:	in std_logic;
			flash_ready				:	out std_logic;

			ext_sram_addr                : out std_logic_vector(sram_addr_width-1 downto 0);
            ext_sram_data                : inout std_logic_vector(hw_sram_data_width-1 downto 0);
            ext_sram_output_enable       : out std_logic;
            ext_sram_write_enable        : out std_logic;

			debug					: 	out uint8_t
			--weights_wr_en 			:	in std_logic;
			--weights 				:	inout weights_vector := (others => 'Z')
		);
end HiddenLayers;

architecture Behavioral of HiddenLayers is

constant finishedDelay : integer := 320000;

-- signal weights : fixed_point_matrix_array := (others => (others => (others => init_weight))); -- weights for all the hidden layers
-- signal weights : fixed_point_matrix := (others => (others => init_weight));
signal errors_accrue_s : fixed_point_vector;
signal weights_in, weights_out : fixed_point_matrix;
signal conn_in, conn_out, conn_out_prev, err_in, err_out, bias_in, bias_out : fixed_point_vector;
-- signal connections : fixed_point_array;
signal n_feedback_s : integer range 0 to 2;

-- weights ram interface
constant WEIGHTS_RAM_WIDTH							: integer := log2(totalLayers);
signal weights_wr_a, weights_wr_b: std_logic := '0';
signal weights_address_a,weights_address_b,weights_address_ann,weights_address_flash			: std_logic_vector(WEIGHTS_RAM_WIDTH-1 downto 0);
signal weights_din_a, weights_din_b, weights_din_ann, weights_din_ext, weights_dout_a, weights_dout_b 	: weights_vector; -- read entire layer's weights at a time 
--signal resetWeightsOscillate 						: boolean; -- indicates when weights should be written
signal invert_clk									: std_logic;
-- signal reset_counter 								: unsigned(WEIGHTS_RAM_WIDTH-1 downto 0) := (others => '0'); -- l+1 means it's done

-- conn ram interface
constant CONN_RAM_WIDTH							: integer := log2(totalLayers+1);
signal conn_wr									: std_logic := '0';
signal conn_address_a,conn_address_b			: std_logic_vector(CONN_RAM_WIDTH-1 downto 0);
signal conn_wr_din, conn_rd_dout_a, conn_rd_dout_b	: conn_vector;
signal conn_write, conn_rd_b					: fixed_point_vector; -- data to be written
signal conn_feedback							: fixed_point_vector;

-- bias ram interface
constant BIAS_RAM_WIDTH						: integer := log2(totalLayers);
signal bias_wr								: std_logic := '0';
signal bias_rd_address,bias_wr_address,bias_rd_address_ann,bias_rd_address_flash : std_logic_vector(BIAS_RAM_WIDTH-1 downto 0);
signal bias_din, bias_dout					: conn_vector;
signal biases_in, biases_out				: fixed_point_vector;

signal current_layer_sample_signal : uint8_t;
signal current_neuron_sample_signal : uint8_t;

 --flash interface
--signal flashAddress : uint16_t;
signal flashWrRequest, flashRdRequest, flashDataInRequest, flashDone : std_logic;
signal flashNumBytes : integer range 0 to 256;
signal flashDataIn, flashDataOut : uint8_t;

signal weights_wr_flash, weights_rd_flash, bias_wr_flash, bias_rd_flash : std_logic;
signal weights_din_sram : weights_vector;
signal flashState : flashStateType;



signal sram_mode : sramModeType;


-- for sram reset functions
signal sram_reset_address : std_logic_vector(sram_addr_width-1 downto 0);
signal sram_reset_data : std_logic_vector(hw_sram_data_width-1 downto 0);


-- for sram conn process
signal conn_wr_request : std_logic;
signal sram_conn_write_address : std_logic_vector(sram_addr_width-1 downto 0);
signal sram_conn_read_address : std_logic_vector(sram_addr_width-1 downto 0);
signal sram_conn_write_data : std_logic_vector(hw_sram_data_width-1 downto 0);
signal sram_conn_read_data : std_logic_vector(hw_sram_data_width-1 downto 0);

-- for sram bias & weights process
signal bias_and_weights_wr_request : std_logic;
signal sram_bias_weights_write_address : std_logic_vector(sram_addr_width-1 downto 0);
signal sram_bias_weights_read_address : std_logic_vector(sram_addr_width-1 downto 0);
signal sram_bias_weights_write_data : std_logic_vector(hw_sram_data_width-1 downto 0);
signal sram_bias_weights_read_data : std_logic_vector(hw_sram_data_width-1 downto 0);


signal sram_write_ctl : std_logic;
 
-- debug
signal layerIndex_s, index_s : integer;

begin


sram_mode <= sramReset when dist_mode = resetWeights else
             connWrite when conn_wr_request='1' else
             
             --<expression> when <condition> else
             idle;
             
with sram_mode select
  ext_sram_addr <= (others=>'0') when idle,
            sram_reset_address when sramReset,
            sram_conn_write_address when connWrite,
            (others=>'0') when others;

with sram_mode select
  ext_sram_data <= (others=>'0') when idle,
            sram_reset_data when sramReset,
            sram_conn_write_data when connWrite,
            (others=>'0') when others;
            
            

sram_write_ctl <= '0' when (sram_mode = sramReset) or (sram_mode = connWrite)
	else '1';
	

          
lay: 
	entity neuralNetwork.Layer(Behavioral) port map
	(
		clk, reset, n_feedback, dist_mode, current_layer, current_neuron, conn_in, conn_out, conn_out_prev, err_in, err_out, weights_in, weights_out, biases_in, biases_out
	);

    
    ext_sram_write_enable <=  sram_write_ctl or clk;
---- flash loading
--flash:
--	entity fpgamiddlewarelibs.FlashInterface(Behavioral)
----	 generic map
----	(
----		prescaler => 2
----	)
--	port map
--	(
--		clk => clk,
--		reset => reset,

--		addressIn => flash_address,
--		writeRequest => flashWrRequest,
--		readRequest => flashRdRequest,
--		numBytes => flashNumBytes,
--		dataIn => flashDataIn,
--		dataInRequest => flashDataInRequest,
--		dataOut => flashDataOut,
--		dataOutAvailable => flashDataOutAvail,
--		done => flashDone,

--		spi_cs => spi_cs,
--		spi_clk => spi_clk,
--		spi_mosi => spi_mosi,
--		spi_miso => spi_miso
--	);

-- half speed clock to only write memory every second cycle
--resetWeightsOscillate_process:
--process(clk, reset, reset_weights)
--begin
--	if reset = '1' then
--		resetWeightsOscillate <= true;

--	elsif falling_edge(clk) then
--		if dist_mode = resetWeights then
--			if resetWeightsOscillate then
--				resetWeightsOscillate <= false;
--			else
--				resetWeightsOscillate <= true;
--			end if;
--		else
--			resetWeightsOscillate <= false;
--		end if;
--	end if;
--end process;

-- process for reading/writing sram chip
sram_process:
process (clk, reset, reset_weights, load_weights) is
	variable index : integer range 0 to totalLayers+1;
	
	variable layerIndex : integer range 0 to totalLayers + 1;
	-- variable neuronIndex : integer range 1 to maxWidth + 1; -- chao added it useless
	-- variable currentByte : integer;
	variable waitIndex : integer range 0 to finishedDelay + 1;
	variable firstByte : boolean;
	
begin
	if reset = '1' then
		flashState <= idle;
		weights_din_sram <= (others => '0');
		weights_address_flash <= (others => '0');
		flashRdRequest <= '0';
		flashWrRequest <= '0';
		waitIndex := 0;
		firstByte := false;
	elsif rising_edge(clk) then
        case flashState is
		
		when idle =>
			if load_weights = '1' then
				flashState <= requestLoadWeights;
			elsif store_weights = '1' then
				flashState <= requestStoreWeights;
			elsif reset_weights = '1' then
				flashState <= waitResetWeights;
			end if;
			
--			-- current state flags
--			weights_wr_flash <= '0';
--			weights_rd_flash <= '0';
--			bias_wr_flash <= '0';
--			bias_rd_flash <= '0';

			index := 0;
			layerIndex := 0;
            
		-- reset weights
		when waitResetWeights =>
			-- stay here until weights have been reset
			if dist_mode = resetWeightsDone then 
				flashState <= finished;
				waitIndex := 0;
			end if;

--		-- load weights from flash
--		when requestLoadWeights =>
--			--flashAddress <= x"A50F";
--			flashRdRequest <= '1';
--			flashNumBytes <= bytesPerLayerWeights * totalLayers + bytesPerLayerBias * totalLayers;
--			weights_address_flash <= (others => '0');

--			flashState <= waitingLoadingWeights;
--			firstByte := true; -- to ignore 
--		when loadingWeights =>
--			flashRdRequest <= '0';

--			weights_din_flash((layerIndex+1)*8-1 downto layerIndex*8) <= std_logic_vector(currentByte);
			
--			if layerIndex < bytesPerLayerWeights - 1 then
				
--				layerIndex := layerIndex + 1;
--				flashState <= waitingLoadingWeights;

--			else 
--				layerIndex := 0;
--				weights_address_flash <= std_logic_vector(to_unsigned(index, weights_address_flash'length));
--				weights_wr_flash <= '1';
--				index := index + 1;
--				-- done
--				if index = totalLayers then
--					flashState <= finished;
--					waitIndex := 0;
--				else
--					flashState <= waitingLoadingWeights;
--				end if;
--			end if;
--		when waitingLoadingWeights =>
--			weights_wr_flash <= '0';
--			-- wait for next byte to be available from the flash
--			if flashDataOutAvail = '1' then
--				if firstByte then
--					firstByte := false;
--				else
--					flashState <= loadingWeights;
--					currentByte := flashDataOut;
--				end if;
--			end if;

--		-- storing weights to flash
--		when requestStoreWeights =>
--			--flashAddress <= x"A50F";
--			flashNumBytes <= bytesPerLayerWeights * totalLayers + bytesPerLayerBias * totalLayers;
--			--assert flashNumBytes < 256 report "writing too many bytes to flash" severity failure;
--			weights_address_flash <= (others => '0');
--			bias_rd_address_flash <= (others => '0');
--			weights_rd_flash <= '1';
--			flashWrRequest <= '1';
--			layerIndex := 0;


--			-- assert first data
--			flashState <= waitingStoringWeights;
--			flashDataIn <= unsigned(weights_dout_b((layerIndex+1)*8-1 downto layerIndex*8));

--		when storingWeights =>
--			if layerIndex < bytesPerLayerWeights - 2 then				
--				layerIndex := layerIndex + 1;
--				flashState <= waitingStoringWeights;
--				-- first time layerIndex will be 1 here
--				flashDataIn <= unsigned(weights_dout_b((layerIndex+1)*8-1 downto layerIndex*8));

--			-- read normally but queue read of next layer
--			elsif layerIndex = bytesPerLayerWeights - 2 then
--				layerIndex := layerIndex + 1;
--				flashState <= waitingStoringWeights;				

--				-- read either next layer or end 
--				--if index = totalLayers - 1 then
--				--	flashState <= finished;
--				index := index + 1;
--				flashState <= waitingStoringWeights;
				
--				if index /= totalLayers then
--					weights_address_flash <= std_logic_vector(to_unsigned(index, weights_address_flash'length));
--				end if;

--				-- first time layerIndex will be 1 here
--				flashDataIn <= unsigned(weights_dout_b((layerIndex+1)*8-1 downto layerIndex*8));

--			else
--				-- write first of next layer
--				layerIndex := 0;
--				flashState <= waitingStoringWeights;
				
--				if index = totalLayers then
--					index := 0;
--					-- set up first bias
--					weights_rd_flash <= '0';
--					bias_rd_flash <= '1';

--					flashState <= waitingStoringBias;
--					flashDataIn <= unsigned(bias_dout((layerIndex+1)*8-1 downto layerIndex*8));
--				--end if;
--				--weights_wr_flash <= '1';
--				-- done
--				else
--					-- first time layerIndex will be 1 here
--					flashDataIn <= unsigned(weights_dout_b((layerIndex+1)*8-1 downto layerIndex*8));
--				end if;
--			end if;

			
--		when waitingStoringWeights =>
--			flashWrRequest <= '0';

--			--weights_wr_flash <= '0';
--			-- wait for next byte to be available from the flash
--			if flashDataInRequest = '1' then
--				flashState <= storingWeights;
--				currentByte := flashDataOut;
--			end if;

--		-- storing bias to flash
--		when storingBias =>
--			if layerIndex < bytesPerLayerBias - 2 then				
--				layerIndex := layerIndex + 1;
--				flashState <= waitingStoringBias;

--			-- read normally but queue read of next layer
--			elsif layerIndex = bytesPerLayerBias - 2 then
--				layerIndex := layerIndex + 1;
--				flashState <= waitingStoringBias;				

--				-- read either next layer or end 
--				--if index = totalLayers - 1 then
--				--	flashState <= finished;
--				index := index + 1;
--				flashState <= waitingStoringBias;
				
--				if index /= totalLayers then
--					bias_rd_address_flash <= std_logic_vector(to_unsigned(index, bias_rd_address_flash'length));
--				end if;
--			else
--				-- write first of next layer
--				layerIndex := 0;
--				flashState <= waitingStoringBias;
				
--				if index = totalLayers then
--					index := 0;
--					bias_rd_flash <= '0';
--					flashState <= finished;
--					waitIndex := 0;

--				end if;
--				--weights_wr_flash <= '1';
--				-- done
--			end if;

--			-- first time layerIndex will be 1 here
--			flashDataIn <= unsigned(bias_dout((layerIndex+1)*8-1 downto layerIndex*8));
			
--		when waitingStoringBias =>

--			--weights_wr_flash <= '0';
--			-- wait for next byte to be available from the flash
--			if flashDataInRequest = '1' then
--				flashState <= storingBias;
--				currentByte := flashDataOut;
--			end if;

		-- done 
		when finished =>
			if load_weights = '0' and store_weights = '0' and reset_weights = '0' then

				if waitIndex = finishedDelay then
					flashState <= idle;
					waitIndex := 0;
				else 
					waitIndex := waitIndex + 1;
				end if;
			else
				waitIndex := 0;
			end if;
		when others =>
            
		end case;

		layerIndex_s <= layerIndex;
		index_s <= index;
--	elsif falling_edge(clk) then
--        case flashState is
--        when waitResetWeights =>
--            ext_sram_write_enable <= '1';   -- disable the sram write ability
--        when others =>
--        end case;
	end if;
end process;
flash_ready <= '1' when flashState = finished else '0';
debug <= to_unsigned(flashStateType'POS(flashState), 8);

-- memory
invert_clk <= not clk;
-- write on feedback, when correct layer
weights_bram:
	entity neuralnetwork.bram_tdp(rtl) generic map
	(
		b*maxWidth*maxWidth, WEIGHTS_RAM_WIDTH
	) port map
	( -- read port A, write port B
		invert_clk, '0', weights_address_a, (others => '0'), weights_dout_a, clk, weights_wr_b, weights_address_b, weights_din_b, weights_dout_b
	);
-- simple writing logic
-- write when resetting, or after each feedback layer, or after last feedback layer, or when weights are being set from outside
weights_wr_b <= '1' when (reset_weights = '1') or (n_feedback = 2 and dist_mode = feedback) or (dist_mode = delay) or (weights_wr_flash = '1') -- or (weights_wr_ext = '1') reset = '1' or 
	else '0';
-- output weights to buffer when not being written
--weights <= (others => 'Z') when weights_wr_en = '1' else weights_dout_b; -- (others => '1'); -- when weights_wr_en = '0' else (others => 'Z'); -- weights_dout_b
weights_din_b <= weights_din_sram when weights_wr_flash = '1' else weights_din_ann;
weights_address_b <= weights_address_flash when weights_wr_flash = '1' or weights_rd_flash = '1' else weights_address_ann;
--weights_din_b <= weights_din_ann;

    
    
	n_feedback_s <= n_feedback when (current_layer > 0 and current_layer < totalLayers-1) else 2;
-- convert between ram vectors and weights
vtw:
	entity neuralnetwork.vectortoweights(Behavioral) port map
	(
		weights_dout_a, weights_in
	);
wtv:
	entity neuralnetwork.weightstovector(Behavioral) port map
	(
		weights_out, weights_din_ann
	);
	
connections:
	entity neuralnetwork.bram_tdp(rtl) generic map
	(
		b*maxWidth, CONN_RAM_WIDTH
	) port map
	(
		clk, conn_wr, conn_address_a, conn_wr_din, conn_rd_dout_a, invert_clk, '0', conn_address_b, (others => '0'), conn_rd_dout_b
	);
-- data to be written for connections out
conn_write <= connections_in when (conn_address_a = std_logic_vector(to_unsigned(0, conn_address_a'length))) 
					else conn_out when n_feedback = 1
					else conn_out; -- (others => (others => '1')); -- write connections in in address 0, otherwise outputs
-- write connections out after each layer in feed forward, connection in during calculate
conn_wr <= '1' when (n_feedback = 2 and (dist_mode = intermediate or dist_mode = feedforward)) or dist_mode = waiting
					else '0';


-- sample the neuron for conn in
process(clk) is 
begin
	if rising_edge(clk) then 
		current_neuron_sample_signal <= current_neuron;
	end if;
end process;
-- conn in assignment process
process(clk) is
	variable previous_neuron : uint8_t;
begin
	if rising_edge(clk) then
		-- assign conn_in
		if n_feedback = 2 then
			-- feedforward
			if dist_mode = feedforward then 
				-- between layers
				conn_in <= conn_out;
			-- inbetween or feedback
			elsif dist_mode = intermediate or dist_mode = feedback then
				conn_in <= conn_rd_b;
			end if;
		-- new start
		elsif dist_mode = waiting then
		-- elsif n_feedback = 1 and current_layer = to_unsigned(0, current_layer'length) and current_neuron = to_unsigned(0, current_neuron'length) then
			conn_in <= connections_in;
		-- feedback
		end if;
	end if;
end process;

--conn_in <= conn_rd_b when n_feedback = '0'
--					else conn_feedback when n_feedback = '1'
--					else connections_in;
vtc_a:
	entity neuralnetwork.vectortoconn(Behavioral) port map
	(
		conn_rd_dout_a, conn_out_prev
	);
vtc_b:
	entity neuralnetwork.vectortoconn(Behavioral) port map
	(
		conn_rd_dout_b, conn_rd_b
	);
ctv:
	entity neuralnetwork.conntovector(Behavioral) port map
	(
		conn_write, conn_wr_din
	);
	
bias:
	entity neuralnetwork.bram_tdp(rtl) generic map
	(
		b*maxWidth, BIAS_RAM_WIDTH
	) port map
	( -- read port A, write port B
		invert_clk, '0', bias_rd_address, (others => '0'), bias_dout, clk, bias_wr, bias_wr_address, bias_din, open
	);
bias_rd_address <= bias_rd_address_flash when bias_rd_flash = '1' else bias_rd_address_ann;
bias_wr <= '1' when (reset_weights = '1') or (n_feedback = 2 and dist_mode = feedback) or (dist_mode = delay)
	else '0';
vtb:
	entity neuralnetwork.vectortoconn(Behavioral) port map
	(
		bias_dout, biases_in
	);
btv:
	entity neuralnetwork.conntovector(Behavioral) port map
	(
		biases_out, bias_din
	);

	
	-- weights_in <= weights; -- (to_integer(current_layer));-- ***
	
	-- weights ram prep process
	--reading
	process(clk, current_layer, reset) is
		variable current_layer_sample : integer range 0 to totalLayers;
		variable last_neuron, second_last_neuron : boolean;
		
	begin
		if reset = '1' then
			weights_address_a <= (others => '0'); -- preload first one
		else
			if rising_edge(clk) then
				--if weights_wr_en = '1' then
				--	weights_address_a <= std_logic_vector(resize(current_layer, WEIGHTS_RAM_WIDTH));
				--	-- sample incoming weights
				--	weights_din_a <= weights;
				--	weights_wr_a <= '1';
				--else
					current_layer_sample := to_integer(current_layer);

					weights_wr_a <= '0';
					
					--current_neuron = maxWidth-1-1;
					last_neuron := (current_neuron = maxWidth-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1)); -- or ((current_layer_sample = 0) and (current_neuron = inputWidth-1));
					--last_neuron := current_neuron = maxWidth-1;
					second_last_neuron := (current_neuron = maxWidth-1-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1-1)) or ((current_layer_sample = 0) and (current_neuron = inputWidth-1-1));
							
					
					-- when forward, load weights for next (clocks inverted)
					if n_feedback = 1 then
						if last_neuron and current_layer < totalLayers - 1 then -- dont load l+1 weights
							-- used to load current_layer+1
							weights_address_a <= std_logic_vector(resize(current_layer+1, WEIGHTS_RAM_WIDTH));
						end if;
					-- when backward, load next 
					elsif n_feedback = 0 then
						if last_neuron then
							-- used to load current_layer-1
							weights_address_a <= std_logic_vector(resize(current_layer-1, WEIGHTS_RAM_WIDTH));
							-- if currently in hidden layer, queue write next cycle
							-- if current_layer_sample > 0 and current_layer_sample < totalLayers-1 then
							-- end if;
						end if;
					-- preload
					elsif dist_mode = idle then
						weights_address_a <= (others => '0'); -- preload first one 
					-- inbetween 
					elsif dist_mode = intermediate then
						weights_address_a <= std_logic_vector(to_unsigned(numHiddenLayers, weights_address_a'length)); -- preload first one 
					end if;
					-- weights_in <= vector_to_weights(weights_dout); -- weights((current_layer_sample+1)*maxWidth-1 downto current_layer_sample*w);
				end if;
			--end if;
		end if;
	end process;
	
	
	-- writing (bias & weights)
	process(clk, current_layer, reset) is
		variable current_layer_sample : integer range 0 to totalLayers;
		variable last_neuron : boolean;
        variable sram_reset_address_v : integer;
        variable currentParam : integer;
        variable last_time_neuron_index : uint8_t;
        
        variable write_bias_weights_count : integer range 0 to maxWidth;
        variable sram_bias_weights_write_address_v : integer;
        variable storage_neuron_cnt,storage_param_cnt:integer;
        variable bias_and_weights_wrting_state : std_logic;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				currentParam := 0;
				last_time_neuron_index := to_unsigned(maxWidth,8);
				
				 bias_and_weights_wr_request <='0';
                 bias_and_weights_wrting_state := '0';
                 
			elsif dist_mode = resetWeights then
			    if (last_time_neuron_index /= current_neuron) and (currentParam /= 0) then 
                    currentParam := 1;
                    last_time_neuron_index := current_neuron;
			    end if;
			    
                -- reset weights and bias here
                if currentParam /= 0 then
                
                    if currentParam <= paramsPerNeuronWeights then
                        sram_reset_data <= std_logic_vector(weights_out(to_integer(current_neuron))(currentParam-1));
                    elsif currentParam = paramsPerNeuronWeights+1 then
                        sram_reset_data <= std_logic_vector(biases_out(to_integer(current_neuron)));
                    end if;
                    
                    sram_reset_address_v := ((to_integer(current_layer)+1)*maxWidth 
                        + to_integer(current_neuron))*totalParamsPerNeuron + currentParam - 1;
    
                    -- SRAM Control
                    sram_reset_address <= conv_std_logic_vector(sram_reset_address_v, sram_reset_address'length);
                
                end if;
                
                if  currentParam <= paramsPerNeuronWeights+1 then 
                    currentParam := currentParam + 1;                   
                end if;
                
                
				weights_address_ann <= std_logic_vector(resize(current_layer, weights_address_ann'length));
				bias_wr_address <= std_logic_vector(resize(current_layer, weights_address_b'length));
			
			elsif dist_mode = intermediate then -- used to be idle?
				weights_address_ann <= std_logic_vector(to_unsigned(numHiddenLayers, WEIGHTS_RAM_WIDTH));
				bias_and_weights_wr_request <='0';
				bias_and_weights_wrting_state := '0';
			else
		
				current_layer_sample := to_integer(current_layer);

				last_neuron := (current_neuron = maxWidth-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1)); -- or ((current_layer_sample = 0) and (current_neuron = inputWidth-1));

				if last_neuron then
					weights_address_ann <= std_logic_vector(resize(current_layer, WEIGHTS_RAM_WIDTH));
					bias_wr_address <= std_logic_vector(resize(current_layer, BIAS_RAM_WIDTH));
					
                    if dist_mode = feedback then 
                        if sram_mode = idle and bias_and_weights_wr_request='0' then
                            storage_neuron_cnt:=0;
                            storage_param_cnt:=0;
                            bias_and_weights_wrting_state := '1';
--                            sram_bias_weights_write_address_v := (to_integer(current_layer)+1)*totalParamsPerNeuron*maxWidth;
--                            sram_bias_weights_write_address <= conv_std_logic_vector(sram_bias_weights_write_address_v, sram_bias_weights_write_address'length);
--                            sram_bias_weights_write_data <= std_logic_vector(weights_out(storage_neuron_cnt)(storage_param_cnt));
                        end if;
                    end if; 
                elsif bias_and_weights_wrting_state='1' then
                    
                    bias_and_weights_wr_request <='1';
                                    
                    if storage_param_cnt=totalParamsPerNeuron-1 then
                        
                        storage_neuron_cnt := storage_neuron_cnt+1;
                        
                        if storage_neuron_cnt=maxWidth then
                            bias_and_weights_wrting_state := '0';
                            bias_and_weights_wr_request <= '0';
                        else
                            storage_param_cnt := 0;
                            sram_bias_weights_write_address_v := (to_integer(current_layer)+2)*totalParamsPerNeuron*maxWidth+storage_neuron_cnt*totalParamsPerNeuron+storage_param_cnt;
                            sram_bias_weights_write_data <= std_logic_vector(weights_out(storage_neuron_cnt)(storage_param_cnt));
                        end if;
                        
                    elsif storage_param_cnt=totalParamsPerNeuron-2 then -- save bias
                        sram_bias_weights_write_address_v := (to_integer(current_layer)+2)*totalParamsPerNeuron*maxWidth+storage_neuron_cnt*totalParamsPerNeuron+storage_param_cnt;
                        sram_bias_weights_write_data <= std_logic_vector(biases_out(storage_neuron_cnt));
                    else
                        sram_bias_weights_write_address_v := (to_integer(current_layer)+2)*totalParamsPerNeuron*maxWidth+storage_neuron_cnt*totalParamsPerNeuron+storage_param_cnt;
                        sram_bias_weights_write_data <= std_logic_vector(weights_out(storage_neuron_cnt)(storage_param_cnt));
                    end if;
                    
                    sram_bias_weights_write_address <= conv_std_logic_vector(sram_bias_weights_write_address_v, sram_bias_weights_write_address'length);
                    
                    storage_param_cnt := storage_param_cnt+1; 
				end if;
	
			end if;

		end if;
	end process;

	-- connections ram process
	process(reset, clk, current_layer, conn_wr) is
		variable current_layer_sample : integer range 0 to totalLayers;
		
		-- after a neuron's calculation finished, we need to save 
		-- all output connection for a neuron.
		variable write_conns_count : integer range 0 to maxWidth; 
		variable sram_conn_write_address_v : integer;
	begin
		if reset = '1' then
			conn_address_a <= (others => '0');
			conn_address_b <= (others => '0');
		elsif rising_edge(clk) then
			-- conn_wr <= '0';
			
			current_layer_sample := to_integer(current_layer);
			-- weights_wr_address <= std_logic_vector(resize(current_layer, WEIGHTS_RAM_WIDTH));
			
			-- update conn ram reading address 
			if (current_neuron = maxWidth-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1)) then -- or ((current_layer_sample = 0) and (current_neuron = inputWidth-1)) then
				-- when forward, load weights for next (clocks inverted)
				if n_feedback = 1 then
					conn_address_a <= std_logic_vector(resize(current_layer + 1, CONN_RAM_WIDTH));
					conn_address_b <= std_logic_vector(to_unsigned(totalLayers-1, CONN_RAM_WIDTH));
				-- when backward, load next 
				elsif n_feedback = 0 then
					conn_address_b <= std_logic_vector(resize(current_layer-1, CONN_RAM_WIDTH)); 	-- conn_prev
					conn_address_a <= std_logic_vector(resize(current_layer, CONN_RAM_WIDTH));		-- conn_in
				end if;
			--elsif current_neuron = maxWidth-1-1 then
			--	if n_feedback = 0 then
			--	end if;
			end if;
			
            
            if conn_wr ='1' and sram_mode = idle then
                conn_wr_request <= '1';
                write_conns_count := 0;
                
                sram_conn_write_address_v := ((to_integer(current_layer)) * maxWidth)*totalParamsPerNeuron + 5;
                
                sram_conn_write_address <= conv_std_logic_vector(sram_conn_write_address_v, 
                                                              sram_reset_address'length);
                sram_conn_write_data <= std_logic_vector(conn_write(write_conns_count));
            end if;

            
            -- if we should write the conns[maxWidth] into sram now.
            if conn_wr_request= '1' then
            
                write_conns_count := write_conns_count + 1;
                if write_conns_count=maxWidth then
                    conn_wr_request <= '0';
                else

                    sram_conn_write_address_v := ((to_integer(current_layer)) * maxWidth + write_conns_count)*totalParamsPerNeuron + 5;
                    sram_conn_write_address <= conv_std_logic_vector(sram_conn_write_address_v, 
                                                                  sram_reset_address'length);
                    sram_conn_write_data <= std_logic_vector(conn_write(write_conns_count));
                end if;
                                
            end if;
            
		end if;
	end process;
	
	-- bias ram process
	process(reset, clk, current_layer) is
		variable current_layer_sample : integer range 0 to totalLayers;
		variable last_neuron, second_last_neuron : boolean;
	begin
		if reset = '1' then
			-- bias_wr <= '1'; -- address done in weights write process
			bias_rd_address_ann <= (others => '0');

		else
			if rising_edge(clk) then
			
				current_layer_sample := to_integer(current_layer);

				last_neuron := (current_neuron = maxWidth-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1)); -- or ((current_layer_sample = 0) and (current_neuron = inputWidth-1));
				-- second_last_neuron := (current_neuron = maxWidth-1-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1));
				
				-- assign address to read from 
				if n_feedback = 1 then
					if last_neuron then
						-- just stay in final layer for intermediate
						if current_layer < totalLayers-1 then
							bias_rd_address_ann <= std_logic_vector(resize(current_layer + 1, BIAS_RAM_WIDTH));
						end if;
					end if;
				-- when backward, load next 
				elsif n_feedback = 0 then
					if last_neuron then
						-- stay in first layer until next round of query
						if current_layer > 0 then
							bias_rd_address_ann <= std_logic_vector(resize(current_layer - 1, BIAS_RAM_WIDTH));
						end if;
					end if;
				-- between feedback and feedforward
				elsif dist_mode = intermediate then
					bias_rd_address_ann <= std_logic_vector(to_unsigned(totalLayers-1, BIAS_RAM_WIDTH));
				elsif dist_mode = idle then
					bias_rd_address_ann <= (others => '0');
				end if;
			end if;
		end if;
	end process;
	
	-- error process
	process(clk) is
		variable current_layer_sample : integer range 0 to totalLayers;
		variable errors_accrue : fixed_point_vector;
	begin
		if rising_edge(clk) then
			current_layer_sample := to_integer(current_layer);

			if n_feedback = 2 then 
				-- when in the last feed forward, preload the conn_out_prev
				if dist_mode = intermediate then
					err_in <= wanted - conn_out;
					--errors_accrue := (others => zero);
				-- between layers of feedback
				elsif dist_mode = feedback then
					err_in <= err_out; -- errors_accrue; -- forward results of previous layer to next layer
					-- errors_accrue := (others => zero);
				end if;
			-- accrue errors for each neuron
			--elsif n_feedback = 0 then
			--	errors_accrue := errors_accrue + err_out;
			end if;
			--errors_accrue_s <= errors_accrue;
		end if;	
	end process;
	
	
	-- main process
	process(clk, current_layer, connections_in) is
		variable current_layer_sample : integer range 0 to totalLayers;
	begin
		-- set inputs correctly before they're needed
		if rising_edge(clk) then -- recently changed this to rising_edge
			current_layer_sample := to_integer(current_layer);
			current_layer_sample_signal <= to_unsigned(current_layer_sample, current_layer_sample_signal'length);

			-- set output connections correctly
			if dist_mode = intermediate then -- between forward and back
				connections_out <= conn_out;
			elsif dist_mode = doneQuery then
				connections_out <= conn_out;
			end if;
			
			-- save results for future learning
			if n_feedback = 1 then
				-- perform feedback when last neuron calculated
				if (current_neuron = maxWidth-1) or ((current_neuron = outputWidth-1) and (current_layer_sample = totalLayers-1)) or ((current_layer_sample = 0) and (current_neuron = inputWidth-1)) then
					conn_feedback <= conn_out; -- not used?
				end if;
			else
				conn_feedback <= connections_in; -- initialise conn_in properly
			end if; -- not used?
	
		end if;	
	end process;


end Behavioral;

