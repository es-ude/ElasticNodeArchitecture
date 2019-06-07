library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library neuralnetwork;
use neuralnetwork.Common.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

--library ieee_proposed;
--use ieee_proposed.fixed_float_types.all;

entity SimulateNeuron is
end entity;


architecture sim of SimulateNeuron is

  constant period: time := 10  ns;

  signal clk: std_logic := '0';
  signal rst: std_logic := '0';

  component Neuron
    port (
      clk           : in std_logic;
      reset         : in std_logic;

      n_feedback        : in integer range 0 to 2;

      current_layer     : in uint8_t;
      current_neuron      :   in uint8_t;
      --index         : in integer range 0 to maxWidth-1;

      input_connections     :   in fixed_point_vector;
      input_error       : in fixed_point;

      output_connection   : out fixed_point := zero;
      output_previous     : in fixed_point;
      output_errors     :   out fixed_point_vector := (others => zero);

      weights_in        :   in fixed_point_vector;
      weights_out       :   out fixed_point_vector := (others => factor_2);

      bias_in         :   in fixed_point;
      bias_out        :   out fixed_point

      );
  end component;

  --Define your external connections here
  signal i_conn     : fixed_point_vector := (others => real_to_fixed_point(0.0));
  signal o_conn,o_prev     : fixed_point;
  signal o_errors   : fixed_point_vector;
  signal i_error   : fixed_point;
  signal n_feedback : integer;
  signal i_weights  : fixed_point_vector;
  
  signal busy 		  : boolean := true;
  signal bias_in    : fixed_point;

  signal current_layer, current_neuron : uint8_t;
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

  -- Reset
  process
  begin
    --wait for 5 ns;
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait;
  end process;



  uut: Neuron port map(
      clk => clk,
      reset => rst,
      n_feedback => n_feedback,
      current_layer => current_layer,
      current_neuron => current_neuron,
      input_connections => i_conn,
      input_error => i_error,
      output_connection => o_conn,
      output_previous => o_prev,
      output_errors => o_errors,
  		weights_in => i_weights,
  		weights_out => open,
      bias_in => bias_in,
      bias_out => open
    );

  process
  begin
    
    wait until rst='1';
    wait until rst='0';

    current_neuron <= (others => '0');
    current_layer <= (others => '0');
    bias_in <= zero;  
    
    o_prev <= zero; 
    i_error <= real_to_fixed_point(1.0);
    i_conn(0) <= real_to_fixed_point(0.0);
    i_conn(1) <= real_to_fixed_point(1.0);
    n_feedback <= 1;
    i_weights <= (others => real_to_fixed_point(0.5));
    --i_weights(1) <= real_to_fixed_point(0.5);
    --i_weights(2) <= real_to_fixed_point(0.5);
	
    wait until rising_edge(clk);
    wait for period/2;
    n_feedback <= 0;
    assert (o_errors(0) = 1.0);
    assert (o_conn = 0.0);
    wait until rising_edge(clk);
    wait for period/2;
    n_feedback <= 2;
    
	 busy <= false;
    report "Finished" severity warning;
  end process;


end sim;
