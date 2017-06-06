library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library neuralnetwork;
use neuralnetwork.Common.all;

library ieee_proposed;
use ieee_proposed.fixed_float_types.all;

entity SimulateNeuron is
end entity;


architecture sim of SimulateNeuron is

  constant period: time := 100 ns;

  signal clk: std_logic := '0';
  signal rst: std_logic := '0';

  component Neuron
    port (
      clk               : in std_logic;

      n_feedback        : in std_logic;
      input_connections :   in fixed_point_vector;
      input_errors      : in fixed_point_vector;

      output_connection : out fixed_point;
      output_errors     :   out fixed_point_vector
      );
  end component;

  --Define your external connections here
  signal i_conn     : fixed_point_vector := (others => real_to_fixed_point(0.0));
  signal o_conn     : fixed_point;
  signal o_errors   : fixed_point_vector;
  signal i_errors   : fixed_point_vector := (others => real_to_fixed_point(0.0));
  signal n_feedback : std_logic := 'Z';
  
  signal busy 			: boolean := true;
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
    wait for 5 ns;
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait;
  end process;

  uut: Neuron port map(
      clk => clk,
      n_feedback => n_feedback,
      input_connections => i_conn,
      input_errors => i_errors,
      output_connection => o_conn,
      output_errors => o_errors
    );

  process
  begin
    
    wait until rst='1';
    wait until rst='0';
    
    i_errors(0) <= real_to_fixed_point(1.0);
    i_conn(0) <= real_to_fixed_point(0.0);
    i_conn(1) <= real_to_fixed_point(1.0);
    n_feedback <= '1';

    wait until rising_edge(clk);
    wait for period/2;
    n_feedback <= '0';
    assert (o_errors(0) = 1.0);
    assert (o_conn = 0.0);
    wait until rising_edge(clk);
    wait for period/2;
    n_feedback <= 'Z';
    
	 busy <= false;
    report "Finished" severity warning;
  end process;


end sim;
