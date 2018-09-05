----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:54:44 07/07/2015 
-- Design Name: 
-- Module Name:    Layer - Behavioral 
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

library neuralnetwork;
use neuralnetwork.Common.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Layer is
	port (
			clk						:	in std_logic;
			reset					: 	in std_logic;

			n_feedback				:	in integer range 0 to 2;
			dist_mode				:	in distributor_mode;
			current_layer			:	in uint8_t; -- tell each to only consider own error
			current_neuron			:	in uint8_t;
					
			connections_in			:	in fixed_point_vector;
			connections_out			:	out fixed_point_vector;
			connections_out_prev	:	in fixed_point_vector;

			errors_in				:	in fixed_point_vector;
			errors_out				:	out fixed_point_vector;
			
			weights_in				: 	in fixed_point_matrix; -- one fpv per neuron
			weights_out				: 	out fixed_point_matrix;
			
			biases_in				:	in fixed_point_vector;
			biases_out				: 	out fixed_point_vector
		);
end Layer;

architecture Behavioral of Layer is
	-- signal errors_matrix : fixed_point_matrix;
	signal reset_mux : std_logic;
	
	-- signal errors_out, errors_in : fixed_point
	component sumMux
		port (
			reset		:	in std_logic;
			clk			:	in std_logic;
			index		:	in integer range 0 to maxWidth-1;
			errors_in	:	in fixed_point_vector;
			errors_out	: 	out fixed_point_vector
			);
	end component;

	component Neuron
		-- generic ( 
		port (
			clk					:	in std_logic;

			n_feedback			:	in integer range 0 to 2;
			--output_neuron		:	in std_logic; -- tell neuron to only consider own error

			current_layer			:	in uint8_t;
			current_neuron			: 	in uint8_t;
			--index					:	integer range 0 to maxWidth-1;

			input_connections : 	in fixed_point_vector;
			input_errors		:	in fixed_point_vector;

			output_connection	:	out fixed_point;
			output_previous	:	in fixed_point;
			output_errors		: 	out fixed_point_vector;
			
			weights_in			: 	in fixed_point_vector;
			weights_out			: 	out fixed_point_vector;
		
			bias_in				: 	in fixed_point;
			bias_out				: 	out fixed_point
			);
	end component;

	signal neuron_clk : std_logic := '0';

	signal conn_in, error_out, weight_in, weight_out : fixed_point_vector;
	signal conn_out, conn_out_prev : fixed_point; -- 
	
	signal current_neuron_int, next_neuron_int, previous_neuron_int : integer range 0 to maxWidth-1; -- next and previous are half clock cycle delayed/ahead
	signal bias_in, bias_out : fixed_point;
	signal next_neuron : uint8_t := (others => '0');
	signal output_previous_buffer : fixed_point_vector; -- buffer previous output because it switches to next layer too soon
	signal errors_out_seq : fixed_point;
begin


	-- grab current neuron
--	process (clk) is
--	begin
--		if rising_edge(clk) then
	current_neuron_int <= to_integer(current_neuron);
	
	-- predict next neuron for preloading
	process (clk, current_neuron) is
	begin
		if rising_edge(clk) then
			previous_neuron_int <= current_neuron_int;

			-- no change if currently idle
			if dist_mode /= waiting then
				if current_neuron < maxWidth-1 then
					next_neuron <= current_neuron + 1;
				else
					next_neuron <= (others => '0');
					output_previous_buffer <= connections_out_prev; -- hold this value of output_previous for next layer
				end if;
			end if;
		end if;
	end process;
	next_neuron_int <= to_integer(next_neuron);
	

	
	-- TODO: conn in timing?

--		end if;
--	end process;
	
	
	-- all of the multiplexed values for different neurons must be clocked (otherwise mapping errors)
--	-- assign in/out based on neuron
--	process (clk) is
--	begin
--		if falling_edge(clk) then
	-- assign from vector or matrix for current neuron
		-- conn_in <= connections_in(current_neuron_int);
	process(clk, conn_out) is 
	begin
		if falling_edge(clk) then
			connections_out(previous_neuron_int) <= conn_out;
		end if;
	end process;
	process (clk, connections_out_prev) is
	begin
		if falling_edge(clk) then
			conn_out_prev <= connections_out_prev(next_neuron_int);
			-- conn_out_prev <= output_previous_buffer(next_neuron_int);
		end if;
	end process;
	
	process(clk, bias_out, current_neuron_int, reset) is 
	begin
		if reset = '1' then
			biases_out <= (others => zero);
		else
			if falling_edge(clk) then
				biases_out(previous_neuron_int) <= bias_out;
			end if;
		end if;
	end process;

	process (clk, biases_in, current_neuron_int) is
	begin
		if falling_edge(clk) then
			bias_in <= biases_in(next_neuron_int);
		end if;
	end process;
-- weight_in <= weights_in(current_neuron_int);

	process (clk, weights_in) is
	begin
		if falling_edge(clk) then
			weight_in <= weights_in(next_neuron_int);
		end if;
	end process;
	process (clk, weight_out, reset) is
	begin
		-- create default weight for writing to bram
		if reset = '1' then
			-- weights_out <= (others => (others => init_weight));
			if current_layer = 0 then
				weights_out <= (others => init_input_weights);
			else
				weights_out <= (others => init_hidden_weights);
			end if;
		else
			if falling_edge(clk) then
				weights_out(previous_neuron_int) <= weight_out;
			end if;
		end if;
	end process;
	
	-- error mux reset
	process (reset, clk) is
	begin
		if reset = '1' then
			reset_mux <= '1';
		elsif rising_edge(clk) then
			if n_feedback = 2 then
				reset_mux <= '1';
			else
				reset_mux <= '0';
			end if;
		end if;
	end process;
--	process (clk, error_out) is
--	begin
--		if falling_edge(clk) then
--			errors_matrix(previous_neuron_int) <= error_out;
----			if current_neuron_int = 0 then
----				errors_out_seq <= error_out;
----			else
----				errors_out_seq <= errors_out_seq + error_out;
----			end if;
--		end if;
--	end process;
--		end if;
--	end process;
	
	mux : sumMux port map
	(
		reset => reset_mux,
		clk => clk,
		index => previous_neuron_int,
		errors_in => error_out,
		errors_out => errors_out
	);

	-- only clock neuron logic when calculating something
	neuron_clk <= clk when dist_mode = feedforward or dist_mode = feedback;

-- gen_neutrons:
--	for i in 0 to maxWidth-1 generate neuron_x : Neuron generic map
--	(
--		index => i
--	)
neur:
	Neuron
	port map 
	(
		clk => neuron_clk, 
		n_feedback => n_feedback,
		current_layer => current_layer,
		current_neuron => current_neuron,
		--output_neuron => output_layer,
		--index => current_neuron_int,
		input_connections => connections_in, 
		input_errors => errors_in,
		output_connection => conn_out,
		output_previous => conn_out_prev,
		output_errors => error_out,
		weights_in => weight_in,
		weights_out => weight_out,
		bias_in => bias_in,
		bias_out => bias_out
	);
	-- end generate;
end Behavioral;
