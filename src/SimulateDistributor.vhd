----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:56:35 07/27/2015 
-- Design Name: 
-- Module Name:    SimulateDistributor - Behavioral 
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
library DesignLab;
use DesignLab.Common.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimulateDistributor is
end SimulateDistributor;

architecture Behavioral of SimulateDistributor is

component Distributor is
	port
	(
		clk			:	in std_logic;
		learn		:	in std_logic;

		n_feedback_bus	:	out std_logic_vector(l downto 0) := (others => 'Z')
	);
end component;


signal clk : std_logic := '0';
constant period : time := 100 ns;
signal learn : std_logic;
signal n_feedback_bus : std_logic_vector(l downto 0);

begin
	clk <= not clk after period / 2;

uut: Distributor port map (clk, learn, n_feedback_bus);

process begin
	learn <= '0';
	wait for period;
	learn <= '1';
	wait for period * 2 * (l * 2 + 1);
	--learn <= '0';
	wait;
end process;

end Behavioral;

