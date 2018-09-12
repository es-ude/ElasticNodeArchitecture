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
use IEEE.STD_LOGIC_1164.ALL;

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

			weights_wr_en 			:	in std_logic;
			weights 				:	inout weights_vector := (others => 'Z')
		);
end HiddenLayers;

architecture Behavioral of HiddenLayers is

-- signal weights : fixed_point_matrix_array := (others => (others => (others => init_weight))); -- weights for all the hidden layers
-- signal weights : fixed_point_matrix := (others => (others => init_weight));
signal errors_accrue_s : fixed_point_vector;
signal weights_in, weights_out : fixed_point_matrix;
signal conn_in, conn_out, conn_out_prev, err_in, err_out, bias_in, bias_out : fixed_point_vector;
-- signal connections : fixed_point_array;
signal n_feedback_s : integer range 0 to 2;

-- weights ram interface
constant WEIGHTS_RAM_WIDTH							: integer := log2(totalLayers);
signal weights_wr_a, weights_wr_b, weights_wr_ext	: std_logic := '0';
signal weights_address_a,weights_address_b			: std_logic_vector(WEIGHTS_RAM_WIDTH-1 downto 0);
signal weights_din_a, weights_din_b, weights_din_ann, weights_din_ext, weights_dout_a, weights_dout_b 	: weights_vector; -- read entire layer's weights at a time 
signal invert_clk									: std_logic;
signal reset_counter 								: unsigned(WEIGHTS_RAM_WIDTH-1 downto 0) := (others => '0'); -- l+1 means it's done

-- conn ram interface
constant CONN_RAM_WIDTH							: integer := log2(totalLayers+1);
signal conn_wr									: std_logic := '0';
signal conn_address_a,conn_address_b			: std_logic_vector(CONN_RAM_WIDTH-1 downto 0);
signal conn_wr_din, conn_rd_dout_a, conn_rd_dout_b	: conn_vector;
signal conn_write, conn_rd_b					: fixed_point_vector; -- data to be written
signal conn_feedback							: fixed_point_vector;

-- bias ram interface
constant BIAS_RAM_WIDTH						: integer := log2(totalLayers);
signal bias_wr									: std_logic := '0';
signal bias_rd_address,bias_wr_address	: std_logic_vector(BIAS_RAM_WIDTH-1 downto 0);
signal bias_din, bias_dout					: conn_vector;
signal biases_in, biases_out				: fixed_point_vector;

signal current_layer_sample_signal : uint8_t;
signal current_neuron_sample_signal : uint8_t;

begin

lay: 
	entity neuralNetwork.Layer(Behavioral) port map
	(
		clk, reset, n_feedback, dist_mode, current_layer, current_neuron, conn_in, conn_out, conn_out_prev, err_in, err_out, weights_in, weights_out, biases_in, biases_out
	);

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
weights_wr_b <= '1' when reset = '1' or (n_feedback = 2 and dist_mode = feedback) or (dist_mode = delay) or (weights_wr_ext = '1')
	else '0';
-- output weights to buffer when not being written
weights <= (others => 'Z') when weights_wr_en = '1' else weights_dout_b; -- (others => '1'); -- when weights_wr_en = '0' else (others => 'Z'); -- weights_dout_b
weights_din_b <= weights_din_ext when weights_wr_ext = '1' else weights_din_ann;

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
bias_wr <= '1' when reset = '1' or (n_feedback = 2 and dist_mode = feedback) or (dist_mode = delay)
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

	begin
		if rising_edge(clk) then
			if reset = '1' then
				weights_wr_ext <= '0';

				--reset_counter <= current_layer_sample;
				-- reset all weights in memory
				--if reset_counter < totalLayers+1 then
					-- data is being set by Layer.vhd
					weights_address_b <= std_logic_vector(resize(current_layer, weights_address_b'length));
					--weights_din_b <= weights_din_ann; -- retrieve defaults from Layer
					bias_wr_address <= std_logic_vector(resize(current_layer, weights_address_b'length));
					--reset_counter <= reset_counter + to_unsigned(1, reset_counter'length);
					--weights_wr <= '1';
				--else 
					--weights_wr <= '0';
					--weights_address_b <= (others => '0');
				--end if;
				
			-- weights being set from outside
			elsif weights_wr_en = '1' then
				-- sample incoming weights
				--weights_din_b <= weights;
				weights_wr_ext <= '1';
				weights_din_ext <= weights;
				weights_address_b <= std_logic_vector(resize(current_layer, weights_address_b'length));
			-- generic read for external read
			elsif dist_mode = intermediate then -- used to be idle?
				weights_wr_ext <= '0';
				weights_address_b <= std_logic_vector(to_unsigned(numHiddenLayers, WEIGHTS_RAM_WIDTH));
			else
				weights_wr_ext <= '0';
				reset_counter <= (others => '0');
		
				current_layer_sample := to_integer(current_layer);

				last_neuron := (current_neuron = maxWidth-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1)); -- or ((current_layer_sample = 0) and (current_neuron = inputWidth-1));
				-- last_neuron := current_neuron = maxWidth-1;
				
				-- weights_wr <= '0';
				--if n_feedback = '0' and last_neuron then 
				--	weights_wr <= '1';		
				--else
				--	weights_wr <= '0';
				--end if;
				
				-- weights_din_b <= weights_din_ann; -- load weights to be written to memory from the ann, not from outside

				if last_neuron then
					weights_address_b <= std_logic_vector(resize(current_layer, WEIGHTS_RAM_WIDTH));
					bias_wr_address <= std_logic_vector(resize(current_layer, BIAS_RAM_WIDTH));

				end if;
			end if;

		end if;
	end process;

	-- connections ram process
	process(reset, clk, current_layer) is
		variable current_layer_sample : integer range 0 to totalLayers;
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
		end if;
	end process;
	
	-- bias ram process
	process(reset, clk, current_layer) is
		variable current_layer_sample : integer range 0 to totalLayers;
		variable last_neuron, second_last_neuron : boolean;
	begin
		if reset = '1' then
			-- bias_wr <= '1'; -- address done in weights write process
			bias_rd_address <= (others => '0');

		else
			if rising_edge(clk) then
			
				current_layer_sample := to_integer(current_layer);

				last_neuron := (current_neuron = maxWidth-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1)); -- or ((current_layer_sample = 0) and (current_neuron = inputWidth-1));
				-- second_last_neuron := (current_neuron = maxWidth-1-1) or ((current_layer_sample = totalLayers-1) and (current_neuron = outputWidth-1));
					
				--last_neuron := current_neuron = maxWidth-1; 
				--second_last_neuron := current_neuron = maxWidth-1-1; -- load new bias one clk early

				-- assign address to read from 
				if n_feedback = 1 then
					if last_neuron then
						-- just stay in final layer for intermediate
						if current_layer < totalLayers-1 then
							bias_rd_address <= std_logic_vector(resize(current_layer + 1, BIAS_RAM_WIDTH));
						end if;
					end if;
				-- when backward, load next 
				elsif n_feedback = 0 then
					if last_neuron then
						-- stay in first layer until next round of query
						if current_layer > 0 then
							bias_rd_address <= std_logic_vector(resize(current_layer - 1, BIAS_RAM_WIDTH));
						end if;
					end if;
				-- between feedback and feedforward
				elsif dist_mode = intermediate then
					bias_rd_address <= std_logic_vector(to_unsigned(totalLayers-1, BIAS_RAM_WIDTH));
				elsif dist_mode = idle then
					bias_rd_address <= (others => '0');
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

