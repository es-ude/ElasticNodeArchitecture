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

use work.firPackage.all;

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
		wr 					: in std_logic; 	-- request changing a variable 
		
		-- data interface 
		data_in				: in uint8_t;
		address_in			: in uint16_t; 
		data_out			: out uint8_t;

		-- unused spi interface
		flash_available		: 	in std_logic;
		spi_cs				:	out std_logic := '1';
		spi_clk				:	out std_logic := '0';
		spi_mosi			:	out std_logic := '0';
		spi_miso			:	in std_logic
	);
	end FirWishboneSkeleton;

architecture Behavioral of FirWishboneSkeleton is

constant FIR_ID 		: uint8_t := x"BB";


-- convert 
signal addressVector : std_logic_vector(address_in'length-1 downto 0);
signal invertClock, half_clock : std_logic;
-- 16-bit interface
signal hwfStb, stb, writeEnable : std_logic;
signal hwfAddressIn, hwfAddress : std_logic_vector(addressWidth-1 downto 0);
signal hwfDataIn : int16_t;
signal hwfDataOut : int32_t;

-- fifo
type fifoStateType is (idle, newvalue, request, store);
signal fifoState : fifoStateType;
signal fifoStb, fifoDataValid, fifoDataRequest, fifoEmpty, fifoFull : std_logic;
signal fifoDataOut : std_logic_vector(31 downto 0);
signal fifoDataIn : std_logic_vector(31 downto 0);
signal fifoAddress : std_logic_vector(hwfAddress'range);

signal fifoCount : integer range 0 to fifoDepth;
signal fifoCountVector : uint8_t := (others => '0');

begin
	-- half the clock
process (reset, clock) is
	variable val : std_logic := '0';
begin
	if rising_edge(clock) then
		val := not val;
		half_clock <= val;
	end if;
end process;
			

	hwf: entity work.firWishbone PORT MAP(
		invertClock, reset, writeEnable, stb, hwfAddress, hwfDataIn, hwfDataOut
	);
	hwfAddress <= fifoAddress when fifoDataRequest = '1' else hwfAddressIn;
	stb <= hwfStb or fifoStb;

	invertClock <= not half_clock;

	-- allocate static relays to hwf interface
	addressVector <= std_logic_vector(address_in);
	
	-- main data io process
	process (clock, rd, wr, reset) 
		variable newDataIn : boolean := false;
	begin 
		
		if reset = '1' then 
			newDataIn := false;
			writeEnable <= '0';
			hwfStb <= '0';
		else 
		-- beginning/end 
			if rising_edge(clock) then 
				-- process address of written value 
				if wr = '0' or rd = '0' then 
					-- incoming data of some description
					writeEnable <= not wr;

					-- convert 8-bit address to 16-bit required by hwf
					hwfAddressIn <= addressVector(hwfAddressIn'length-1+1 downto 1);


					-- variable being set 
					-- reverse from big to little endian 
					if wr = '0' then 
						case addressVector(0) is
 						when '0' =>
							hwfDataIn(7 downto 0) <= signed(data_in);
						when '1' =>
							hwfDataIn(15 downto 8) <= signed(data_in);
							if not newDataIn then
								hwfStb <= '1'; -- last byte activates hwf
								newDataIn := true; -- only activate stb for one clock cycle
							else
								hwfStb <= '0';
							end if;

						when others =>
						end case;
					elsif rd = '0' then
						-- convert 8-bit address to 32-bit required by hwf
						hwfAddressIn <= addressVector(hwfAddressIn'length-1+3 downto 3);

						case to_integer(address_in) is
						when 0 =>
							data_out <= unsigned(fifoDataOut(7 downto 0));
						when 1 =>
							data_out <= unsigned(fifoDataOut(15 downto 8));
						when 2 =>
							data_out <= unsigned(fifoDataOut(23 downto 16));
						when 3 =>
							-- request next value from FIFO for next read
							-- only request when at last byte
							--if not newDataIn then
							-- fifo changes to next value when request goes low
							fifoDataRequest <= '1'; -- first byte activates fifo
							--	newDataIn := true; -- only activate stb for one clock cycle
							--else
							--	fifoDataRequest <= '0';
							--end if;
							data_out <= unsigned(fifoDataOut(31 downto 24));
						when 4 => 
							data_out <= fifoCountVector;
						when 255 =>
							data_out <= FIR_ID;
						when others =>
							data_out <= address_in(7 downto 0);
						end case; 
					end if; 
				else
					fifoDataRequest <= '0';
					newDataIn := false;
					hwfStb <= '0';
					writeEnable <= '0';
				end if; 
			end if; 
		end if; 
	end process; 
	
	-- fifo process
	process (reset, half_clock, hwfStb) is
		variable delayStb : std_logic;
	begin
		if reset = '1' then
			delayStb := '0';
			fifoStb <= '0';
			fifoState <= idle;
			fifoDataValid <= '0';

			-- fifoDataRequest <= '0';
		elsif (rising_edge(half_clock)) then
			case fifoState is 

			when idle =>
				if hwfStb = '1' then
					-- only fifo if u being updated
					if hwfAddressIn = u_address then
						fifoState <= newvalue;
					else 
						fifoState <= idle;
					end if;
				end if;
				-- fifoDataRequest <= '0';
				fifoDataValid <= '0';
			when newvalue =>
				fifoState <= request;
			when request =>
				fifoStb <= '1';
				-- fifoDataRequest <= '1';
				fifoAddress <= u_address;
				fifoState <= store;
			when store =>
				--fifoDataRequest <= '1';
				fifoStb <= '0';
				-- fifoDataIn <= std_logic_vector(hwfDataOut);
				fifoDataValid <= '1';
				fifoState <= idle;
			when others =>
			end case;
		end if;
			
	end process;

fifo: entity work.localFIFO(Behavioral) 
	generic map
	(
		width => 2*firWidth, depth => fifoDepth
	)
	port MAP
	(
		half_clock, reset, fifoDataIn, fifoDataValid, fifoDataOut, fifoDataRequest, fifoEmpty, fifoFull, fifoCount
	);
	fifoDataIn <= std_logic_vector(hwfDataOut);
	fifoCountVector <= to_unsigned(fifoCount, fifoCountVector'length);
	
end Behavioral;

