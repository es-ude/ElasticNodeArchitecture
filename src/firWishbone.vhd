----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:29:45 08/10/2018 
-- Design Name: 
-- Module Name:    firWishbone - Behavioral 
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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

use work.firPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity firWishbone is
	generic(
		uWidth			: natural := 16
	);
	port(
		-- generic interface
		clk				: in std_logic;
		reset 			: in std_logic;
		writeEnable		: in std_logic;
		stb				: in std_logic;
		
		-- ack and cyc ignored for now
		
		-- streaming interface
		addressIn		: in std_logic_vector(1 downto 0);
		dataIn			: in int16_t;
--		dataInValid		: in std_logic;
		dataOut			: out int32_t
--		dataOutValid	: out std_logic
	);
end firWishbone;

architecture Behavioral of firWishbone is

	signal dataOutSignal : int32_t;

	signal u : signed(uWidth-1 downto 0);
	signal y : signed(uWidth*2-1 downto 0);

	signal q : signed(u'range);

	-- /* 32-by-N matrix array structure (as in RAM). Similar to integer_vector, difference being base vector is 32-bit unsigned. */
	type signed_vector is array(natural range <>) of signed(u'range);
	type signedx2_vector is array(natural range<>) of signed(y'range);

	-- /* Pipes and delay chains. */
	signal y0:signed(u'length*2-1 downto 0);
	signal u_pipe:signed_vector(b'range):=(others=>(others=>'0'));
	signal y_pipe:signedx2_vector(b'range):=(others=>(others=>'0'));
	
	signal filterClock : std_logic := '0';
-- attribute mult_style:string; attribute mult_style of fir:entity is "block";		--xilinx
	
begin

	-- data input
dataInProcess: process (clk, stb, writeEnable) is
	
	begin
		if reset = '1' then
			
		elsif rising_edge(clk) then
			if stb = '1' and writeEnable = '1' then
				-- u
				if addressIn = "00" then
					u <= dataIn;
					filterClock <= '1';
				end if;
			else
				filterClock <= '0';
			end if;
		end if;
	end process;


	-- data output
dataOutProcess: process (clk, stb, writeEnable) is
	
	begin
		if reset = '1' then
			
		elsif rising_edge(clk) then
			if stb = '1' and writeEnable = '0' then
				-- y
				case addressIn is 
					when "00" =>
						dataOut <= y;
					when others =>
				end case;
			end if;
		end if;
	end process;

	-- filter part
	u_pipe(0)<=u;
	u_dlyChain: for i in 1 to u_pipe'high generate
		delayChain: process(clk, filterClock) is begin
			if rising_edge(clk) then
				if filterClock = '1' then
					u_pipe(i)<=u_pipe(i-1); 
				end if;
			end if;
		end process delayChain;
	end generate u_dlyChain;
	
	y_pipe(0)<=b(0)*u;
	y_dlyChain: for i in 1 to y_pipe'high generate
		y_pipe(i)<=b(i)*u_pipe(i) + y_pipe(i-1);
	end generate y_dlyChain;
	
	y0<=y_pipe(y_pipe'high) when reset='0' else (others=>'0');
	y<=y0(y'range);
	
--filter : entity work.fir(rtl)
--	port map (reset, filterClock, dataIn, dataOutSignal);
--
--	dataOut <= dataOutSignal;
--	filterClock <= clk and dataInValid and not reset;
	
--dataoutvalidprocess: 
--	process(clk) is
--		if rising_edge(clk) then
--			dataOutValid <= dataInValid;
--		end if;
--	end process;

end Behavioral;

