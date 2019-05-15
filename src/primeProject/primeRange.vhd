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
--use UNISIM.VComponents.all;\
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
	signal dones : std_logic_vector(1 to NUM_KERNELS);
	constant all_done : std_logic_vector(1 to NUM_KERNELS) := (others => '1');

	-- signal fifoCount : integer;
	signal fifoEmpty, fifoFull, fifoDataInValid, fifoDataOutRequest : std_logic; 
	signal fifoDataIn, fifoDataOut : std_logic_vector(15 downto 0);
	signal processDone : std_logic; 

	signal currentSignal : int16_t;
	
	type stateType is (idle, active, finished);
	signal curState : stateType;

	signal invert_clock : std_logic;
begin
	invert_clock <= not clock;
	outputReady <= not fifoEmpty;
	fifoDataOutRequest <= outputAck;
	outputValue <= signed(fifoDataOut);

	genKernels: for i in 1 to NUM_KERNELS generate
		kernel:
			entity prime.Prime(Behavioral) port map
			(invert_clock, reset, inputQueries(i), inputReadies(i), inputWaiting(i), outputValues(i), outputReadies(i), outputAcks(i), dones(i));
		end generate;

fifo: entity work.localFIFO(behavioral)
		generic map (16, fifodepth)
		port map (invert_clock, reset, fifoDataIn, fifoDataInValid, fifoDataOut, fifoDataOutRequest, fifoEmpty, fifoFull);

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
				fifoDataIn <= (others => '0');
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
									if current < endQ then 
										-- kernel available
										inputQueries(i) <= current;
										current := current + to_signed(1, 16);
										inputReadies(i) <= '1';
										-- outputAcks(i) <= '0';
									end if;
								else
									inputReadies(i) <= '0';
								end if;
							else
								inputReadies(i) <= '0';
							end if;
							
							
							-- check if output is ready
							if not saving then
								-- result is ready
								if (outputReadies(i) = '1') then 
									if (outputValues(i) /= zero) then
										-- space in fifo?
										if fifoFull /= '1' then
											fifoDataInValid <= '1';
											fifoDataIn <= std_logic_vector(outputValues(i));
											saving := true;
											outputAcks(i) <= '1';
										else
											outputAcks(i) <= '0';
										end if;
									else
										-- nothing to save
										outputAcks(i) <= '1';
									end if;
								else
									outputAcks(i) <= '0';
									fifoDataInValid <= '0';
								end if;
							else
								outputAcks(i) <= '0';
								-- fifoDataInValid <= '0';
							end if;
							-- else
							-- 	outputAcks(i) <= '0';
							-- end if;
						end loop;
						if current = endQuery then
							processDone <= '1';
						end if;
					when finished =>
				end case; 
				currentSignal <= current;
			end if;
	end process;

	-- state proces
	process (clock, reset) is
		begin
			if reset = '1' then
				curState <= idle;
				done <= '0';
			-- main state machine
			elsif rising_edge(clock) then 
				case curState is
					when idle =>
						if inputReady = '1' then
							curState <= active;
							done <= '0';
						end if;
					when active =>
						-- if no more to do and all kernels inactive
						if processDone = '1' and inputWaiting = all_done then
							curState <= finished;
						end if;
					when finished =>
						if fifoEmpty = '1' then
							curState <= idle;
							done <= '1';
						end if;
				end case;
			end if;
	end process;


end Behavioral;
