----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:09:42 08/13/2018 
-- Design Name: 
-- Module Name:    localFIFO - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity localFIFO is
	generic ( 
		width				: integer;
		depth				: integer
	);
	port (
		clk				: in std_logic;
		reset 			: in std_logic;
		
		dataIn			: in std_logic_vector(width-1 downto 0);
		dataInValid		: in std_logic;
		
		dataOut			: out std_logic_vector(width-1 downto 0);
		dataOutRequest	: in std_logic;
		
		empty				: out std_logic;
		full 				: out std_logic;

		count_out			: out integer range 0 to depth
	);
end localFIFO;

architecture Behavioral of localFIFO is
	type memory is array(0 to depth-1) of std_logic_vector(dataIn'range);
	signal mem_s : memory;
	signal head_s, tail_s : integer;
	
	signal count_s : integer range 0 to depth;

	type dataOutState is (waiting, queueing, switching);
	signal currentDataOutState : dataOutState := waiting;
begin

	count_out <= count_s;

	process (clk, reset) is 
		variable mem : memory;
		variable head : integer range 0 to depth - 1;
		variable tail : integer range 0 to depth - 1;
		variable full_v, empty_v : boolean;

		variable count : integer range 0 to depth;
	begin
		if reset = '1' then 
			mem := (others => (others => '0'));
			head := 0;
			tail := 0;
			empty_v := false;
			full_v := false;
			
			count := 0;
		
			currentDataOutState <= waiting;
		elsif falling_edge(clk) then
			if dataInValid = '1' then
				if full_v = false then
					mem(head) := dataIn;
					count := count + 1;
					
					-- push head forward or wrap around
					if head = depth - 1 then
						head := 0;
					else
						head := head + 1;
					end if;
					
				end if;
			end if;
			
			case currentDataOutState is
			-- wait for request to change to next
			when waiting =>
				if dataOutRequest = '1' then
					currentDataOutState <= queueing;
				end if;
			-- wait for current byte to finish being read
			when queueing =>
				if dataOutRequest = '0' then
					if empty_v = false then
					if tail = depth - 1 then
						tail := 0;
					else
						tail := tail + 1;
					end if;
					count := count - 1;
				end if;
				currentDataOutState <= waiting;
				--currentDataOutState <= switching;
				end if;
			-- change tail to point to next value
			when switching =>
				-- obsolete
				currentDataOutState <= waiting;
			when others =>
			end case;
			
			full_v := count = depth;
			empty_v := count = 0;
			
			-- outputs
			if empty_v then
				empty <= '1';
			else 
				empty <= '0';
			end if;
			if full_v then
				full <= '1';
			else 
				full <= '0';
			end if;
			
			-- debug outs
			mem_s <= mem;
			head_s <= head;
			tail_s <= tail;
			count_s <= count;
			if not empty_v then
				dataOut <= mem(tail);
			else
				dataOut <= (others => '1');
			end if;
		end if;
	end process;



end Behavioral;

