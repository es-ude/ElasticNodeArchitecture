----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2019 01:42:06 PM
-- Design Name: 
-- Module Name: prime - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity prime is
	Port 
	(
		clock		:	in std_logic;
		reset		:	in std_logic;
		inputQuery	:	in int16_t;
		inputReady	:	in std_logic;
		inputWaiting:	out std_logic;

		outputValue	:	out int16_t;
		outputReady	:	out std_logic;
		outputAck	: 	in std_logic
	);
end prime;

architecture Behavioral of prime is
	type processState is (idle, processing, finished);
	signal curState : processState := idle;
	signal done : std_logic;
	signal curValueSignal : int16_t;
begin
	-- main state machine
	process (clock, reset) is
		begin
			if reset = '1' then
				curState <= idle;
			elsif rising_edge(clock) then 
				case curState is
					when idle =>
						if inputReady = '1' then
							curState <= processing;
						end if;
					when processing =>
						if done = '1' then
							curState <= finished;
						end if;
					when finished =>
						if outputAck = '1' then
							curState <= idle;
						end if;
				end case;
			end if;
	end process;

	-- calculation process
	process (clock, reset, curState) is
		variable curValue, curQuery : int16_t;
		begin
			if reset = '1' then
				curValue := (others => '0');
				curQuery := (others => '0');
				done <= '0';
			elsif rising_edge(clock) then
				case curState is
					when idle =>
						curValue := to_signed(2, 16);
						curQuery := inputQuery;
						done <= '0';
					when processing =>
						if curValue < curQuery - to_signed(1, 16) then
							-- current value divisible into query?
							if (curQuery mod curValue) = to_signed(0, 16) then
								outputValue <= to_signed(0, 16);
								done <= '1';
							else
								curValue := curValue + to_signed(1, 16);
							end if;
						else
							done <= '1';
						end if;
					when finished =>
						done <= '0';
				end case;
				curValueSignal <= curValue;
			end if;
	end process;

	-- output logic
	outputReady <= '1' when curState = finished else 
				'0';
	inputWaiting <= '1' when curState = idle else
				'0';
end Behavioral;
