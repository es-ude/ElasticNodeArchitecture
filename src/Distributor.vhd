----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:56:17 07/27/2015 
-- Design Name: 
-- Module Name:    Distributor - Behavioral 
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
use IEEE.NUMERIC_STD.all;
library neuralnetwork;
use neuralnetwork.Common.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Distributor is
	port
	(
		clk				:	in std_logic;
		reset			: 	in std_logic;
		learn			:	in std_logic;
		calculate      	:  in std_logic;
		n_feedback_bus	:	out std_logic_vector(totalLayers downto 0) := (others => 'Z'); -- l layers + summation (at l)
		
		n_feedback		: 	out integer range 0 to 2; -- 0 is back, 1 forward, 2 inbetween
		current_layer	:	out uint8_t;
		current_neuron	:	out uint8_t;

		data_rdy       :  out std_logic;
		mode_out       :  out distributor_mode
	);
end Distributor;

architecture Behavioral of Distributor is
	signal mode : distributor_mode := idle; -- range 0 to 7 := 0; -- 0 idle 1 feedforward 2 feedback 3 feedback->feedforward
begin
	process (reset, clk, calculate, learn)
	type FeedbackType is (forward, back, idle);
	variable n_feedback_var : FeedbackType := idle;
	variable layer_counter : integer range -1 to totalLayers := 0;
	variable neuron_counter : integer range 0 to maxWidth := 0;
	begin

		-- set up before the clock cycle for hidden layers to sample current_layer
		if falling_edge(clk) then 
			-- keep distributor 
			if reset = '1' then
				neuron_counter := 0;
				n_feedback_var := idle; -- init feed forward
				mode <= idle;
				n_feedback_bus <= (others => 'Z');
				data_rdy <= '0';

				-- set current_layer so all layers are reset correctly
				if layer_counter < totalLayers-1 and layer_counter >= 0 then
					layer_counter := layer_counter + 1;
				else
					layer_counter := 0;
				end if;
				
				current_layer <= to_unsigned(layer_counter, current_layer'length);
			else
				--if learn = '1' then 
					-- start learning
				case mode is 
					when idle => -- init
						layer_counter := 0;
						neuron_counter := 0;
						n_feedback_var := idle;
						
						-- stay in idle until told to calculate
						if calculate = '1' then 
							mode <= waiting;
							n_feedback_var := forward;
							data_rdy <= '0';
						end if;
	--					data_rdy <= '0';
					when feedforward => -- feedforward
						neuron_counter := neuron_counter + 1;
						if n_feedback_var = idle then -- start again
							
							n_feedback_var := forward; -- reassert feedback after delay
							neuron_counter := 0;
						-- check for output layer
						elsif ((layer_counter = 0) and (neuron_counter = inputWidth)) or ((layer_counter = totalLayers-1) and (neuron_counter = outputWidth)) or (neuron_counter = maxWidth) then
						--elsif neuron_counter = maxWidth then
							-- go to next layer
							neuron_counter := 0;
							n_feedback_var := idle; -- one cycle delay
							
							-- move on to next layer
							layer_counter := layer_counter + 1;
							if layer_counter = totalLayers then -- through all layers
								if learn = '1' then
									n_feedback_var := idle;
									mode <= intermediate;
								else
									-- if not learning, just return to first layer for feed forward
									n_feedback_var := idle;
									mode <= doneQuery;
								end if;
							end if;
						end if;

					when feedback => -- feedback
						neuron_counter := neuron_counter + 1;
						-- was delayed, resume and restore variables
						if n_feedback_var = idle then
							n_feedback_var := back;
							neuron_counter := 0;
						-- is last neuron in layer?
						elsif ((layer_counter = totalLayers-1) and (neuron_counter = outputWidth)) or (neuron_counter = maxWidth) then
						--elsif neuron_counter = maxWidth then
							neuron_counter := 0;
							
							n_feedback_var := idle; -- one cycle delay
						
							layer_counter := layer_counter - 1;
							if layer_counter = 0 then
								layer_counter := 0;
								mode <= delay;
								n_feedback_var := idle;
								--counter := 0;
							end if;
						end if;
					-- apparently not used ??
					--when 3 => -- input layer low then high
					--	n_feedback_var := forward;
					--	mode <= feedforward; -- back to feedforward
	--					data_rdy <= '0';
					when doneQuery | doneLearn => -- wait for next input
						n_feedback_var := idle;
						mode <= idle;
						data_rdy <= '1';
					when delay => -- input layer high 
						n_feedback_var := idle;
						
						mode <= doneLearn;
					when intermediate => -- intermediate
						n_feedback_var := back;
						layer_counter := totalLayers-1; 
						mode <= feedback;
						neuron_counter := 0; -- neuron_counter + 1;
					when waiting => -- wait until calculate goes low
						if calculate = '1' then
							mode <= waiting;
						elsif calculate = '0' then
							mode <= feedforward;
						end if;
					when others =>
				end case;
				
				if (n_feedback_var = back or n_feedback_var = forward) then
					current_layer <= to_unsigned(layer_counter, current_layer'length);
					current_neuron <= to_unsigned(neuron_counter, current_neuron'length);
				else
					current_layer <= (others => 'U');
					current_neuron <= (others => 'U');
				end if;
					
				--else
				--	counter := 0;
				--	n_feedback_var <= 'Z';
				--end if;
				-- n_feedback_bus <= (others => 'Z');
				-- n_feedback_bus(layer_counter) <= n_feedback_var;
				if n_feedback_var = forward then
					n_feedback <= 	1;
				elsif n_feedback_var = back then
					n_feedback <= 	0;
				else
					n_feedback <= 	2;
				end if; -- n_feedback <= n_feedback_var;
			end if;
		end if;
	end process;
	
	
	
	-- data_rdy <= '1' when mode = 4 else '0';
    --mode_out <= to_unsigned(mode, mode_out'length); -- std_logic_vector(to_unsigned(mode, mode_out'length));
    mode_out <= mode;
    
end Behavioral;

