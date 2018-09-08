----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/28/2018 04:03:38 PM
-- Design Name: 
-- Module Name: TestDistributor - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

library neuralnetwork;
use neuralnetwork.Common.all;

entity TestDistributor is
--  Port ( );
end TestDistributor;

architecture Behavioral of TestDistributor is
    
    -- component declaration
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
    
        data_rdy        :   out std_logic;
        mode_out        :   out distributor_mode
    );
    end component;
    
    -- Clock and reset signal
    constant period : time := 100 ns;
    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';
    signal busy  : boolean   := true;
    
    signal learn : std_logic := '0';
    signal calculate : std_logic := '0';
    signal n_feedback_bus : std_logic_vector(l downto 0); -- l==4
    
    signal n_feedback : integer;
    signal current_layer : uint8_t := (others => '0');
    signal current_neuron : uint8_t := (others => '0');
    
    signal data_rdy : std_logic := '0';
    signal dist_mode : distributor_mode;
    
begin

    -- Clock process
    clock_signal : process
        begin
            if busy then
                wait for period/2;
                clk <= not clk;
            else
                wait;
            end if;    
    end process clock_signal;

    utt: Distributor port map
    (
        clk, reset, learn, calculate, n_feedback_bus, n_feedback, current_layer, current_neuron, data_rdy, dist_mode
    );


    testing_process : process
    begin
        -- n_feedback_bus is not in use, so just check if it is equal to 'ZZZZZ'
        
        -- In feedforward mode (learn function is '0' => not learning => feedforward)
        -- Start of testing clk, reset, calculate, n_feedback, current_layer, current_neuron, data_rdy, dist_mode
        reset <= '1';
        wait for period *2;
        reset <= '0';
        wait for 1*period;
        
        calculate <= '1';
        wait for 1*period;
        calculate <= '0';
        wait for 40*period;   
        -- after  data_rdy is setted to '1', the calculation will stop, until next rising edge of calculate
        -- End of testing clk, reset, calculate, n_feedback, current_layer, current_neuron, data_rdy, dist_mode
        
        -- In backward mode (learn function is '1' => enable learning => backward)
        -- Start of testing clk, reset, learn, calculate, n_feedback, current_layer, current_neuron, data_rdy, dist_mode
        learn <= '1'; -- enable the backward function
        
        calculate <= '1';
        wait for 1*period;
        calculate <= '0';
        wait for 80*period; 
        -- feedforward first, after all layers switchs to backward automaticly
        -- layer_count counts downward
        -- neuron counts upward
        -- after all layers wented through, mode is setted to 5 -> then is setted 4 and data_rdy is setted to '1'
        -- when mode changes from 5 to 4 layer_count and neuron_count are both setted as 'Uninitialized'
        -- mode is setted 0
        -- wait for changing of calculate signal 
        -- End of testing clk, reset, learn, calculate, n_feedback, current_layer, current_neuron, data_rdy, dist_mode

		wait for period*1;
		busy <= false;
		report "Finished" severity warning;
		wait;
    end process testing_process;
end Behavioral;
