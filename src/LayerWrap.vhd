----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:55:58 07/08/2015 
-- Design Name: 
-- Module Name:    LayerWrap - Behavioral 
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

entity LayerWrap is
end LayerWrap;

architecture Behavioral of LayerWrap is
	component Layer port (
			clk				:	in std_logic;

			connections_in	:	in probability_vector;
			connections_out	:	out probability_vector;

			errors_in		:	in probability_vector;
			errors_out		:	out probability_vector
		);
	end component;

	signal clk : std_logic;
	signal connections_in, errors_in, errors_out : probability_vector := (others => 0.0);
	signal connections_out : probability_vector := (others => 0.0);
begin

layer_init : Layer port map
(
	clk, connections_in, connections_out, errors_in, errors_out
	);

end Behavioral;

