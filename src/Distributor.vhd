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

		data_rdy       :  out std_logic;
		mode_out       :  out std_logic_vector(2 downto 0)
	);
end Distributor;

architecture Behavioral of Distributor is

signal mode : integer range 0 to 6 := 0; -- 0 idle 1 feedforward 2 feedback 3 feedback->feedforward
begin
	process (reset, clk, calculate, learn)
	variable n_feedback_var : std_logic := 'Z';
	variable counter : integer range 0 to l := 0;
	begin
	    -- keep distributor 
		if reset = '1' then
			counter := 0;
			n_feedback_var := 'Z'; -- init feed forward
			mode <= 0;
			n_feedback_bus <= (others => 'Z');
			data_rdy <= '0';
		-- set up before the clock cycle for hidden layers to sample current_layer
		elsif falling_edge(clk) then 
			--if learn = '1' then 
				-- start learning
				
				
					case mode is 
						when 0 => -- init
							counter := 0;
							n_feedback_var := 'Z';
							
							-- stay in idle until told to calculate
							if calculate = '1' then 
								mode <= 1;
								n_feedback_var := '1';
								data_rdy <= '0';
							end if;
		--					data_rdy <= '0';
						when 1 => -- feedforward
							counter := counter + 1;
							if counter = l-1 then -- through all layers
								-- avoid extra cycle on l=1
								-- if counter > l-1 then counter := l-1; end if;
								
								if learn = '1' then
									-- if counter = l * 10 then -- through all layers
									-- n_feedback_var := '1';
									-- counter := counter + 1; -- will be reduced again before active
									mode <= 6;
								else
									-- if not learning, just return to first layer for feed forward
									-- if counter = l * 10 + 1 then -- through all layers
									n_feedback_var := 'Z';
									mode <= 4;
									--                            n_feedback_var := '0';
									--                            mode <= 2;
									--counter := 0;
									--data_rdy <= '1';
								end if;
							-- counter := l;
							end if;
						when 2 => -- feedback
							counter := counter - 1;
							if counter = 0 then
								mode <= 5;
								n_feedback_var := '0';
								--counter := 0;
							end if;
		--					data_rdy <= '0';
						when 3 => -- input layer low then high
							n_feedback_var := '1';
							mode <= 1; -- back to feedforward
		--					data_rdy <= '0';
						when 4 => -- wait for next input
								  n_feedback_var := 'Z';
								  mode <= 0;
		                    data_rdy <= '1';
		
							
						when 5 => -- input layer high 
								  n_feedback_var := 'Z';
								  mode <= 4;
						when 6 => -- output layer low
							n_feedback_var := '0';
							mode <= 2;
						when others =>
					end case;
					
					if (n_feedback_var = '0' or n_feedback_var = '1') then
						current_layer <= to_unsigned(counter, current_layer'length);
					else
						current_layer <= (others => 'U');
					end if;
				
			--else
			--	counter := 0;
			--	n_feedback_var <= 'Z';
			--end if;
			n_feedback_bus <= (others => 'Z');
			n_feedback_bus(counter) <= n_feedback_var;
			n_feedback <= n_feedback_var;
		end if;
	end process;
	
	-- data_rdy <= '1' when mode = 4 else '0';
    mode_out <= std_logic_vector(to_unsigned(mode, mode_out'length));
    
end Behavioral;

