----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/01/2019 02:21:06 PM
-- Design Name: 
-- Module Name: TestSoftSRAM - Behavioral
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
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;


library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

library neuralnetwork;
use neuralnetwork.all;
use neuralnetwork.common.all;

entity TestSoftSRAM is
--  Port ( );
end TestSoftSRAM;


architecture Behavioral of TestSoftSRAM is
    -- Clock and reset signal
    constant period : time      := 10 ps;
    signal   clk    : std_logic := '0';
    signal   reset  : std_logic := '1';
    signal   testing: boolean   := true;
    
    -- Test Signals
    signal addr : std_logic_vector(18 downto 0):=(others=>'0');
    signal data : std_logic_vector(15 downto 0):=(others=>'0');
    signal cs_1, cs_2, oe, we : std_logic;
    
begin
    testSoftSRAM: entity neuralnetwork.SoftSRAM port map(
        address=>addr,
        data_io=>data,
        cs_1=>cs_1,
        cs_2=>cs_2,
        output_enable=>oe,
        write_enable=>we,
        upper_byte_select=>'0',
        lower_byte_select=>'0'
    );  
    
    process 
    begin
        if testing then
            wait for period/2;
            clk <= not clk;
        else 
            wait;
        end if;
    end process;
    process 
    begin 
        reset <= '1';
        wait for period *2;
        reset <= '0';
        
        for i in 0 to 10 loop
            addr <= conv_std_logic_vector(i, addr'length);
            data <= conv_std_logic_vector(i, data'length);
            cs_1 <= '0';
            cs_2 <= '1';
            oe <= '1';
            we <= '0';
            wait for period;
            we <= '1';
            wait for period;
        end loop;
        
        data <= (others=>'Z');
        cs_1 <= '0';
        cs_2 <= '1';
        oe <= '0';
        we <= '1';
                    
        for i in 0 to 10 loop
            addr <= conv_std_logic_vector(i, addr'length);
            wait for period;
        end loop;      
                
        testing <= false;
        report "Finished" severity warning;
        wait;
    end process;
end Behavioral;
