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
		reset				: 	in std_logic;
		learn				:	in std_logic;
		calculate      :  in std_logic;
		n_feedback_bus	:	out std_logic_vector(l downto 0) := (others => 'Z'); -- l layers + summation (at l)
		
		n_feedback		: 	out std_logic;
		current_layer	:	out uint8_t;
		current_neuron	:	out uint8_t;

		data_rdy       :  out std_logic;
		mode_out       :  out uint8_t
	);
end Distributor;

architecture Behavioral of Distributor is
	signal mode : integer range 0 to 7 := 0; -- 0 idle 1 feedforward 2 feedback 3 feedback->feedforward
begin
	process (reset, clk, calculate, learn)
	type FeedbackType is (forward, back, idle);
	variable n_feedback_var : FeedbackType := idle;
	variable layer_counter : integer range -1 to l := 0;
	variable neuron_counter : integer range 0 to w := 0;
	begin
	    -- keep distributor 
		if reset = '1' then
			layer_counter := 0;
			neuron_counter := 0;
			n_feedback_var := idle; -- init feed forward
			mode <= 0;
			n_feedback_bus <= (others => 'Z');
			data_rdy <= '0';
		-- set up before the clock cycle for hidden layers to sample current_layer
		elsif falling_edge(clk) then 
			--if learn = '1' then 
				-- start learning
					case mode is 
						when 0 => -- init
							layer_counter := 0;
							neuron_counter := 0;
							n_feedback_var := idle;
							
							-- stay in idle until told to calculate
							if calculate = '1' then 
								mode <= 7;
								n_feedback_var := forward;
								data_rdy <= '0';
							end if;
		--					data_rdy <= '0';
						when 1 => -- feedforward
							neuron_counter := neuron_counter + 1;
							if n_feedback_var = idle then -- start again
								
								n_feedback_var := forward; -- reassert feedback after delay
								neuron_counter := 0;
							elsif neuron_counter = w then
								neuron_counter := 0;
								n_feedback_var := idle; -- one cycle delay
								
								-- move on to next layer
								layer_counter := layer_counter + 1;
								if layer_counter = l then -- through all layers
									-- return to last layer for feedback
									-- layer_counter := l-1; 
									
									if learn = '1' then
										-- if counter = l * 10 then -- through all layers
										n_feedback_var := idle;
										-- counter := counter + 1; -- will be reduced again before active
										mode <= 6;
									else
										-- if not learning, just return to first layer for feed forward
										-- if counter = l * 10 + 1 then -- through all layers
										n_feedback_var := idle;
										mode <= 4;
										--                            n_feedback_var := '0';
										--                            mode <= 2;
										--counter := 0;
										--data_rdy <= '1';
									end if;
								end if;
									
--							else 
--								-- first wait
--								n_feedback_var := 'Z';
							end if;
								
								
								
							-- counter := l;
							-- end if;
						when 2 => -- feedback
							neuron_counter := neuron_counter + 1;
							-- was delayed, resume and restore variables
							if n_feedback_var = idle then
								n_feedback_var := back;
							elsif neuron_counter = w then
								neuron_counter := 0;
								
								n_feedback_var := idle; -- one cycle delay
							
								layer_counter := layer_counter - 1;
								if layer_counter = -1 then
									layer_counter := 0;
									mode <= 5;
									n_feedback_var := idle;
									--counter := 0;
								end if;
							end if;
		--					data_rdy <= '0';
						when 3 => -- input layer low then high
							n_feedback_var := forward;
							mode <= 1; -- back to feedforward
		--					data_rdy <= '0';
						when 4 => -- wait for next input
							n_feedback_var := idle;
							mode <= 0;
							data_rdy <= '1';
						when 5 => -- input layer high 
							n_feedback_var := idle;
							
							mode <= 4;
						when 6 => -- intermediate
							n_feedback_var := back;
							layer_counter := l-1; 
							mode <= 2;
							neuron_counter := 0; -- neuron_counter + 1;
						when 7 => -- wait until calculate goes low
							if calculate = '1' then
								mode <= 7;
							elsif calculate = '0' then
								mode <= 1;
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
				n_feedback <= 	'1';
			elsif n_feedback_var = back then
				n_feedback <= 	'0';
			else
				n_feedback <= 	'Z';
			end if; -- n_feedback <= n_feedback_var;
		end if;
	end process;
	
	
	
	-- data_rdy <= '1' when mode = 4 else '0';
    mode_out <= to_unsigned(mode, mode_out'length); -- std_logic_vector(to_unsigned(mode, mode_out'length));
    
end Behavioral;

