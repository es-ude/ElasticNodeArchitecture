----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:20:16 07/27/2015 
-- Design Name: 
-- Module Name:    Network - Behavioral 
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

--library ieee_proposed;
--use ieee_proposed.fixed_float_types.all;
--use ieee_proposed.fixed_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Network is
	port (
			clk				: 	in std_logic;
			reset				:	 in std_logic;
			
			learn				:	in std_logic;
			data_rdy			:	out std_logic := '0';
        	calculate      :   in std_logic;
            
			connections_in	:	in fixed_point_vector;
			connections_out	:	out fixed_point_vector;

			--errors_in		:	in fixed_point_vector;
			wanted			:	in fixed_point_vector;
         mode_out       :  out uint8_t
		);
end Network;

architecture Behavioral of Network is
--	component InputLayer is
--	port (
--			clk				:	in std_logic;
--
--			n_feedback		:	in std_logic;
--
--			connections_in	:	in uintw_t;
--			connections_out	:	out fixed_point_vector;
--
--			errors_in		:	in fixed_point_vector;
--			errors_out		:	out fixed_point_vector
--		);
--	end component;

	
	component HiddenLayers is
	port (
			clk					:	in std_logic;
			reset					: 	in std_logic;

			n_feedback			:	in std_logic;
			current_layer		: 	in uint8_t;
			current_neuron		:	in uint8_t;
			
			dist_mode			:	in uint8_t;

			connections_in		:	in fixed_point_vector;
			connections_out	:	out fixed_point_vector;

			wanted				:	in fixed_point_vector
			-- errors_out		:	out fixed_point_vector
		);
	end component;

--	component OutputLayer is
--	port (
--			clk				:	in std_logic;
--
--			n_feedback		:	in std_logic;
--
--			connections_in	:	in fixed_point_vector;
--			connections_out	:	out fixed_point_vector;
--
--			errors_in		:	in fixed_point_vector;
--			errors_out		:	out fixed_point_vector
--		);
--	end component;


	component Diff is
		port 
		(
			current		:	in fixed_point_vector;
			wanted		:	in fixed_point_vector;
			difference 	:	out fixed_point_vector
		);
	end component;

	component Distributor is
	port
	(
		clk				:	in std_logic;
		reset				: in std_logic;
		learn				:	in std_logic;
      	calculate    	:   in std_logic;
		n_feedback_bus	:	out std_logic_vector(l downto 0) := (others => 'Z'); -- l layers + summation (at l)
		
				
		n_feedback		: 	out std_logic;
		current_layer	:	out uint8_t;
		current_neuron	:	out uint8_t;
				
	  data_rdy        :   out std_logic;
	  mode_out        :   out uint8_t
	);
	end component;
	
	component Logic_FixedPoint is
		Port (
			fixed_point		:	out fixed_point_vector;
			std_logic_vec	: 	in uintw_t;
			clk				:	in std_logic
		);
	end component;

--	signal conn_matrix 		: fixed_point_array;
--	signal err_matrix 		: fixed_point_array;
	signal hidden_connections_out : fixed_point_vector;
	signal err_out 			: fixed_point_vector;
	signal data_rdy_s			: std_logic := '0';
	signal mode_out_signal	: uint8_t;
	
	-- signal wanted_fp	: fixed_point_vector;
	--signal conn_in_real	: fixed_point_vector;
	--signal conn_out_real: fixed_point_vector;

	--signal learn		: std_logic := '0';
	signal n_feedback_bus 	: std_logic_vector(l downto 0) := (others => 'Z');
	signal n_feedback		 	: std_logic;
	signal current_layer  	: uint8_t;
	signal current_neuron	: uint8_t;
	
begin
	data_rdy <= data_rdy_s;
	-- set output connections when changing to learning
	process (clk, mode_out_signal) is
	begin
		if rising_edge(clk) then
			-- if learn = '0' then
			if mode_out_signal = to_unsigned(4, mode_out_signal'length) then -- std_logic_vector(to_unsigned(4, mode_out_signal'length)) then
				connections_out <= hidden_connections_out;
			end if;
		end if;
--		elsif falling_edge(n_feedback) then
--			connections_out <= hidden_connections_out;
--		end if;
	end process;
	--process (conn_matrix(l-1))
	--begin
	--	for i in 0 to w-1 loop
	--		if conn_matrix(l-1)(i)) > 0.5 then
	--			connections_out(i) <= '1'; 
	--		else
	--			connections_out(i) <= '0';
	--		end if;
	--	end loop;
	--end process;

--    -- disable distributor entirely when enable low so processing stops
--    process(connections_in, clk, enable)
--    begin
--        if enable = '0' then
--             -- keep disabling distr when enable is low
--            distr_enable <= '0';
--        else
--            -- async distr_enable, reenable on next clock and restart distributor
--            if rising_edge(clk) then
--                if distr_enable = '0' then
--                    distr_enable <= '1';
--                end if;
--            elsif falling_edge(clk) then
--            else -- must be connections_in changed
--                distr_enable <= '0';
--            end if;
--        end if;
--    end process;
	--process (connections_in)
	--begin
	--	for i in 0 to w-1 loop
	--		if connections_in(i) = '1' then
	--			conn_in_real(i) <= real_to_fixed_point(1.0);
	--		else
	--			conn_in_real(i) <= real_to_fixed_point(0.0);
	--		end if;
	--	end loop;
	--end process;

	--process(wanted)
	--begin
	--	for i in 0 to w-1 loop
	--		if wanted(i) = '1' then
	--			wanted_real(i) <= real_to_fixed_point(1.0); 
	--		else
	--			wanted_real(i) <= real_to_fixed_point(0.0);
	--		end if;
	--	end loop;
	--end process;

	--	gen_layers:
--	for i in 1 to l-2 generate layer_x : Layer port map -- l-2 hidden layers
--		(
--			clk => clk,
--			n_feedback => n_feedback_bus(i),
--			connections_in => conn_matrix(i-1),
--			connections_out => conn_matrix(i),
--			errors_in => err_matrix(i),
--			errors_out => err_matrix(i-1)
--		);
--	end generate;


	-- input_layer : InputLayer port map (clk, n_feedback_bus(0), connections_in, conn_matrix(0), err_matrix(0), err_out);
	hidden_layers: HiddenLayers port map (clk, reset, n_feedback, current_layer, current_neuron, mode_out_signal, connections_in, hidden_connections_out, wanted); --  err_matrix(l-1), err_out);
	-- output_layer : OutputLayer port map (clk, n_feedback_bus(l-1), conn_matrix(l-2), conn_matrix(l-1), err_matrix(l-1), err_matrix(l-2));

	-- lfp: Logic_FixedPoint port map (wanted_fp, wanted, clk);
	
--	process (wanted, conn_matrix(l-1)) 
--	begin
--		err_matrix(l-1) <= wanted - conn_matrix(l-1);
--	end process;
	--diff_unit: Diff port map 
	--(
	--	current => conn_matrix(l-1), wanted => wanted_real, difference => err_matrix(l-1)
	--);

	distr: Distributor port map
	(
		clk, reset, learn, calculate, n_feedback_bus, n_feedback, current_layer, current_neuron, data_rdy_s, mode_out_signal
	);
	mode_out <= mode_out_signal;

--	process (clk, learn)
--	variable clk_count : natural range 0 to (l * 2 + 1) := 0;
--	begin
--		if rising_edge(clk) then
--            -- data ready after one clock cycle per layer
--			if learn = '1' then
--				clk_count := clk_count + 1;
--				if clk_count = l + 2 then
--					data_rdy_s <= '1';
--				elsif clk_count = l * 2 + 4 then
--					data_rdy_s <= '0';
--					clk_count := 0;
--				else 
--					data_rdy_s <= '0';
--				end if;
--			else
--				clk_count := clk_count + 1;
--				if clk_count = l + 2 then
--					data_rdy_s <= '1';
--				--elsif clk_count = l * 2 + 1 then
--				--	data_rdy_s <= '0';
--					clk_count := 0;
--				else 
--					data_rdy_s <= '0';
--				end if;
--			end if;
--		end if;
--	end process;

end Behavioral;

