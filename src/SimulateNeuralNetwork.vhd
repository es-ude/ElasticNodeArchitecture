----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:20:33 07/27/2015 
-- Design Name: 
-- Module Name:    SimulateNetwork - Behavioral 
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
library neuralnetwork;
use neuralnetwork.Common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimulateNeuralNetwork is
end SimulateNeuralNetwork;

architecture Behavioral of SimulateNeuralNetwork is
	component NeuralNetwork is
    Port (
            clk             :	in std_logic;
            reset			:	in std_logic;
					
            learn           :	in std_logic;
            data_rdy        :	out std_logic;
            calculate       :	in std_logic;
				
--            data_in         :  in std_logic_vector(3*w+2 downto 0);
--            data_out         :  out std_logic_vector(3*w+2 downto 0)
            connections_in  :	in uintw_t;
            wanted          :	in uintw_t;
            connections_out :	out uintw_t
        );
	end component;

	signal clk_s : std_logic := '0';	
	signal learn, data_rdy, calculate : std_logic := 'Z';
	signal reset : std_logic := '1';
	constant period : time := 40 ns;
	constant repeat : integer := 10;

	signal wanted				: 	uintw_t := (others => '0');
	signal conn_in, conn_out 	: uintw_t := (others => '0');
	
	signal busy 	: boolean := true;

begin
--	data_in(w-1 downto 0) <= conn_in;
--	data_in(2*w-1 downto w) <= wanted;
--	data_in(2*w) <= learn;
--	data_in(2*w + 1) <= enable;
--
--	data_rdy <= data_out(2*w+2);
--	conn_out <= data_out(3*w+2 downto 2*w+3);
	
	process
	begin
		if busy then
			wait for period/2;
			clk_s <= not clk_s;
		else 
			wait;
		end if;
	end process;

	uut: NeuralNetwork port map (clk_s, reset, learn, data_rdy, calculate, conn_in, wanted, conn_out);
	process begin
		wait for period;
		reset <= '0';

		--n_feedback <= 'Z';
		learn <= '0';
		conn_in <= ('1', '0', '1'); -- (real_to_fixed_point(1.0), real_to_fixed_point(0.0), real_to_fixed_point(1.0));
		wanted <= ('1', '1', '0'); -- (real_to_fixed_point(1.0), real_to_fixed_point(1.0), real_to_fixed_point(0.0));
		calculate <= '1';
		
		wait for period;
		calculate <= '0';
		wait until data_rdy = '1';
		wait for period; 
		
		learn <= '1';
		calculate <= '1';
		
		--learn <= '1';
		----n_feedback <= '1';
		wait until data_rdy = '1';
		wait for period * 4; 

		busy <= false;
		wait;
	end process;
end Behavioral;

