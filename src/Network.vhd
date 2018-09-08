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
			clk					: 	in std_logic;
			reset				:	in std_logic;
			
			learn				:	in std_logic;
			data_rdy			:	out std_logic := '0';
			busy				:  	out std_logic;
        	calculate      		:   in std_logic;
            
			connections_in		:	in uintw_t;
			connections_out		:	out uintw_t := (others => '0');

			--errors_in			:	in fixed_point_vector;
			wanted				:	in uintw_t;

			weights_wr_en 		:	in std_logic;
			weights 			:	inout weights_vector;

         	debug		      	:  	out uint8_t
		);
end Network;

architecture Behavioral of Network is

	component FixedPoint_Logic is
		Port (
			fixed_point		:	in fixed_point_vector;
			std_logic_vec	: 	out uintw_t;
			clk				:	in std_logic
		);
	end component;

	component Logic_FixedPoint is
		Port (
			fixed_point		:	out fixed_point_vector;
			std_logic_vec	: 	in uintw_t;
			clk				:	in std_logic
		);
	end component;

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
		reset			: 	in std_logic;
		learn			:	in std_logic;
		calculate    	:   in std_logic;
		n_feedback_bus	:	out std_logic_vector(totalLayers downto 0) := (others => 'Z'); -- l layers + summation (at l)


		n_feedback		: 	out integer range 0 to 2;
		current_layer	:	out uint8_t;
		current_neuron	:	out uint8_t;

		data_rdy        :   out std_logic;
		mode_out        :   out distributor_mode
	);
	end component;
	
	--component Logic_FixedPoint is
	--	Port (
	--		fixed_point		:	out fixed_point_vector;
	--		std_logic_vec	: 	in uintw_t;
	--		clk				:	in std_logic
	--	);
	--end component;

--	signal conn_matrix 		: fixed_point_array;
--	signal err_matrix 		: fixed_point_array;
	signal hidden_connections_out_fp : fixed_point_vector;
	--signal connections_out_fp : fixed_point_vector;
	signal err_out 					: fixed_point_vector;
	signal data_rdy_s				: std_logic := '0';
	signal mode_out_signal			: distributor_mode;
	signal mode_out_signal_delay	: distributor_mode;
	
	-- signal wanted_fp	: fixed_point_vector;
	--signal conn_in_real	: fixed_point_vector;
	--signal conn_out_real: fixed_point_vector;

	--signal learn		: std_logic := '0';
	signal n_feedback_bus 	: std_logic_vector(totalLayers downto 0) := (others => 'Z');
	signal n_feedback		 	: integer range 0 to 2;
	signal n_feedback_buffered : integer range 0 to 2;
	signal current_layer  	: uint8_t;
	signal current_neuron	: uint8_t;
	
	
	signal connections_in_fp   : fixed_point_vector := (others => real_to_fixed_point(0.0));
	signal wanted_fp           : fixed_point_vector := (others => real_to_fixed_point(0.0));
	signal connections_out_fp  : fixed_point_vector;

	signal error_out : fixed_point;
	signal error_out_abs : fixed_point;

begin
	data_rdy <= data_rdy_s;

	-- delay mode for fetching output connections on falling edge
	process (reset, clk, mode_out_signal) is
	begin
		if reset = '1' then 
			mode_out_signal_delay <= idle;
		elsif rising_edge(clk) then
			mode_out_signal_delay <= mode_out_signal;
		end if;
	end process;

	-- set output connections when changing to learning
	process (reset, clk, mode_out_signal) is
	begin
		if reset = '1' then
			connections_out_fp <= (others => zero);
		elsif falling_edge(clk) then
			-- if learn = '0' then
			if mode_out_signal_delay = doneQuery or mode_out_signal_delay = intermediate then -- std_logic_vector(to_unsigned(4, mode_out_signal'length)) then
				connections_out_fp <= hidden_connections_out_fp;
				-- used to see when model is trained
				error_out <= wanted_fp(0) - hidden_connections_out_fp(0);
				error_out_abs <= abs(wanted_fp(0) - hidden_connections_out_fp(0));
			else
				connections_out_fp <= connections_out_fp;
			end if;
		end if;

	end process;
	
	-- connections_out <= connections_out_fp;

	busy <= '0' when mode_out_signal = idle else '1';


	
hidden_layers: entity work.HiddenLayers(Behavioral) port map 
	(
		clk => clk, 
		reset => reset, 
		n_feedback => n_feedback, 
		current_layer => current_layer, 
		current_neuron => current_neuron, 
		dist_mode => mode_out_signal, 
		connections_in => connections_in_fp, 
		connections_out => hidden_connections_out_fp,
		wanted => wanted_fp, 
		weights_wr_en => weights_wr_en, 
		weights => weights
	);


	distr: Distributor port map
	(
		clk, reset, learn, calculate, n_feedback_bus, n_feedback, current_layer, current_neuron, data_rdy_s, mode_out_signal
	);

	fpl: FixedPoint_Logic port map
	(
	    connections_out_fp, connections_out, clk
	);

	lfp: Logic_FixedPoint port map
	(
	    connections_in_fp, connections_in, clk
	);

	lfpw: Logic_FixedPoint port map
	(
	    wanted_fp, wanted, clk
	);

--	buff: BUFG port map
--	(
--		O=>n_feedback_buffered, I=>n_feedback
--	);
	debug(2 downto 0) <= to_unsigned(distributor_mode'POS(mode_out_signal), 3);
	debug(3) <= '1' when n_feedback = 1 else '0';
	debug(7 downto 4) <= current_layer(3 downto 0);

end Behavioral;

