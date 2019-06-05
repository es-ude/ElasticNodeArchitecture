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
library prime;
use prime.Prime;

library work;
use work.all;

entity primeRange is
	Port 
	(
		clock		:	in std_logic;
		reset		:	in std_logic;

		startQuery	:	in int16_t;
		endQuery	:	in int16_t;
		inputReady	: 	in std_logic;

		outputValue	:	out int16_t;
		outputReady	:	out std_logic;
		outputAck	: 	in std_logic;
		
		done		:	out std_logic
	);
end primeRange;

architecture Behavioral of primeRange is

	constant zero : int16_t := (others => '0');

	constant NUM_KERNELS : integer := 5;
	constant fifodepth : integer := NUM_KERNELS;
	type arrayInt16 is array(1 to NUM_KERNELS) of int16_t;
	signal inputQueries : arrayInt16;
	signal outputValues : arrayInt16;
	signal inputReadies : std_logic_vector(1 to NUM_KERNELS);
	signal inputWaiting : std_logic_vector(1 to NUM_KERNELS);
	signal outputReadies : std_logic_vector(1 to NUM_KERNELS);
	signal outputAcks : std_logic_vector(1 to NUM_KERNELS);

	signal fifoCount : integer; 
	signal processDone : std_logic; 
	
	type stateType is (idle, active, finished);
	signal curState : stateType;
begin
	genKernels: for i in 1 to NUM_KERNELS generate
		kernel:
			entity prime.Prime(Behavioral) port map
			(clock, reset, inputQueries(i), inputReadies(i), inputWaiting(i), outputValues(i), outputReadies(i), outputAcks(i));
		end generate;

	-- arbitration process
	process (clock, reset) is
		variable startQ, endQ, current : int16_t;
		variable saving : boolean; -- can only store one result per clock cycle
		begin
			if reset = '1' then
				inputReadies <= (others => '0');
				outputAcks <= (others => '0');
				startQ := (others => '0');
				endQ := (others => '0');
				processDone <= '0';
			elsif rising_edge(clock) then
				case curState is 
					when idle =>
						inputReadies <= (others => '0');
						outputAcks <= (others => '0');
						startQ := startQuery;
						endQ := endQuery;
						current := startQuery;
						processDone <= '0';

					when active =>
						-- find available kernel
						saving := false;
						for i in 1 to NUM_KERNELS loop
							-- do not assign if all have been assigned
							if processDone = '0' then
								if inputWaiting(i) = '1' then
									-- kernel available
									inputQueries(i) <= current;
									current := current + to_signed(1, 16);
									inputReadies(i) <= '1';
								else
									inputReadies(i) <= '0';
									-- check if output is ready
									if not saving then
										if outputReadies(i) = '1' then -- result is ready
											fifoStore <= '1';
											fifoValue <= outputValues(i);
											saving := true;
										end if;
									end if;
								end if;
							end if;
						end loop;
						if current = endQuery then
							processDone <= '1';
						end if;
					when finished =>
				end case; 
			end if;
	end process;

	-- state proces
	process (clock, reset) is
		begin
			if reset = '1' then
				curState <= idle;
			-- main state machine
			elsif rising_edge(clock) then 
				case curState is
					when idle =>
						if inputReady = '1' then
							curState <= active;
						end if;
					when active =>
						if processDone = '1' then
							curState <= finished;
						end if;
					when finished =>
						if fifoCount = 0 then
							curState <= idle;
						end if;
				end case;
			end if;
	end process;


end Behavioral;
