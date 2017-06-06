----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:18:31 07/08/2015 
-- Design Name: 
-- Module Name:    SimulateLayer - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library DesignLab;
use DesignLab.Common.all;

entity SimulateOutputLayer is
end SimulateOutputLayer;

architecture Behavioral of SimulateOutputLayer is	
	component OutputLayer 
		port (
			clk				:	in std_logic;

			n_feedback		:	in std_logic;

			connections_in	:	in weights_vector;
			connections_out	:	out weights_vector;

			errors_in		:	in weights_vector;
			errors_out		:	out weights_vector
		);
	end component;

	signal clk : std_logic := '0';
	constant period : time := 100 ns;

	signal conn_in, conn_out : weights_vector := (others => 0.0);
	signal err_in, err_out : weights_vector := (others => 0.0);
	signal n_feedback : std_logic := 'Z';

begin
	clk <= not clk after period / 2;

	uut : OutputLayer port map 
		(clk => clk, n_feedback => n_feedback, connections_in => conn_in , connections_out => conn_out, errors_in => err_in, errors_out => err_out);
	process begin
		n_feedback <= 'Z';
		conn_in <= (1.0, 0.0, 1.0);
		wait for period;
		n_feedback <= '1';
		wait for period;
		err_in <= (1.0, 1.0, 0.0);
		n_feedback <= '0';
		wait for period;
		n_feedback <= 'Z';
		wait;
	end process;
end Behavioral;

