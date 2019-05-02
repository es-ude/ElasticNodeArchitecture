-- generated 2019-04-10 17:10:19.073240
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;


package firPackage is

-- data width
constant firWidth		: natural := 16;
constant fifoDepth 		: natural := 50;

-- /* 32-by-N matrix array structure (as in RAM). Similar to integer_vector, difference being base vector is 32-bit unsigned. */
type signed_vector is array(natural range <>) of signed(firWidth-1 downto 0);
type signedx2_vector is array(natural range<>) of signed(firWidth*2-1 downto 0);

-- filter order
constant order : natural := 8;

-- addresses
constant addressWidth : integer := 4; -- ceil(log2(1 + order))
constant u_address : std_logic_vector(addressWidth-1 downto 0) := std_logic_vector(to_unsigned(0, addressWidth));
constant y_address : std_logic_vector(addressWidth-1 downto 0) := std_logic_vector(to_unsigned(0, addressWidth));

-- /* Filter length = number of taps = number of coefficients = order + 1 */
constant fir_coeff:signed_vector(0 to order):=(
	x"003B",
	x"00B3",
	x"01EC",
	x"033D",
	x"03CE",
	x"033D",
	x"01EC",
	x"00B3",
	x"003B"
);

end package;