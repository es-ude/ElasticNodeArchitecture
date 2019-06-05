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

		ready			: out std_logic;
		
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
	signal y, ytmp : signed(firWidth*2-1 downto 0);
	constant zero : signed(firWidth*2-1 downto 0) := (others => '0');

	signal q : signed(u'range);

	-- /* Pipes and delay chains. */
	signal y0:signed(u'length*2-1 downto 0);
	signal u_pipe:signed_vector(fir_coeff'range):=(others=>(others=>'0'));
	signal y_pipe:signedx2_vector(fir_coeff'range):=(others=>(others=>'0'));
	
	signal filterClock : std_logic := '0';
	signal b_signal : signed_vector(0 to order);
	signal stateCount : integer range 0 to (order + 1);


	type filterState is (idle, calculating);
	signal currentState : filterState;
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
				--else
				--	index := to_integer(unsigned(addressIn)) - 1;
				--	b_signal(index) <= dataIn;
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

	-- u pipe part
uChain: process(clk, filterClock, reset) is begin
		if reset = '1' then
			u_pipe(0) <= (others => '0');
		elsif falling_edge(clk) then
			if filterClock = '1' then
				u_pipe(0)<=u; 
			end if;
		end if;
	end process;
	-- u_pipe(0)<=u;
u_dlyChain: for i in 1 to u_pipe'high generate
		delayChain: process(clk, filterClock, reset) is begin
			if reset = '1' then
				u_pipe(i) <= (others => '0');
			elsif falling_edge(clk) then
				if filterClock = '1' then
					u_pipe(i)<=u_pipe(i-1); 
				end if;
			end if;
		end process delayChain;
	end generate u_dlyChain;

	-- filter part
filterStateProcess: process (reset, clk, filterClock) is
	begin
		if reset = '1' then
			currentState <= idle;
			stateCount <= 0;
			y <= zero;
		elsif falling_edge(clk) then
			if filterClock = '1' and currentState = idle then
				currentState <= calculating;
			elsif currentState = calculating then
				if stateCount = order then
					currentState <= idle;
					stateCount <= 0;
					y <= ytmp;
				else
					stateCount <= stateCount + 1;
				end if;
			end if;
		end if;
	end process;

	-- calculation part
filterProcess: process (reset, clk) is

	begin
		if reset = '1' then
			ytmp <= zero;
			ready <= '1';
		elsif rising_edge(clk) then
			if currentState = calculating then
				ready <= '0';

				ytmp <= ytmp + fir_coeff(stateCount) * u_pipe(stateCount);
			else
				ytmp <= zero;
				ready <= '1';
			end if;
		end if;
	end process;

end Behavioral;

