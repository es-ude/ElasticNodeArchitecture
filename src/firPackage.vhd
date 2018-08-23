library IEEE;
use IEEE.NUMERIC_STD.ALL;


package firPackage is

-- data width
constant uWidth			: natural := 16;

-- /* 32-by-N matrix array structure (as in RAM). Similar to integer_vector, difference being base vector is 32-bit unsigned. */
type signed_vector is array(natural range <>) of signed(uWidth-1 downto 0);
type signedx2_vector is array(natural range<>) of signed(uWidth*2-1 downto 0);
	
-- filter order
constant order : natural := 16;

-- /* Filter length = number of taps = number of coefficients = order + 1 */
constant b:signed_vector(0 to order):=(
	x"FFEF",
	x"FFED",
	x"FFE8",
	x"FFE6",
	x"FFEB",
	x"0000",
	x"002C",
	x"0075",
	x"00DC",
	x"015F",
	x"01F4",
	x"028E",
	x"031F",
	x"0394",
	x"03E1",
	x"03FC",
	x"03E1"
	--x"0394",
	--x"031F",
	--x"028E",
	--x"01F4",
	--x"015F",
	--x"00DC",
	--x"0075",
	--x"002C",
	--x"0000",
	--x"FFEB",
	--x"FFE6",
	--x"FFE8",
	--x"FFED",
	--x"FFEF"
);

end package;