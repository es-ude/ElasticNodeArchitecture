----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:18:31 07/08/2015 
-- Design Name: 
-- Module Name:    SimulateLayer - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

library neuralnetwork;
use neuralnetwork.Common.all;

entity TestHiddenLayers is
end TestHiddenLayers;

architecture Behavioral of TestHiddenLayers is	
	component HiddenLayers
	port (
		clk				:	in std_logic;
		reset 		    : 	in std_logic; -- reset all variables and memory 

		n_feedback		:	in integer range 0 to 2;    -- 0:backward, 1:feedforward, 2:between
		current_layer	: 	in uint8_t;
		current_neuron  :   in uint8_t;
		
		dist_mode       :   in distributor_mode;

		connections_in	:	in fixed_point_vector;
		connections_out	:	out fixed_point_vector;

		wanted 			: 	in fixed_point_vector;

		weights_wr_en	: 	in std_logic;
		weights 		: 	inout weights_vector
	);
	end component;
	
	-- tested by TestDistributor.vhd
	component Distributor is
	port
	(
		clk				:	in std_logic;
		reset			: 	in std_logic;
		learn			:	in std_logic;
		calculate       :   in std_logic;
		n_feedback_bus	:	out std_logic_vector(l downto 0) := (others => 'Z'); -- l layers + summation (at l)
		
		n_feedback		: 	out integer range 0 to 2;
		current_layer	:	out uint8_t;
		current_neuron	:	out uint8_t;

		data_rdy       :  out std_logic;
		mode_out       :  out distributor_mode
	);
	end component;

    -- Clock and reset signal
    constant period : time := 100 ns;
    signal clk : std_logic := '0';
    signal reset : std_logic:='1';
    signal busy 	: boolean := true;
    
    -- Common signals
    
    -- Signals for Layer module
	signal conn_in, conn_out : fixed_point_vector := (others => (others => '0'));
	signal err_in, err_out : fixed_point_vector := (others => (others => '0'));
	
	signal n_feedback : integer range 0 to 2;

	signal current_layer_dist, current_layer, current_layer_manual : uint8_t := (others => '0');
	signal current_neuron : uint8_t := (others => '0');
	signal dist_mode : distributor_mode;

	signal weights_wr_en : std_logic;
	signal weights : weights_vector := (others => 'Z');
	signal wanted : fixed_point_vector := (others => (others => '0'));

	
	-- Signals for Distribute module
	signal learn, calculate, data_rdy : std_logic := '0';
	signal n_feedback_bus : std_logic_vector(l downto 0);

    --signal err_in, err_out : fixed_point_vector := (others => (others => '0'));
    --signal errors_in		:	fixed_point_vector;
    --signal connections_out    :     fixed_point_vector;

	
begin
	
	process
	begin
		if busy then
			wait for period/2;
			clk <= not clk;
		else 
			wait;
		end if;
	end process;

    -- need to be corrected
	distr: Distributor port map
	(
		clk, reset, learn, calculate, n_feedback_bus, n_feedback, current_layer_dist, current_neuron, data_rdy, dist_mode
	);
	
	uut : HiddenLayers port map 
		(
			clk, reset, n_feedback, current_layer, current_neuron, dist_mode, conn_in, conn_out, wanted, weights_wr_en, weights
		);
	current_layer <= current_layer_manual when dist_mode = idle else current_layer_dist;

	process begin
		reset <= '1';
		weights <= (others => 'Z');
		wait for period *(l+2);
		reset <= '0';
		
		for i in 0 to 10 loop
			-- initial test
			learn <= '1';
			calculate <= '1';
			weights_wr_en <= '0';
			conn_in <= (others => zero);
			conn_in(1) <= factor;
			wanted <= (others => zero);
			wanted(0) <= factor;
			wait for period*4;
			calculate <= '0';

			wait until dist_mode = idle;
		end loop;



		-- read weights
		for i in 0 to l loop
			--weights <= (others => '0');
			current_layer_manual <= to_unsigned(i, current_layer_manual'length);
			wait for period * 3;
		end loop;

		-- change weights
		for i in 0 to l loop
			weights <= (others => '0');
			weights_wr_en <= '1';
			current_layer_manual <= to_unsigned(i, current_layer_manual'length);
			wait for period;
			weights_wr_en <= '0';
			weights <= (others => 'Z');
			wait for period * 2;
		end loop;
		weights <= (others => 'Z');

		-- secodn test
		learn <= '0';
		calculate <= '1';
		weights_wr_en <= '0';
		conn_in <= (others => zero);
		conn_in(1) <= factor;
		wanted <= (others => zero);
		wanted(0) <= factor;

		wait for period*4;
		calculate <= '0';

		wait until dist_mode = idle;

		busy <= false;
		report "Finished" severity warning;
		wait;
	end process;
end Behavioral;