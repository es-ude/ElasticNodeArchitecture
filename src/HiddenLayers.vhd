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
			
			dist_mode				:	in uint8_t;
					
			connections_in			:	in fixed_point_vector;
			connections_out		:	out fixed_point_vector;

			wanted					:	in fixed_point_vector
			-- errors_out				:	out fixed_point_vector
		);
end HiddenLayers;

architecture Behavioral of HiddenLayers is

-- signal weights : fixed_point_matrix_array := (others => (others => (others => init_weight))); -- weights for all the hidden layers
-- signal weights : fixed_point_matrix := (others => (others => init_weight));
signal weights_in, weights_out : fixed_point_matrix;
signal conn_in, conn_out, conn_out_prev, err_in, err_out, bias_in, bias_out : fixed_point_vector;
-- signal connections : fixed_point_array;
signal output_layer : std_logic;
signal n_feedback_s : integer range 0 to 2;

-- weights ram interface
constant WEIGHTS_RAM_WIDTH					: integer := log2(l);
signal weights_wr							 	: std_logic := '0';
signal weights_rd_address,weights_wr_address	: std_logic_vector(WEIGHTS_RAM_WIDTH-1 downto 0);
signal weights_din, weights_dout			: weights_vector; -- read entire layer's weights at a time 
signal invert_clk								: std_logic;
signal reset_counter 						: unsigned(WEIGHTS_RAM_WIDTH-1 downto 0) := (others => '0'); -- l+1 means it's done

-- conn ram interface
constant CONN_RAM_WIDTH						: integer := log2(l+1);
signal conn_wr									: std_logic := '0';
signal conn_address_a,conn_address_b	: std_logic_vector(CONN_RAM_WIDTH-1 downto 0);
signal conn_wr_din, conn_rd_dout_a, conn_rd_dout_b	: conn_vector;
signal conn_write, conn_rd_b				: fixed_point_vector; -- data to be written
signal conn_feedback							: fixed_point_vector;

-- bias ram interface
constant BIAS_RAM_WIDTH						: integer := log2(l);
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
		clk, reset, n_feedback, dist_mode, output_layer, current_neuron, conn_in, conn_out, conn_out_prev, err_in, err_out, weights_in, weights_out, biases_in, biases_out
	);
output_layer <= '1' when current_layer = l-1 else '0';

-- memory
invert_clk <= not clk;
-- write on feedback, when correct layer
weights:
	entity neuralnetwork.bram_tdp(rtl) generic map
	(
		b*w*w, WEIGHTS_RAM_WIDTH
	) port map
	( -- read port A, write port B
		invert_clk, '0', weights_rd_address, (others => '0'), weights_dout, clk, weights_wr, weights_wr_address, weights_din, open
	);
-- simple writing logic
-- write when resetting, or after each feedback layer, or after last feedback layer
weights_wr <= '1' when reset = '1' or (n_feedback = 2 and dist_mode = to_unsigned(2, dist_mode'length)) or (dist_mode = to_unsigned(5, dist_mode'length))
	else '0';

	n_feedback_s <= n_feedback when (current_layer > 0 and current_layer < l-1) else 2;
-- convert between ram vectors and weights
vtw:
	entity neuralnetwork.vectortoweights(Behavioral) port map
	(
		weights_dout, weights_in
	);
wtv:
	entity neuralnetwork.weightstovector(Behavioral) port map
	(
		weights_out, weights_din
	);
	
connections:
	entity neuralnetwork.bram_tdp(rtl) generic map
	(
		b*w, CONN_RAM_WIDTH
	) port map
	(
		clk, conn_wr, conn_address_a, conn_wr_din, conn_rd_dout_a, invert_clk, '0', conn_address_b, (others => '0'), conn_rd_dout_b
	);
-- data to be written for connections out
conn_write <= connections_in when (conn_address_a = std_logic_vector(to_unsigned(0, conn_address_a'length))) 
					else conn_out when n_feedback = 1
					else conn_out; -- (others => (others => '1')); -- write connections in in address 0, otherwise outputs
-- write connections out after each layer in feed forward, connection in during calculate
conn_wr <= '1' when (n_feedback = 2 and (dist_mode = to_unsigned(6, dist_mode'length) or dist_mode = to_unsigned(1, dist_mode'length))) or dist_mode = to_unsigned(7, dist_mode'length)
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
			if dist_mode = to_unsigned(1, dist_mode'length) then 
				-- between layers
				conn_in <= conn_out;
			-- inbetween or feedback
			elsif dist_mode = to_unsigned(6, dist_mode'length) or dist_mode = to_unsigned(2, dist_mode'length) then
				conn_in <= conn_rd_b;
			end if;
		-- new start
		elsif n_feedback = 1 and current_layer = to_unsigned(0, current_layer'length) and current_neuron = to_unsigned(0, current_neuron'length) then
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
		b*w, BIAS_RAM_WIDTH
	) port map
	( -- read port A, write port B
		invert_clk, '0', bias_rd_address, (others => '0'), bias_dout, clk, bias_wr, bias_wr_address, bias_din, open
	);
bias_wr <= '1' when reset = '1' or (n_feedback = 2 and dist_mode = to_unsigned(2, dist_mode'length)) or (dist_mode = to_unsigned(5, dist_mode'length))
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
		variable current_layer_sample : integer range 0 to l;
		variable last_neuron, second_last_neuron : boolean;
		
	begin
		if reset = '1' then
			weights_rd_address <= (others => '0'); -- preload first one
		else
			if rising_edge(clk) then
				
				
				last_neuron := current_neuron = w-1;
				second_last_neuron := current_neuron = w-1-1;
						
				current_layer_sample := to_integer(current_layer);
				
				-- when forward, load weights for next (clocks inverted)
				if n_feedback = 1 then
					if last_neuron and current_layer < l - 1 then -- dont load l+1 weights
						weights_rd_address <= std_logic_vector(resize(current_layer + 1, WEIGHTS_RAM_WIDTH));
					end if;
				-- when backward, load next 
				elsif n_feedback = 0 then
					if last_neuron then
						weights_rd_address <= std_logic_vector(resize(current_layer - 1, WEIGHTS_RAM_WIDTH));
						-- if currently in hidden layer, queue write next cycle
						-- if current_layer_sample > 0 and current_layer_sample < l-1 then
						-- end if;
					end if;
				-- preload
				elsif dist_mode = to_unsigned(0, dist_mode'length) then
					weights_rd_address <= (others => '0'); -- preload first one 
				-- inbetween 
				elsif dist_mode = to_unsigned(6, dist_mode'length) then
					weights_rd_address <= std_logic_vector(to_unsigned(l-1, weights_rd_address'length)); -- preload first one 
				end if;
				-- weights_in <= vector_to_weights(weights_dout); -- weights((current_layer_sample+1)*w-1 downto current_layer_sample*w);

			end if;
		end if;
	end process;
	
	
	--writing (bias & weights)
	process(clk, current_layer, reset) is
		variable current_layer_sample : integer range 0 to l;
		variable last_neuron : boolean;

	begin
		if rising_edge(clk) then
			if reset = '1' then
				-- reset all weights in memory
				if reset_counter < l+1 then
					-- data is being set by Layer.vhd
					weights_wr_address <= std_logic_vector(reset_counter);
					bias_wr_address <= std_logic_vector(reset_counter);
					reset_counter <= reset_counter + to_unsigned(1, reset_counter'length);
					--weights_wr <= '1';
				else 
					--weights_wr <= '0';
					weights_wr_address <= (others => '0');
				end if;
				
			else

				reset_counter <= (others => '0');
		
				last_neuron := current_neuron = w-1;
				
				-- weights_wr <= '0';
				--if n_feedback = '0' and last_neuron then 
				--	weights_wr <= '1';		
				--else
				--	weights_wr <= '0';
				--end if;
				
				current_layer_sample := to_integer(current_layer);
				
				if last_neuron then
					weights_wr_address <= std_logic_vector(resize(current_layer, WEIGHTS_RAM_WIDTH));
					bias_wr_address <= std_logic_vector(resize(current_layer, BIAS_RAM_WIDTH));

				end if;
			end if;

		end if;
	end process;
--	--writing
--	process(clk, current_layer, reset) is
--		variable current_layer_sample : integer range 0 to l;
--		variable last_neuron : boolean;
--		
--		variable reset_counter : integer range 0 to l+1 := 0; -- l+1 means it's done
--
--	begin
--		if rising_edge(clk) then
--			if reset = '1' then
--				-- reset all weights in memory
--				if reset_counter < l+1 then
--					weights_wr_address <= std_logic_vector(to_unsigned(reset_counter, WEIGHTS_RAM_WIDTH));
--					weights_wr <= '1';
--				else 
--					weights_wr <= '0';
--				end if;
--				
--			else
--				reset_counter := 0;
--		
--				last_neuron := current_neuron = w-1;
--				
--				-- weights_wr <= '0';
--				if n_feedback = '0' and last_neuron then 
--					weights_wr <= '1';		
--				else
--					weights_wr <= '0';
--				end if;
--				
--				current_layer_sample := to_integer(current_layer);
--				
--				if last_neuron then
--					weights_wr_address <= std_logic_vector(resize(current_layer, WEIGHTS_RAM_WIDTH));
--					bias_wr_address <= std_logic_vector(resize(current_layer, BIAS_RAM_WIDTH));
--				end if;
--			end if;
--		end if;
--	end process;
	
	
	-- connections ram process
	process(reset, clk, current_layer) is
		variable current_layer_sample : integer range 0 to l;
	begin
		if reset = '1' then
			conn_address_a <= (others => '0');
			conn_address_b <= (others => '0');
		elsif rising_edge(clk) then
			-- conn_wr <= '0';
			
			current_layer_sample := to_integer(current_layer);
			-- weights_wr_address <= std_logic_vector(resize(current_layer, WEIGHTS_RAM_WIDTH));
			
			-- update conn ram reading address 
			if current_neuron = w-1 then
				-- when forward, load weights for next (clocks inverted)
				if n_feedback = 1 then
					conn_address_a <= std_logic_vector(resize(current_layer + 1, CONN_RAM_WIDTH));
					conn_address_b <= std_logic_vector(to_unsigned(l-1, CONN_RAM_WIDTH));
				-- when backward, load next 
				elsif n_feedback = 0 then
					conn_address_b <= std_logic_vector(resize(current_layer-1, CONN_RAM_WIDTH)); 	-- conn_prev
					conn_address_a <= std_logic_vector(resize(current_layer, CONN_RAM_WIDTH));		-- conn_in
				end if;
			elsif current_neuron = w-1-1 then
				if n_feedback = 0 then
				end if;
			end if;
		end if;
	end process;
	
	-- bias ram process
	process(reset, clk, current_layer) is
		variable current_layer_sample : integer range 0 to l;
		variable last_neuron, second_last_neuron : boolean;
	begin
		if reset = '1' then
			-- bias_wr <= '1'; -- address done in weights write process
			bias_rd_address <= (others => '0');

		else
			if rising_edge(clk) then
			
				current_layer_sample := to_integer(current_layer);
				last_neuron := current_neuron = w-1; 
				second_last_neuron := current_neuron = w-1-1; -- load new bias one clk early

				--if n_feedback = '0' and last_neuron then 
				--	bias_wr <= '1';
				--else
				--	bias_wr <= '0';
				--end if;
				
				-- assign address to read from 
				if n_feedback = 1 then
					if last_neuron then
						bias_rd_address <= std_logic_vector(resize(current_layer + 1, BIAS_RAM_WIDTH));
					end if;
				-- when backward, load next 
				elsif n_feedback = 0 then
					if last_neuron then
						bias_rd_address <= std_logic_vector(resize(current_layer - 1, BIAS_RAM_WIDTH));
					end if;
				-- between feedback and feedforward
				elsif dist_mode = to_unsigned(6, dist_mode'length) then
					bias_rd_address <= std_logic_vector(to_unsigned(l-1, BIAS_RAM_WIDTH));
				end if;
			end if;
		end if;
	end process;
	
	-- error process
	process(clk) is
			variable current_layer_sample : integer range 0 to l;
	begin
		if rising_edge(clk) then
			current_layer_sample := to_integer(current_layer);

			if n_feedback = 2 then 
--				-- feedback errors when layer complete
--				if current_neuron = w-1 then
--					err_in <= err_out; -- forward results of previous layer to next layer
--				end if;
--			elsif n_feedback = 2 then
				-- when in the last feed forward, preload the conn_out_prev
				if dist_mode = to_unsigned(6, dist_mode'length) then
					err_in <= wanted - conn_out;
				-- between layers of feedback
				elsif dist_mode = to_unsigned(2, dist_mode'length) then
					err_in <= err_out; -- forward results of previous layer to next layer
				end if;
			end if;
		end if;	
	end process;
	
	
	-- main process
	process(clk, current_layer, connections_in) is
		variable current_layer_sample : integer range 0 to l;
	begin
		-- set inputs correctly before they're needed
		if falling_edge(clk) then
			current_layer_sample := to_integer(current_layer);
			current_layer_sample_signal <= to_unsigned(current_layer_sample, current_layer_sample_signal'length);
			-- weights_wr <= '0';
		
			-- set output connections correctly
			if dist_mode = to_unsigned(6, dist_mode'length) then -- between forward and back
				connections_out <= conn_out;
			end if;
			
			-- save results for future learning
			if n_feedback = 0 then 
				-- conn_in <= conn_rd_b;
				-- if current_layer_sample > 0 and current_layer_sample < l then -- hidden layer active
				if current_layer_sample > 0 then
					--- 
					--- conn_out_prev <= connections(current_layer_sample - 1); -- use old output of layer for learning (current_layer -1 will be active next clock)
					
					if current_layer_sample = 1 then
						--- conn_in <= connections_in; -- first input connection is not saved
					else
						--- conn_in <= connections(current_layer_sample-2);
					end if;
				end if;
					-- weights_in <= vector_to_weights(weights_dout); -- weights((current_layer_sample+1)*w-1 downto current_layer_sample*w);
					
					----------
--					-- type incompatibility: writing part of a fp_matrix_array to a fp_matrix
--					for i in 0 to w-1 loop
--						weights_in(i) <= weights(current_layer_sample, i);
--					end loop;

				-- if current_layer_sample < l-1 then
					
					-- feedback errors when layer complete
					if current_neuron = w-1 then
						--err_in <= err_out; -- forward results of previous layer to next layer
					end if;
					
						-- ***
--						-- currently addressing w of w*l 
--						-- type incompatibility: writing part of a fp_matrix_array to a fp_matrix
--						for i in 0 to w-1 loop
--							weights(current_layer_sample, i) <= weights_out(i);
--						end loop;
						
						-- weights_din <= weights_to_vector(weights_out);
						-- weights_wr <= '1';
						-- weights((current_layer_sample+1)*w-1 downto current_layer_sample*w) <= weights_out(w-1 downto 0); -- save updated weights
						-- weights <= weights_out;
--					else 
--						errors_out <= err_out;
--					end if;
----					elsif current_layer_sample = 1 then
----						conn_in <= connections_in;
--				else
--					err_in <= errors_in;
				-- end if;
				
			elsif n_feedback = 1 then
				-- current_layer_sample := current_layer_sample + 1;
				-- hidden layer was active
				-- if current_layer_sample > 0 and current_layer_sample < l-1 then -- hidden layer active
				--if current_layer_sample > 0 then
				-- conn_in <= conn_out; -- forward results of previous layer to next layer
					--- connections(current_layer_sample) <= conn_out;
				-- conn_write <= conn_out;
				
				-- perform feedback when last neuron calculated
				if current_neuron = w-1 then
					conn_feedback <= conn_out;
				end if;
				
				-- when in the last feed forward, preload the conn_out_prev
				if current_layer_sample = l-1 then
					--- conn_out_prev <= conn_out; -- use old output of layer for learning (current_layer -1 will be active next clock)
					--- conn_in <= connections(l-2); -- set old input of last layer
					--err_in <= wanted - conn_out;
				end if;
				--else
--					conn_in <= connections_in;
--					connections(0) <= connections_in;
--				end if;
			else
				conn_feedback <= connections_in; -- initialise conn_in properly
				-- conn_write <= connections_in;

				-- conn_in <= connections_in;
				--- connections(0) <= connections_in;
				-- conn_in <= (others => (others => '0'));
			end if;
			
--			-- outside connections and errors
--			if current_layer_sample = 1 then
--				-- connections_out <= conn_out;
--
--			end if;		
		end if;	
	end process;
	
--		-- set outputs correctly
--		elsif rising_edge(clk) then
--			if current_layer_sample >= 0 and current_layer_sample < l then -- hidden layer active
--				if current_layer_sample > 0 and current_layer_sample < l-1 then
--					-- if training, save weights
--					if n_feedback = '0' then
----						weights(current_layer_sample) <= weights_out; -- save updated weights
--					end if;
--				end if;
--				 -- TODO can probably get away from n_feedback_s, checking for layer anyway...
--				--if n_feedback = '1' then 
--				--	n_feedback_s <= n_feedback; --  when (current_layer > 0 and current_layer < l-1) else 'Z';
--				--end if;
----			else
----				n_feedback_s <= 'Z';
--			end if;
--		end if;	
--		-- current_layer changed
--		else
--			-- sample current layer once with rising, not falling edge
--			current_layer_sample := to_integer(current_layer);
			
--			-- is current hidden layer
--			if current_layer_sample > 0 and current_layer_sample < l-1 then -- hidden layer active
--				-- n_feedback_s <= n_feedback;
--				weights_in <= weights(current_layer_sample);
				
--			-- outside connections and errors
--			elsif current_layer_sample = 1  then
--				-- if forward, connect to connections_in
--				-- if n_feedback_s = '1' then
--				-- conn_in <= connections_in;
--				-- if backward, connect to errors_in
--			elsif current_layer_sample = l-1 then
--			-- if n_feedback_s = '0' then
--				err_in <= errors_in;
--				-- end if;
--			end if;
--		end if;



end Behavioral;

