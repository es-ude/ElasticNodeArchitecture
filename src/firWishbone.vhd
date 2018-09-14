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

library work;
use work.firPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity firWishbone is
	port(
		-- generic interface
		clk				: in std_logic;
		reset 			: in std_logic;
		writeEnable		: in std_logic;
		stb				: in std_logic;
		
		-- ack and cyc ignored for now
		
		-- streaming interface
		addressIn		: in std_logic_vector(addressWidth-1 downto 0);
		dataIn			: in int16_t;
--		dataInValid		: in std_logic;
		dataOut			: out int32_t
--		dataOutValid	: out std_logic
	);
end firWishbone;

architecture Behavioral of firWishbone is

	signal dataOutSignal : int32_t;

	signal u : signed(firWidth-1 downto 0);
	signal y : signed(firWidth*2-1 downto 0);

	signal q : signed(u'range);

	-- /* Pipes and delay chains. */
	signal y0:signed(u'length*2-1 downto 0);
	signal u_pipe:signed_vector(fir_coeff'range):=(others=>(others=>'0'));
	signal y_pipe:signedx2_vector(fir_coeff'range):=(others=>(others=>'0'));
	
	signal filterClock : std_logic := '0';
	signal b_signal : signed_vector(0 to order);
-- attribute mult_style:string; attribute mult_style of fir:entity is "block";		--xilinx
	
begin

	-- data input
dataInProcess: process (reset, clk, stb, writeEnable) is
	variable index : integer range 0 to order := 0;
	begin
		if reset = '1' then
			u <= (others => '0');
			b_signal <= fir_coeff;
			index := 0;
		elsif rising_edge(clk) then
			if stb = '1' and writeEnable = '1' then
				-- u
				if addressIn = u_address then
					u <= dataIn;
					filterClock <= '1';
				else
					index := to_integer(unsigned(addressIn)) - 1;
					b_signal(index) <= dataIn;
				end if;
			else
				filterClock <= '0';
			end if;
		end if;
	end process;


	-- data output
dataOutProcess: process (reset, clk, stb, writeEnable) is
	
	begin
		if reset = '1' then
			
		elsif rising_edge(clk) then
			if stb = '1' and writeEnable = '0' then
				-- y
				case addressIn is 
					when y_address =>
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
	
	y_pipe(0)<=fir_coeff(0)*u;
	y_dlyChain: for i in 1 to y_pipe'high generate
		y_pipe(i)<=b_signal(i)*u_pipe(i) + y_pipe(i-1);
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

