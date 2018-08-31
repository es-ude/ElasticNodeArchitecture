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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FirWishboneSkeleton is
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
	end FirWishboneSkeleton;

architecture Behavioral of FirWishboneSkeleton is

constant firWidth : integer := 16;
constant firDepth : integer := 2;
signal dataInValid : std_logic;
signal hwfDataIn: std_logic_vector(width-1 downto 0);
signal dataOutValid : std_logic;

begin

uut: entity work.fir(rtl)
		generic map (16, 10)
		port map (reset, hwfClock, hwfDataIn, hwfDataOut);

dataoutvalidprocess: 
	process(hwfClock) is
	begin
		if rising_edge(hwfClock) then
			dataOutValid <= dataInValid;
		end if;
	end process;
	
	process (clock, rd, wr, reset) 
	begin 
		
		if reset = '1' then 
			hwfClock <= '0';
		else 
		-- beginning/end 
			if rising_edge(clock) then 
				-- process address of written value 
				if wr = '0' or rd = '0' then 
					-- variable being set 
					-- reverse from big to little endian 
					if wr = '0' then 
						case to_integer(address_in) is
 						when 0 =>
							hwf_data_in(7 downto 0) <= data_in;
						when 1 =>
							hwf_data_in(15 downto 8) <= data_in;
						when others =>
						end case;
					elsif rd = '0' then
						calculate <= '0';
						case to_integer(address_in) is
						when 0 =>
							data_out <= dataout(7 downto 0);
						when 1 =>
							data_out <= dataout(15 downto 8);
						when 2 =>
							data_out <= dataout(23 downto 16);
						when 3 =>
							data_out <= dataout(31 downto 24);
						when others =>

						end case; 
					else 
						calculate <= '0'; 
					end if; 
				end if; 
			end if; 
		end if; 
	end process; 
	
	
end Behavioral;

