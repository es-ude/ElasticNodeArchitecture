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
			clk				:	in std_logic;

			n_feedback		:	in std_logic;
			current_layer	:	in uint8_t;

			connections_in	:	in fixed_point_vector;
			connections_out:	out fixed_point_vector;

			errors_in		:	in fixed_point_vector;
			errors_out		:	out fixed_point_vector
		);
end HiddenLayers;

architecture Behavioral of HiddenLayers is

signal weights : fixed_point_matrix_array := (others => (others => (others => factor_2))); -- weights for all the hidden layers
signal weights_in, weights_out : fixed_point_matrix;
signal conn_in, conn_out, err_in, err_out : fixed_point_vector;
signal connections : fixed_point_array;
signal n_feedback_s : std_logic;
begin

lay: 
	entity neuralNetwork.Layer(Behavioral) port map
	(
		clk, n_feedback_s, conn_in, conn_out, err_in, err_out, weights_in, weights_out
	);
	
	-- n_feedback_s <= n_feedback when (current_layer > 0 and current_layer < l-1) else 'Z';
	connections_out <= conn_out when current_layer >= l-2 else (others => zero);
	
	process(clk, current_layer) is
		variable current_layer_sample : integer range 0 to l;
	begin
		-- set inputs correctly before they're needed
		if falling_edge(clk) then
			
			
				-- save results for future learning
				if n_feedback_s = '0' then 
					conn_in <= connections(current_layer_sample); -- use old output of layer for learning (current_layer -1 will be active next clock)
				elsif n_feedback_s = '1' then
					connections(current_layer_sample) <= conn_out;
					-- hidden layer was active
					if current_layer_sample > 0 and current_layer_sample < l-1 then -- hidden layer active
						conn_in <= conn_out; -- forward results of previous layer to next layer
					end if;
--				else
--					conn_in <= (others => (others => '0'));
				end if;
				
				-- outside connections and errors
				if current_layer_sample = l-2 then
					-- connections_out <= conn_out;
					errors_out <= err_out;
				end if;	
				
			
		-- set outputs correctly
		elsif rising_edge(clk) then
			if current_layer_sample >= 0 and current_layer_sample < l then -- hidden layer active
				if current_layer_sample > 0 and current_layer_sample < l-1 then
					-- if training, save weights
					if n_feedback_s = '0' then
						weights(current_layer_sample) <= weights_out; -- save updated weights
					end if;
				end if;
				 -- TODO can probably get away from n_feedback_s, checking for layer anyway...
				if n_feedback = '1' then 
					n_feedback_s <= n_feedback; --  when (current_layer > 0 and current_layer < l-1) else 'Z';
				end if;
			else
				n_feedback_s <= 'Z';
			end if;
			
		-- current_layer changed
		else
			-- sample current layer once with rising, not falling edge
			current_layer_sample := to_integer(current_layer);
			
			-- is current hidden layer
			if current_layer_sample > 0 and current_layer_sample < l-1 then -- hidden layer active
				-- n_feedback_s <= n_feedback;
				weights_in <= weights(current_layer_sample);
				
			-- outside connections and errors
			elsif current_layer_sample = 0 then
				-- if forward, connect to connections_in
				-- if n_feedback_s = '1' then
				conn_in <= connections_in;
				-- if backward, connect to errors_in
			elsif current_layer_sample = l-1 then
			-- if n_feedback_s = '0' then
				err_in <= errors_in;
				-- end if;
			end if;
		end if;
	end process;


end Behavioral;

