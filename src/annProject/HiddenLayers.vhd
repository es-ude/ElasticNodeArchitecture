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
library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

library neuralnetwork;
use neuralnetwork.common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

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

			ext_sram_addr                : out std_logic_vector(sram_addr_width-1 downto 0);
            ext_sram_data                : inout std_logic_vector(hw_sram_data_width-1 downto 0);
            ext_sram_output_enable       : out std_logic;
            ext_sram_write_enable        : out std_logic;

			debug					: 	out uint8_t
		);
end HiddenLayers;

architecture Behavioral of HiddenLayers is

constant finishedDelay : integer := 320000;


signal errors_accrue_s : fixed_point_vector;
signal weights_in, weights_out : fixed_point_matrix;
signal conn_in, conn_out, conn_out_prev, err_in, err_out, new_bias_in, bias_in, bias_out: fixed_point_vector;

signal conn_feedback							: fixed_point_vector;

signal biases_in, biases_out				: fixed_point_vector;

signal current_layer_sample_signal : uint8_t;
signal current_neuron_sample_signal : uint8_t;


signal sram_mode : sramModeType;

-- for sram reset functions
signal sram_reset_address : std_logic_vector(sram_addr_width-1 downto 0);
signal sram_reset_data : std_logic_vector(hw_sram_data_width-1 downto 0);
signal sram_read_address : std_logic_vector(sram_addr_width-1 downto 0);

-- for sram bias & weights process
signal bias_and_weights_wr_request : std_logic;
signal bias_and_weights_rd_request : std_logic;
signal sram_bias_weights_write_address : std_logic_vector(sram_addr_width-1 downto 0);
signal sram_bias_weights_read_address : std_logic_vector(sram_addr_width-1 downto 0);
signal sram_bias_weights_write_data : std_logic_vector(hw_sram_data_width-1 downto 0);
signal sram_bias_weights_read_data : std_logic_vector(hw_sram_data_width-1 downto 0);

signal weights_rd_from_sram : fixed_point_matrix;
signal biases_rd_from_sram : fixed_point_vector;
signal conn_rd_from_sram : fixed_point_vector;


signal sram_write_ctl : std_logic;
 
-- debug
signal layerIndex_s, index_s : integer;

begin

sram_write_ctl <= '0' when (sram_mode = sramReset) or (sram_mode = connWrite) or (sram_mode = biasWeightsWrite)
	else '1';

ext_sram_write_enable <=  sram_write_ctl or ((clk));

ext_sram_output_enable <= '0' when bias_and_weights_rd_request='1'
    else '1';
    
sram_mode <= sramReset when dist_mode = resetWeights else
             biasWeightsWrite when bias_and_weights_wr_request='1' else
             biasWeightsRead when bias_and_weights_rd_request='1' else
             --<expression> when <condition> else
             idle;

sram_bias_weights_read_data <= ext_sram_data;
        
with sram_mode select
  ext_sram_addr <= (others=>'0') when idle,
            sram_reset_address when sramReset,
            sram_bias_weights_write_address when biasWeightsWrite,
            sram_bias_weights_read_address when biasWeightsRead,
            (others=>'Z') when others;



with sram_mode select
  ext_sram_data <= (others=>'0') when idle,
            sram_reset_data when sramReset,
            sram_bias_weights_write_data when biasWeightsWrite,
            (others=>'Z') when biasWeightsRead,
            (others=>'0') when others;

new_bias_in <= biases_rd_from_sram;
weights_in <= weights_rd_from_sram;  
          
lay: 
	entity neuralNetwork.Layer(Behavioral) port map
	(
		clk, reset, n_feedback, dist_mode, current_layer, current_neuron, conn_in, conn_out, conn_out_prev, err_in, err_out,  weights_in, weights_out, new_bias_in, biases_out
	);

-- sample the neuron for conn in
process(clk) is 
begin
	if rising_edge(clk) then 
		current_neuron_sample_signal <= current_neuron;
	end if;
end process;

-- conn in assignment process
-- conn_out_prev
process(reset, clk) is
    variable hold_conn_prev_flag:boolean;
begin
    if reset = '1' then
        hold_conn_prev_flag := false;
    elsif rising_edge(clk) then
        if dist_mode = intermediate then
            conn_out_prev <= conn_out;   -- hold conn_out of the output layer for backward.
        elsif dist_mode = feedback then
            if n_feedback = 2 then
                if hold_conn_prev_flag = false then
                    conn_out_prev <= conn_in;
                    hold_conn_prev_flag:=true;
                end if;
                conn_in <= conn_rd_from_sram;
            else
                hold_conn_prev_flag := false;
            end if;
        elsif dist_mode = feedforward and n_feedback = 2 then 
            -- between layers and feedforward
            if to_integer(current_layer) /= totalLayers-1 then -- at the output layer, conn_out need not pass to next layer
                conn_in <= conn_out;
            end if;
        elsif dist_mode = waiting then
            conn_in <= connections_in;     -- new start     
        end if;
    end if;
end process;

    -- ToDo: reconstructure this part of the code.
	-- reading and writing (bias & weights)
	process(clk, current_layer, reset) is
		variable current_layer_sample : integer range 0 to totalLayers;
		variable last_neuron : boolean;
        variable sram_reset_address_v : integer;
        variable currentParam : integer;
        variable last_time_neuron_index : uint8_t;
        variable start_write,start_read : std_logic;
        variable write_bias_weights_count : integer range 0 to maxWidth;
        variable sram_bias_weights_write_basic_address_v : integer;
        variable sram_bias_weights_read_basic_address_v : integer;
        variable sram_bias_weights_write_address_v : integer;
        variable sram_bias_weights_read_address_v : integer;
        variable storage_neuron_cnt,storage_param_cnt, read_neuron_cnt, read_param_cnt : integer;
        variable temp_data : fixed_point;
        variable new_conn_in_prev_v: fixed_point_vector;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				currentParam := 0;
				last_time_neuron_index := to_unsigned(maxWidth,8);
				start_read := '0';
				start_write:= '0';
				bias_and_weights_wr_request <= '0';
                bias_and_weights_rd_request <= '0';
			elsif dist_mode = resetWeights then
			    if (last_time_neuron_index /= current_neuron) then 
                    currentParam := 0;
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
                    sram_reset_address <= std_logic_vector(to_signed(sram_reset_address_v, sram_reset_address'length));
                    
                end if;
                
                if  currentParam <= paramsPerNeuronWeights+1 then 
                    currentParam := currentParam + 1;                   
                end if;
			
			elsif dist_mode = intermediate then -- used to be idle?
				bias_and_weights_wr_request <='0';
			else
				current_layer_sample := to_integer(current_layer);

				last_neuron := (current_neuron = maxWidth-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1)); -- or ((current_layer_sample = 0) and (current_neuron = inputWidth-1));

				if last_neuron then
                    if dist_mode = feedback then 
                        if sram_mode = idle and bias_and_weights_wr_request='0' and start_read='0' then
                            storage_neuron_cnt:=0;
                            storage_param_cnt:=0;
                            bias_and_weights_wr_request <= '1';
                            sram_bias_weights_write_basic_address_v := (to_integer(current_layer)+1)*totalParamsPerNeuron*maxWidth;
                            
                            sram_bias_weights_write_address <= std_logic_vector(to_signed(sram_bias_weights_write_basic_address_v, sram_bias_weights_write_address'length));
                            sram_bias_weights_write_data <= std_logic_vector(weights_out(storage_neuron_cnt)(storage_param_cnt));

                        end if;
                    elsif dist_mode = intermediate or dist_mode = feedforward then
                        if sram_mode = idle and bias_and_weights_wr_request='0' and bias_and_weights_rd_request='0' and (current_layer_sample /= totalLayers-1) then
                            bias_and_weights_wr_request <= '1';
                            storage_param_cnt:=0;
                            sram_bias_weights_write_basic_address_v := (to_integer(current_layer)+1)*totalParamsPerNeuron*maxWidth+totalParamsPerNeuron-1;
                            sram_bias_weights_write_address <= std_logic_vector(to_signed(sram_bias_weights_write_basic_address_v, sram_bias_weights_write_address'length));
                            sram_bias_weights_write_data <= std_logic_vector(conn_out(storage_param_cnt));
                        end if;
                    end if;
                
				end if;
				
				if dist_mode = waiting and bias_and_weights_wr_request='0' and bias_and_weights_rd_request='0' then
				    bias_and_weights_wr_request <= '1';
                    storage_param_cnt:=0;
                    sram_bias_weights_write_basic_address_v := (to_integer(current_layer))*totalParamsPerNeuron*maxWidth+totalParamsPerNeuron-1;
                    sram_bias_weights_write_address <= std_logic_vector(to_signed(sram_bias_weights_write_basic_address_v, sram_bias_weights_write_address'length));
                    sram_bias_weights_write_data <= std_logic_vector(connections_in(storage_param_cnt));
				end if;
				
                -- waiting, save the input connection
                if dist_mode = waiting and bias_and_weights_wr_request='1' then
                     storage_param_cnt := storage_param_cnt + 1;
                     if storage_param_cnt < maxWidth then
                         sram_bias_weights_write_address_v := sram_bias_weights_write_basic_address_v + storage_param_cnt*totalParamsPerNeuron;
                         sram_bias_weights_write_address <= std_logic_vector(to_signed(sram_bias_weights_write_address_v, sram_bias_weights_write_address'length));
                         sram_bias_weights_write_data <= std_logic_vector(connections_in(storage_param_cnt));
                     else
                        storage_param_cnt := 0;
                        bias_and_weights_wr_request <='0';
                        bias_and_weights_rd_request <='1';
                        read_param_cnt := 0;
                        read_neuron_cnt:= 0;
                        sram_bias_weights_read_basic_address_v := (to_integer(current_layer+1))*totalParamsPerNeuron*maxWidth;
                        sram_bias_weights_read_address <= std_logic_vector(to_signed(sram_bias_weights_read_basic_address_v, sram_bias_weights_write_address'length));
                                            
                     end if;
                end if;
                 
                
                if dist_mode = waiting and bias_and_weights_rd_request='1' then
                    read_param_cnt := read_param_cnt+1;
                    if read_param_cnt=totalParamsPerNeuron-1 then
                        read_neuron_cnt := read_neuron_cnt+1;
                        
                        if read_neuron_cnt=maxWidth then
                            bias_and_weights_rd_request <= '0';        
                        else
                            read_param_cnt := 0;
                        end if;
                    end if;
                    sram_bias_weights_read_address_v := sram_bias_weights_read_basic_address_v+read_neuron_cnt*totalParamsPerNeuron+read_param_cnt;
                    sram_bias_weights_read_address <= std_logic_vector(to_signed(sram_bias_weights_read_address_v, sram_bias_weights_write_address'length));
                    
                end if;
                                
                                
                -- Forward, save connections after per neuron's calculation	
                if dist_mode = feedforward and bias_and_weights_wr_request='1' then
                     storage_param_cnt := storage_param_cnt + 1;
                     if storage_param_cnt < maxWidth then
                         sram_bias_weights_write_address_v := sram_bias_weights_write_basic_address_v + storage_param_cnt*totalParamsPerNeuron;
                         sram_bias_weights_write_address <= std_logic_vector(to_signed(sram_bias_weights_write_address_v, sram_bias_weights_write_address'length));
                         sram_bias_weights_write_data <= std_logic_vector(conn_out(storage_param_cnt));
                     else
                        storage_param_cnt := 0;
                        bias_and_weights_wr_request <='0';
                        bias_and_weights_rd_request <= '1';
                        read_neuron_cnt := 0;
                        read_param_cnt := 0;
                        sram_bias_weights_read_basic_address_v := (to_integer(current_layer+2))*totalParamsPerNeuron*maxWidth;
                        sram_bias_weights_read_address <= std_logic_vector(to_signed(sram_bias_weights_read_basic_address_v, sram_bias_weights_write_address'length));
                     end if;
                end if;
                
                -- Forward, read biases and weights for nextlayer.
                if dist_mode = feedforward and bias_and_weights_rd_request='1' then
                    read_param_cnt := read_param_cnt+1;
                    if read_param_cnt=totalParamsPerNeuron-1 then
                        read_neuron_cnt := read_neuron_cnt+1;
                        
                        if read_neuron_cnt=maxWidth then
                            bias_and_weights_rd_request <= '0';                  
                        else
                            read_param_cnt := 0;
                        end if;
                    end if;
                    
                    sram_bias_weights_read_address_v := sram_bias_weights_read_basic_address_v+read_neuron_cnt*totalParamsPerNeuron+read_param_cnt;
                    sram_bias_weights_read_address <= std_logic_vector(to_signed(sram_bias_weights_read_address_v, sram_bias_weights_write_address'length));
                end if;
                                    
                
				if dist_mode = feedback and bias_and_weights_wr_request='1' then
                           
                    if storage_param_cnt=totalParamsPerNeuron-1 then

                        storage_neuron_cnt := storage_neuron_cnt+1;
                        
                        if storage_neuron_cnt=maxWidth then
                            bias_and_weights_wr_request <= '0';
                            sram_bias_weights_write_data <= (others=>'Z');
                            start_read := '1';
                        else
                            storage_param_cnt := 0;
                            sram_bias_weights_write_data <= std_logic_vector(weights_out(storage_neuron_cnt)(storage_param_cnt));
                        end if;
                        
                    elsif storage_param_cnt=totalParamsPerNeuron-2 then -- save bias
                        sram_bias_weights_write_data <= std_logic_vector(biases_out(storage_neuron_cnt));
                    else
                        sram_bias_weights_write_data <= std_logic_vector(weights_out(storage_neuron_cnt)(storage_param_cnt));
                    end if;
                   
                    sram_bias_weights_write_address_v := sram_bias_weights_write_basic_address_v+storage_neuron_cnt*totalParamsPerNeuron+storage_param_cnt;
                    
                    sram_bias_weights_write_address <= std_logic_vector(to_signed(sram_bias_weights_write_address_v, sram_bias_weights_write_address'length));
                    
                    storage_param_cnt := storage_param_cnt+1;
                end if;
                
                if dist_mode = feedback and bias_and_weights_wr_request='0' and start_read='1' then
                    start_read:='0';
                    read_neuron_cnt:=0;
                    bias_and_weights_rd_request<='1';
                    if current_layer_sample/=0 then
                        sram_bias_weights_read_basic_address_v := (to_integer(current_layer)+1)*totalParamsPerNeuron*maxWidth-totalParamsPerLayer;                                       
                    else
                        sram_bias_weights_read_basic_address_v := (to_integer(current_layer)+1)*totalParamsPerNeuron*maxWidth;
                    end if;
                    
                    sram_bias_weights_read_address <= std_logic_vector(to_signed(sram_bias_weights_read_basic_address_v, sram_bias_weights_write_address'length));
                    read_param_cnt:=0;
                end if;
                          
                if dist_mode = feedback and bias_and_weights_rd_request='1' then
                    read_param_cnt := read_param_cnt+1;
                    if read_param_cnt=totalParamsPerNeuron then
                        read_neuron_cnt := read_neuron_cnt+1;
                        
                        if read_neuron_cnt=maxWidth then
                            bias_and_weights_rd_request <= '0';
                        else
                            read_param_cnt := 0;
                        end if;
                    end if;
                    
                    if current_layer_sample/=0 then
                        if read_param_cnt = totalParamsPerNeuron-1 then
                            sram_bias_weights_read_address_v := sram_bias_weights_read_basic_address_v+read_neuron_cnt*totalParamsPerNeuron+read_param_cnt-totalParamsPerLayer;
                        else
                            sram_bias_weights_read_address_v := sram_bias_weights_read_basic_address_v+read_neuron_cnt*totalParamsPerNeuron+read_param_cnt;
                        end if;
                        
                    else
                        sram_bias_weights_read_address_v := sram_bias_weights_read_basic_address_v+read_neuron_cnt*totalParamsPerNeuron+read_param_cnt;
                    end if;
                    
                    sram_bias_weights_read_address <= std_logic_vector(to_signed(sram_bias_weights_read_address_v, sram_bias_weights_write_address'length));
                    
                end if;

			end if;
			
        elsif falling_edge(clk) then
            -- here we read weights, bias and might connections
            temp_data :=signed(sram_bias_weights_read_data);
            if bias_and_weights_rd_request='1' then
                if dist_mode = waiting or dist_mode = feedforward or dist_mode = feedback then
                    if read_param_cnt=totalParamsPerNeuron-2 then
                        biases_rd_from_sram(read_neuron_cnt) <= temp_data;
                    elsif read_param_cnt=totalParamsPerNeuron-1 then    
                        conn_rd_from_sram(read_neuron_cnt) <= temp_data;
                    elsif read_param_cnt<totalParamsPerNeuron-2 then
                        weights_rd_from_sram(read_neuron_cnt)(read_param_cnt) <= temp_data;
                    end if;
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

