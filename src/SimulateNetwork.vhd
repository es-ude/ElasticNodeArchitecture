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
use IEEE.NUMERIC_STD.all;
library neuralnetwork;
use neuralnetwork.Common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimulateNetwork is
end SimulateNetwork;

architecture Behavioral of SimulateNetwork is
	component Network is
	port (
			clk				: 	in std_logic;
			reset			:	in std_logic;
			
			learn			:	in std_logic;
			data_rdy		:	out std_logic := '0';
			calculate       :   in std_logic;

			connections_in	:	in fixed_point_vector;
			connections_out	:	out fixed_point_vector;
			
			wanted			:	in fixed_point_vector
			-- wanted			:	in uintw_t
		);
	end component;

	signal clk : std_logic := '0';	
	signal learn, data_rdy : std_logic := 'Z';
	constant period : time := 100 ns;
	constant period_internal : time := 25 ns;
	constant repeat : integer := 10;

	signal wanted			: 	fixed_point_vector := (others => (others => '0'));
	signal calculate, reset          :   std_logic;
	signal conn_in			:	fixed_point_vector := (others => zero);
	signal conn_out 		: fixed_point_vector := (others => real_to_fixed_point(0.0));
	
	signal busy : boolean := true;


	signal iteration : integer;
begin
	
	process
	begin
		if busy then
			wait for period_internal/2;
			clk <= not clk;
		else 
			wait;
		end if;
	end process;

	uut: Network port map (clk, reset, learn, data_rdy, calculate, conn_in, conn_out, wanted);
	process begin
		reset <= '1';
		wait for period_internal * l*2;
		reset <= '0';
		--n_feedback <= 'Z';

		-- wanted <= (real_to_fixed_point(1.0), real_to_fixed_point(1.0), real_to_fixed_point(0.0));
		wanted(0) <= (real_to_fixed_point(1.0));

		-- wanted <= to_unsigned(5, w);
		-- wanted(0) <= (factor);
		-- wanted <= (real_to_fixed_point(0.0), real_to_fixed_point(0.0), real_to_fixed_point(0.0));

		-- conn_in <= (real_to_fixed_point(1.0), real_to_fixed_point(0.0), real_to_fixed_point(0.0));
		conn_in(0) <= (real_to_fixed_point(1.0));
--		learn <= '0';
		-- conn_in <= ('1', '0', '0');
		-- conn_in <= to_unsigned(1, w);
--		
--		calculate <= '0';
--		wait for period;
--		calculate <= '1';
--		wait for period;
--		calculate <= '0';
--		
--		wait until data_rdy = '1';
		--n_feedback <= '1';
		-- wait for period * 2 * (l * 2 + 1);
		-- weait until data_rdy = '1';
		

		for i in 0 to 100 loop
			iteration <= i;
			
			learn <= '1';
			calculate <= '0';
			wait for period;
			calculate <= '1';
			wait for period;
			calculate <= '0';
			-- wait for period * 2 * (l * 2 + 1);
			wait until data_rdy = '1';
			wait for period;
			
--			learn <= '0';
--			calculate <= '0';
--			wait for period;
--			calculate <= '1';
--			wait for period;
--			calculate <= '0';
--			-- wait for period * 2 * (l * 2 + 1);
--			wait until data_rdy = '1';
--			wait for period;
		end loop;
		busy <= false;
		wait;
	end process;
end Behavioral;

