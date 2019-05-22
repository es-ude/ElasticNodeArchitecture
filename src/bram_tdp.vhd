-- A parameterized, inferable, true dual-port, dual-clock block RAM in VHDL.
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library neuralnetwork;
use neuralnetwork.common.all;

entity bram_tdp is
generic (
    DATA    : integer := 72;
    ADDR    : integer := 10
);
port (
    -- Port A
    a_clk   : in  std_logic;
    a_wr    : in  std_logic;
    a_addr  : in  std_logic_vector(ADDR-1 downto 0);
    a_din   : in  std_logic_vector(DATA-1 downto 0);
    a_dout  : out std_logic_vector(DATA-1 downto 0);
     
    -- Port B
    b_clk   : in  std_logic;
    b_wr    : in  std_logic;
    b_addr  : in  std_logic_vector(ADDR-1 downto 0);
    b_din   : in  std_logic_vector(DATA-1 downto 0);
    b_dout  : out std_logic_vector(DATA-1 downto 0)
);
end bram_tdp;
 
architecture rtl of bram_tdp is
    -- Shared memory
    type mem_type is array ( (2**ADDR)-1 downto 0 ) of std_logic_vector(DATA-1 downto 0);
    shared variable mem : mem_type;
    --signal mem_s : mem_type;
    --signal mem_w : fixed_point_matrix;
begin
--mem_s <= mem;
-- Port A
process(a_clk)
begin
    if(a_clk'event and a_clk='1') then
        if(a_wr='1') then
            mem(conv_integer(a_addr)) := a_din;
        end if;
        a_dout <= mem(conv_integer(a_addr));
    end if;
end process;
 
-- Port B
process(b_clk)
begin
    if(b_clk'event and b_clk='1') then
        if(b_wr='1') then
            mem(conv_integer(b_addr)) := b_din;
        end if;
        b_dout <= mem(conv_integer(b_addr));

        --mem_s <= mem;
    end if;
end process;
 
end rtl;