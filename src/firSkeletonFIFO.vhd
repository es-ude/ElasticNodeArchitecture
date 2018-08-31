-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:22:45 08/10/2018 
-- Design Name: 
-- Module Name:    FirWishboneSkeleton - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity firSkeletonFIFO is
	port(
		-- control interface 
		clock				: in std_logic; 
		reset				: in std_logic; -- controls functionality (sleep) 
		busy				: out std_logic; 
		-- done 				: out std_logic; -- done with entire calculation 
				
		-- indicate new data or request 
		rd					: in std_logic;	-- request a variable 
		wr 				: in std_logic; 	-- request changing a variable 
		
		-- data interface 
		data_in			: in uint8_t;
		address_in		: in uint16_t; 
		data_out			: out uint8_t
	);
	end firSkeletonFIFO;

architecture Behavioral of firSkeletonFIFO is

constant width : integer := 16;
constant fifodepth : integer := 10;
--signal dataInValid : std_logic;

signal hwfClock: std_logic;
signal hwfDataIn: signed(width-1 downto 0);
signal hwfDataOut: signed(2*width-1 downto 0);
signal dataOutValid : std_logic;
signal fifoDataOut : std_logic_vector(hwfDataOut'range);
signal fifoDataOutRequest, fifoEmpty, fifoFull : std_logic;

begin

uut: entity work.fir(rtl)
		port map (reset, hwfClock, hwfDataIn, hwfDataOut);

fifo: entity work.localFIFO(behavioral)
		generic map (2*width, fifodepth)
		port map (clock, reset, std_logic_vector(hwfDataOut), dataOutValid, fifoDataOut, fifoDataOutRequest, fifoEmpty, fifoFull);
		
dataoutvalidprocess: 
	process(clock) is
	begin
		if rising_edge(clock) then
			dataOutValid <= hwfClock;
		end if;
	end process;
	
	process (clock, rd, wr, reset) 
	begin 
		
		if reset = '1' then 
			hwfClock <= '1';
		else 
		-- beginning/end 
			if rising_edge(clock) then 

				fifoDataOutRequest <= '0';
				hwfClock <= '1';
				
				-- process address of written value 
				if wr = '0' or rd = '0' then 
					-- variable being set 
					-- reverse from big to little endian 
					if wr = '0' then 
						case to_integer(address_in) is
 						when 0 =>
							hwfDataIn(7 downto 0) <= signed(data_in);
						when 1 =>
							hwfDataIn(15 downto 8) <= signed(data_in);
							hwfClock <= '0';
						when others =>
						end case;
					elsif rd = '0' then
						case to_integer(address_in) is
						when 0 =>
							data_out <= unsigned(fifoDataOut(7 downto 0));
						when 1 =>
							data_out <= unsigned(fifoDataOut(15 downto 8));
						when 2 =>
							data_out <= unsigned(fifoDataOut(23 downto 16));
						when 3 =>
							data_out <= unsigned(fifoDataOut(31 downto 24));
							fifoDataOutRequest <= '1';
						when others =>

						end case; 
					else 

					end if; 
				end if; 
			end if; 
		end if; 
	end process; 
	
	
end Behavioral;

