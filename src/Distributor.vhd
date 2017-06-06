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
		reset				 :	 in std_logic;

		learn			:	in std_logic;
      --   enable          :   in std_logic; -- async reset
		calculate 			: in std_logic;
		n_feedback_bus	:	out std_logic_vector(l downto 0) := (others => 'Z'); -- l layers + summation (at l)
		data_rdy        :   out std_logic;
		mode_out        :   out std_logic_vector(2 downto 0)
	);
end Distributor;

architecture Behavioral of Distributor is

signal mode : integer range 0 to 5 := 0; -- 0 idle 1 feedforward 2 feedback 3 feedback->feedforward
begin
	process (reset, clk, calculate, learn)
	variable n_feedback : std_logic := 'Z';
	variable counter : integer range 0 to l + 1 := 0;
	begin
	    -- keep distributor 
		if reset = '1' then
			counter := 0;
			n_feedback := 'Z'; -- init feed forward
			mode <= 0;
			n_feedback_bus <= (others => 'Z');
			data_rdy <= '0';
		elsif rising_edge(clk) then
			--if learn = '1' then 
				-- start learning
				
				
					case mode is 
						when 0 => -- init
							counter := 0;
							n_feedback := 'Z';
							
							-- stay in idle until told to calculate
							if calculate = '1' then 
								mode <= 1;
								n_feedback := '1';
								data_rdy <= '0';
							end if;
		--					data_rdy <= '0';
						when 1 => -- feedforward
							counter := counter + 1;
							if counter = l then -- through all layers
								if learn = '1' then
									-- if counter = l * 10 then -- through all layers
									n_feedback := '0';
									mode <= 2;
								else
									-- if not learning, just return to first layer for feed forward
									-- if counter = l * 10 + 1 then -- through all layers
									n_feedback := 'Z';
									mode <= 4;
									--                            n_feedback := '0';
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
								n_feedback := '0';
								--counter := 0;
							end if;
		--					data_rdy <= '0';
						when 3 => -- input layer low then high
							n_feedback := '1';
							mode <= 1; -- back to feedforward
		--					data_rdy <= '0';
						when 4 => -- wait for next input
								  n_feedback := 'Z';
								  mode <= 0;
		                    data_rdy <= '1';
		
							
						when 5 => -- input layer high 
								  n_feedback := 'Z';
								  mode <= 4;
						when others =>
					end case;
				
			--else
			--	counter := 0;
			--	n_feedback <= 'Z';
			--end if;
			n_feedback_bus <= (others => 'Z');
			n_feedback_bus(counter) <= n_feedback;
		end if;
	end process;
	
	-- data_rdy <= '1' when mode = 4 else '0';
    mode_out <= std_logic_vector(to_unsigned(mode, mode_out'length));
    
end Behavioral;

