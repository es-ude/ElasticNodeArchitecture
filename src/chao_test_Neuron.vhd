----------------------------------------------------------------------------------
-- Company: University Duisburg Essen
-- Engineer: Chao Qian
-- 
-- Create Date: 08/15/2018 11:58:06 AM
-- Design Name: chao_test_Neuron
-- Module Name: chao_test_Neuron - Behavioral
-- Project Name: fpgamiddlewareproject
-- Target Devices: 
-- Tool Versions: 
-- Description: This is a testbench file for testing the Neuron module
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library neuralnetwork;
use neuralnetwork.Common.all;

library ieee_proposed;
use ieee_proposed.fixed_float_types.all;

-- Entity declaration
entity chao_test_Neuron is
--  Port ( ); -- no ports needed for testbench
end chao_test_Neuron;




architecture neuron_simulation of chao_test_Neuron is
    constant period : time := 100 ns;
    signal   clock  : std_logic :='0';
    signal   reset  : std_logic :='0';
    
    component Neuron
        port(
            clk               :	in std_logic;
        
            n_feedback        : in integer range 0 to 2;
            output_neuron     : in std_logic; -- tell neuron to only consider own error
            index             : in integer range 0 to w-1;
    
            input_connections : in fixed_point_vector;
            input_errors      : in fixed_point_vector;
    
            output_connection : out fixed_point := zero;
            output_previous   : in fixed_point;
            output_errors     : out fixed_point_vector := (others => zero);
            
            weights_in        : in fixed_point_vector;
            weights_out       : out fixed_point_vector := (others => factor_2);
            
            bias_in           : in fixed_point;
            bias_out          : out fixed_point
        );
    end component;
    
    -- External test signal definatition
    signal n_feedback : integer range 0 to 2;
    signal o_neuron   : std_logic := 'Z';
    signal i_index    : integer range 0 to w-1;
    
    
    signal i_conn     : fixed_point_vector := (others => real_to_fixed_point(0.0));
    signal i_errors   : fixed_point_vector := (others => real_to_fixed_point(0.0));
        
    signal o_conn     : fixed_point;
    signal i_prev_out : fixed_point;
    signal o_errors   : fixed_point_vector;

    
    signal i_weights  : fixed_point_vector;
    signal o_weights  : fixed_point_vector;
    
    signal i_bias     : fixed_point:= real_to_fixed_point(0.0);
    signal o_bias     : fixed_point;
    
    signal busy       : boolean := true;
    
begin
    process
    begin
        if busy then
            wait for period/2;
            clock <= not clock;
        else
            wait;
        end if;    
    end process;

    -- Signal reset
    process
    begin
        wait for 5 ns;
        reset <= '1';
        
        wait for 20 ns;
        reset <= '0';

        wait;
    end process;
    
    utt: Neuron port map(
        clk => clock,
        n_feedback => n_feedback,
        output_neuron => o_neuron,
        index => i_index,
        input_connections => i_conn,
        input_errors => i_errors,
        output_connection => o_conn,
        output_previous => i_prev_out,
        output_errors => o_errors,
        weights_in => i_weights,
        weights_out => o_weights,
        bias_in => i_bias,
        bias_out => o_bias
    );
    
    process
    begin
        wait until reset='1';
        wait until reset='0';
        n_feedback <= 1;
        -- i_errors() <= real_to_fixed_point();
        -- i_conn() <= real_to_fixed_point();
        -- i_weights <= real_to_fixed_point();
        i_errors(0) <= real_to_fixed_point(0.0);
        i_errors(1) <= real_to_fixed_point(0.1);
        i_errors(2) <= real_to_fixed_point(1.0);
        i_errors(3) <= real_to_fixed_point(0.0);
        i_errors(4) <= real_to_fixed_point(0.1);
        i_errors(5) <= real_to_fixed_point(1.0);
        i_errors(6) <= real_to_fixed_point(0.1);
        i_errors(7) <= real_to_fixed_point(1.0);
        
        i_conn(0) <= real_to_fixed_point(1.0);
        i_conn(1) <= real_to_fixed_point(1.0);
        i_conn(2) <= real_to_fixed_point(1.0);
        i_conn(3) <= real_to_fixed_point(0.0);
        i_conn(4) <= real_to_fixed_point(0.0);
        i_conn(5) <= real_to_fixed_point(0.0);
        i_conn(6) <= real_to_fixed_point(0.1);
        i_conn(7) <= real_to_fixed_point(0.1);
        
        i_weights(0) <= real_to_fixed_point(0.0);
        i_weights(1) <= real_to_fixed_point(0.1);
        i_weights(2) <= real_to_fixed_point(1.0);
        i_weights(3) <= real_to_fixed_point(0.0);
        i_weights(4) <= real_to_fixed_point(0.1);
        i_weights(5) <= real_to_fixed_point(1.0);
        i_weights(6) <= real_to_fixed_point(0.1);
        i_weights(7) <= real_to_fixed_point(0.1);               
        wait until rising_edge(clock);
        wait for 20*period;
        
        busy <= false;
        report "Finished" severity warning;    
    end process;

end neuron_simulation;
