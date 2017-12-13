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
library UNISIM;
use UNISIM.VComponents.all;

entity Network is
	port (
			clk				: 	in std_logic;
			reset				:	 in std_logic;
			
			learn				:	in std_logic;
			data_rdy			:	out std_logic := '0';
			busy				:  out std_logic;
        	calculate      :   in std_logic;
            
			connections_in	:	in fixed_point_vector;
			connections_out	:	out fixed_point_vector := (others => zero);

			--errors_in		:	in fixed_point_vector;
			wanted			:	in fixed_point_vector;
         debug		      :  out uint8_t
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

			n_feedback			:	in integer range 0 to 2;
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
		
				
		n_feedback		: 	out integer range 0 to 2;
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
	signal connections_out_signal : fixed_point_vector;
	signal err_out 			: fixed_point_vector;
	signal data_rdy_s			: std_logic := '0';
	signal mode_out_signal	: uint8_t;
	
	-- signal wanted_fp	: fixed_point_vector;
	--signal conn_in_real	: fixed_point_vector;
	--signal conn_out_real: fixed_point_vector;

	--signal learn		: std_logic := '0';
	signal n_feedback_bus 	: std_logic_vector(l downto 0) := (others => 'Z');
	signal n_feedback		 	: integer range 0 to 2;
	signal n_feedback_buffered : integer range 0 to 2;
	signal current_layer  	: uint8_t;
	signal current_neuron	: uint8_t;
	
	
begin
	data_rdy <= data_rdy_s;
	-- set output connections when changing to learning
	process (reset, clk, mode_out_signal) is
	begin
		if reset = '1' then
			connections_out_signal <= (others => zero);
		elsif rising_edge(clk) then
			-- if learn = '0' then
			if mode_out_signal = to_unsigned(4, mode_out_signal'length) then -- std_logic_vector(to_unsigned(4, mode_out_signal'length)) then
				connections_out_signal <= hidden_connections_out;
			else
				connections_out_signal <= connections_out_signal;
			end if;
		end if;

	end process;
	
	connections_out <= connections_out_signal;

	busy <= '0' when mode_out_signal = to_unsigned(0, mode_out_signal'length) else '1';

	hidden_layers: HiddenLayers port map (clk, reset, n_feedback, current_layer, current_neuron, mode_out_signal, connections_in, hidden_connections_out, wanted); --  err_matrix(l-1), err_out);

	distr: Distributor port map
	(
		clk, reset, learn, calculate, n_feedback_bus, n_feedback, current_layer, current_neuron, data_rdy_s, mode_out_signal
	);
--	buff: BUFG port map
--	(
--		O=>n_feedback_buffered, I=>n_feedback
--	);
	debug(2 downto 0) <= mode_out_signal(2 downto 0);
	debug(3) <= '1' when n_feedback = 1 else '0';
	debug(7 downto 4) <= current_layer(3 downto 0);

end Behavioral;

