----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2015 09:33:28 AM
-- Design Name: 
-- Module Name: NeuralNetwork - Behavioral
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

-- library fpgamiddlewarelibs;
-- use fpgamiddlewarelibs.userlogicinterface.all;

library neuralnetwork;
use neuralnetwork.Common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NeuralNetwork is
    Port (
		clk             :  in std_logic;
		reset				:  in std_logic;
		
		learn           :  in std_logic;
		data_rdy        :  out std_logic;
		calculate       :  in std_logic;
		
		connections_in  :  in uintw_t;
		wanted          :  in uintw_t;
		connections_out :  out uintw_t
	);
end NeuralNetwork;

architecture Behavioral of NeuralNetwork is
component Network is
	port (
		clk					: 	in std_logic;
		reset					:	in std_logic;
		
		learn					:	in std_logic;
		data_rdy				:	out std_logic := '0';
		calculate			:   in std_logic;
	
		connections_in		:	in fixed_point_vector;
		connections_out	:	out fixed_point_vector;
		
		-- wanted			:	in fixed_point_vector
		wanted				:	in fixed_point_vector
		);
end component;


component FixedPoint_Logic is
	Port (
		fixed_point		:	in fixed_point_vector;
		std_logic_vec	: 	out uintw_t;
		clk			:	in std_logic
	);
end component;

component Logic_FixedPoint is
	Port (
		fixed_point		:	out fixed_point_vector;
		std_logic_vec	: 	in uintw_t;
		clk			:	in std_logic
	);
end component;

--signal enable           : std_logic;
--signal learn            : std_logic;
--signal data_rdy         : std_logic;
--signal wanted           : std_logic_vector(w-1 downto 0);
--signal connections_in   : std_logic_vector(w-1 downto 0);
--signal connections_out  : std_logic_vector(w-1 downto 0);
signal mode_out         : std_logic_vector(2 downto 0);

signal connections_in_fp   : fixed_point_vector := (others => real_to_fixed_point(0.0));
signal wanted_fp           : fixed_point_vector := (others => real_to_fixed_point(0.0));
signal connections_out_fp  : fixed_point_vector;

--signal clk_slow             : std_logic := '0';
--signal wanted           : fixed_point_vector := (others => real_to_fixed_point(0.0));

begin

--connections_in <= data_in(w-1 downto 0);
--wanted <= data_in(2*w-1 downto w);
--learn <= data_in(2*w);
--enable <= data_in(2*w + 1);
--
--data_out(w-1 downto 0) <= connections_in;
--data_out(2*w-1 downto w) <= wanted;
--data_out(2*w) <= learn;
--data_out(2*w+1) <= enable;
--data_out(2*w+2) <= data_rdy;
--data_out(3*w+2 downto 2*w+3) <= connections_out;
--data_out(3*w+5 downto 3*w+3) <= mode_out;

--process (clk)
--    variable count : integer range 0 to 2 := 0; 
--    begin
--    if falling_edge(clk) then
--        -- divide the incoming 100MHz down to 25MHz
--        count := count + 1;
--        if count = 2 then 
--            clk_slow <= not clk_slow;
--            count := 0;
--        end if;
--    end if;
--end process;

net: Network port map
(
    clk, reset, learn, data_rdy, calculate, connections_in_fp, connections_out_fp, wanted_fp
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

end Behavioral;
