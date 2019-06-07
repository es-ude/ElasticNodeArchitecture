----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:03:45 04/01/2019 
-- Design Name: 
-- Module Name:    SoftSRAM - Behavioral 
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
use ieee.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

library neuralnetwork;
use neuralnetwork.all;
use neuralnetwork.common.all;

entity SoftSRAM is
    generic (
        DATA    : integer := 16;
        ADDR    : integer := 19
    );
    port (
        clk                 : in std_logic;
        reset               : in std_logic;
        address             : in std_logic_vector(ADDR-1 downto 0);
        data_io             : inout std_logic_vector(DATA-1 downto 0);
        cs_1                : in std_logic;
        cs_2                : in std_logic;
        output_enable       : in std_logic;
        write_enable        : in std_logic;
        upper_byte_select   : in std_logic;
        lower_byte_select   : in std_logic
    );
    end SoftSRAM;

architecture Behavioral of SoftSRAM is
    -- type mem_type is array ( (2**ADDR)-1 downto 0 ) of std_logic_vector(DATA-1 downto 0);
    -- 2^ADDR might be too large for Block RAM. Here we assume we only need 64kB space.
    type mem_type is array ( (2**8)-1 downto 0 ) of std_logic_vector(DATA-1 downto 0);
    shared variable mem : mem_type;
    signal data_out : std_logic_vector(DATA-1 downto 0);
    --signal test_softram : mem_type;
begin
    
    MEM_WRITE_clk: process (reset, clk) 
    begin
        --if reset = '1' then
        --    mem := (others=>(others=>'0'));
        if (rising_edge(clk)) then --  or falling_edge(clk)) then
            if (cs_1 = '0' and cs_2='1' and write_enable='0') then
                if(upper_byte_select='0' and lower_byte_select='0') then
                    mem(conv_integer(address)) := data_io;
                elsif (upper_byte_select='1' and lower_byte_select='0') then
                    mem(conv_integer(address))(7 downto 0) := data_io(7 downto 0);
                elsif (upper_byte_select='0' and lower_byte_select='1') then
                    mem(conv_integer(address))(15 downto 8) := data_io(15 downto 8);
                else
                
                end if;
            elsif (cs_1 = '0' and cs_2 ='1' and write_enable='1' and output_enable='0') then
                data_out <= mem(conv_integer(address));
                --test_softram <= mem;
            end if;
        end if;
    end process;
    

    data_io <= data_out when (cs_1 = '0' and cs_2 ='1' and output_enable = '0' and write_enable='1') else (others=>'Z');
    
    --MEM_Read_clk: process (reset, clk) 
    --begin
    --    --if reset = '1' then
    --    --       ---
    --    if (rising_edge(clk)) then -- or falling_edge(clk)) then
            
    --    end if;
    --end process;
    
end Behavioral;