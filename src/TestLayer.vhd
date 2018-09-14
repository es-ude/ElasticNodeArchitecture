----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/08/21 17:23:55
-- Design Name: 
-- Module Name: TestLayer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - Finished testing function and delete meanless lines
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library neuralnetwork;
use neuralnetwork.Common.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;


entity TestLayer is
end TestLayer;

architecture Behavioral of TestLayer is
    -- layer module defination
    component Layer 
        port (
            clk						:	 in std_logic;
            reset                   :    in std_logic;
            
            n_feedback              :    in integer range 0 to 2;
            dist_mode               :    in distributor_mode;
            output_layer            :    in std_logic; -- tell each to only consider own error
            current_neuron          :    in uint8_t;
            
            connections_in          :    in fixed_point_vector;
            connections_out         :    out fixed_point_vector;
            connections_out_prev    :    in fixed_point_vector;
            
            errors_in               :    in fixed_point_vector;
            errors_out              :    out fixed_point_vector;
            
            weights_in              :     in fixed_point_matrix; -- one fpv per neuron
            weights_out             :     out fixed_point_matrix;
            
            biases_in               :     in fixed_point_vector;
            biases_out              :     out fixed_point_vector
        );
    end component;
    
    -- Clock signal and reset signal    
    constant period : time := 100 ns;
    signal clock : std_logic := '0';
    signal  reset  : std_logic :='0';
    signal busy     : boolean := true;
    
    -- Neuron control signal
    signal feedback            : integer;
    signal dist_mode          : distributor_mode;
    signal output_layer      : std_logic := '0';
    signal current_neuron   : uint8_t;
    
    -- Data signal
    signal conn_in, conn_out, conn_out_prev : fixed_point_vector := (others => (others => '0'));
    signal errors_in,errors_out        :    fixed_point_vector;
    signal weights_in, weights_out : fixed_point_matrix := (others => (others => real_to_fixed_point(0.5)));
    signal bias_in, bias_out : fixed_point_vector:= (others => (others => '0'));
      
begin
-- Clock process
clock_signal : process
    begin
        if busy then
            wait for period/2;
            clock <= not clock;
        else
            wait;
        end if;    
end process clock_signal;

    -- Signal reset
reset_signal : process
    begin
        wait for 5 ns;
        reset <= '1';
        
        wait for 20 ns;
        reset <= '0';

        wait;
end process reset_signal;
    
utt: Layer port map(
            clk => clock,
            reset => reset,
            
            n_feedback => feedback,
            dist_mode=> dist_mode, 
            output_layer => output_layer,
            current_neuron  => current_neuron,
            
            connections_in  => conn_in,
            connections_out  => conn_out,
            connections_out_prev => conn_out_prev,
            
            errors_in => errors_in,
            errors_out  => errors_out,
            
            weights_in => weights_in,
            weights_out => weights_out,
            
            biases_in => bias_in,
            biases_out  => bias_out
    );
testing_process:process
     variable dist_mode_value : distributor_mode := idle;
     variable current_neuron_value : uint8_t :=TO_UNSIGNED(0, 8);
begin
    wait until reset='1';
    wait until reset='0';

    -- conn_out_prev init for test connections_out_prev signal 
    feedback <= 1;
    conn_out_prev(0) <= real_to_fixed_point(0.0);
    conn_out_prev(1) <= real_to_fixed_point(0.1);
    conn_out_prev(2) <= real_to_fixed_point(1.0);
    conn_out_prev(3) <= real_to_fixed_point(0.0);
    current_neuron_value :=  TO_UNSIGNED(0, 8);
    wait for period;
    dist_mode_value := idle;  
    
    for I in 0 to w-1 loop
            current_neuron <= current_neuron_value;
            dist_mode <= dist_mode_value;
            wait for period;
            current_neuron_value := current_neuron_value + 1;
    end loop;
    
    -- second times test
    current_neuron_value :=  TO_UNSIGNED(0, 8);
    dist_mode_value := idle;  
    wait for period;
    for I in 0 to w-1 loop
        current_neuron <= current_neuron_value;
        dist_mode <= dist_mode_value;
        wait for period;
        current_neuron_value := current_neuron_value + 1;
        --dist_mode_value := dist_mode_value + 1;  
    end loop;
    -- preloading of next neuron and connections_out_prev signal has been tested. (dist_mode also)
    
    -- Start of testing bias_in and bias_out logic
    feedback <= 0;  -- switch to backward function (must!)
    current_neuron <= TO_UNSIGNED(w-1, 8);
    dist_mode_value := idle;  
    wait for period;
    current_neuron_value :=  TO_UNSIGNED(0, 8);
    current_neuron <= current_neuron_value;
    wait for (w-1)*period;
    bias_in(0) <= real_to_fixed_point(0.0);
    bias_in(1) <= real_to_fixed_point(0.1);
    bias_in(2) <= real_to_fixed_point(0.0);
    bias_in(3) <= real_to_fixed_point(0.1);

    wait for period;
    for I in 0 to w-1 loop
        current_neuron <= current_neuron_value;
        wait for period;
        current_neuron_value := current_neuron_value + 1;
    end loop;
    -- End of testing bias_in and bias_out logic

    -- Start of testing weights_in and weights_out
    feedback <= 1;      -- switch to feedforward function (must!)
    bias_in <= (others => (others => '0'));
    conn_in(0) <= real_to_fixed_point(0.0);
    conn_in(1) <= real_to_fixed_point(0.0);
    conn_in(2) <= real_to_fixed_point(0.0);
    conn_in(3) <= real_to_fixed_point(0.0);
    
    weights_in(0)(0) <= real_to_fixed_point(0.1);
    weights_in(0)(1) <= real_to_fixed_point(0.0);
    weights_in(0)(2) <= real_to_fixed_point(0.1);
    weights_in(0)(3) <= real_to_fixed_point(0.0);

    current_neuron <= TO_UNSIGNED(w-1, 8); -- init state, otherwise a we will get fault result
    wait for period;
    current_neuron_value :=  TO_UNSIGNED(0, 8);
    for I in 0 to w-1 loop
        current_neuron <= current_neuron_value;
        wait for period;  
        current_neuron_value := current_neuron_value + 1;
    end loop;
    -- End of testing weights_in and weights_out

    -- Start of testing mux function
    feedback <= 0;
    current_neuron <= TO_UNSIGNED(w-1, 8); -- init state, otherwise a we will get fault result
    dist_mode <= idle;
    bias_in <= (others => (others => '0'));
    conn_out_prev(0) <= real_to_fixed_point(1.0);
    conn_out_prev(1) <= real_to_fixed_point(0.1);
    conn_out_prev(2) <= real_to_fixed_point(1.0);
    conn_out_prev(3) <= real_to_fixed_point(0.0);

    errors_in(0) <= real_to_fixed_point(0.1);
    errors_in(1) <= real_to_fixed_point(0.1);
    errors_in(2) <= real_to_fixed_point(0.1);
    errors_in(3) <= real_to_fixed_point(0.1);

    wait for period;
    current_neuron_value :=  TO_UNSIGNED(0, 8);
    for I in 0 to w-1 loop
        current_neuron <= current_neuron_value;
        wait for period;
        current_neuron_value := current_neuron_value + 1;
    end loop;
    -- End of testing mux function
    
    --wait for 5*period;
    busy <= false;
    report "Finished" severity warning;    
        
 end process testing_process;

end Behavioral;
