----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:00:45 12/20/2016 
-- Design Name: 
-- Module Name:    vector_dotproduct - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;


entity firSkeleton is
	generic (
		clk_divider : integer := 5000000
		);
	port (
		-- control interface
		clock				: in std_logic;
		reset				: in std_logic; -- controls functionality (sleep)
		busy				: out std_logic; -- done with entire calculation
				
		-- indicate new data or request
		rd					: in std_logic;	-- request a variable
		wr 				: in std_logic; 	-- request changing a variable
		
		-- data interface
		data_in			: in uint8_t; -- std_logic_vector(31 downto 0);
		address_in		: in uint16_t;
		data_out			: out uint8_t; -- std_logic_vector(31 downto 0)
		
		calculate_out	: out std_logic;
		debug				: out uint8_t
	);
end firSkeleton;

architecture Behavioral of firSkeleton is

	signal input				: signed(b-1 downto 0);
	signal output				: signed(b*2-1 downto 0);
	
	signal half_clock			: std_logic := '0';
	signal data_clock			: std_logic;
	signal busy_signal		: std_logic;
begin
	calculate_out <= calculate;
	
-- half the clock
process (reset, clock) is
	variable val : std_logic := '0';
	variable counter : integer range 0 to clk_divider := 0;-- slow down to 5 Hz from 50 MHz: 50M/2 /5 = 5M
begin
	if reset = '1' then
		val := '0';
		half_clock <= '0';
		counter := 0;
	elsif rising_edge(clock) then
		counter := counter + 1;
		if counter = clk_divider then
			counter := 0;
			val := not val;
			half_clock <= val;
		end if;
	end if;
end process;
			

filter: entity fir(Behavioral)
	port map (reset, data_clock, input, output); -- done wired to busy
		
	busy <= busy_signal;

	-- process data receive 
	process (clock, rd, wr, reset)
	begin
		
		if reset = '1' then
			data_out <= (others => '0');
			calculate <= '0';
			run_counter <= (others => '0');
			-- done <= '0';
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
							input(b-1 downto 8) <= data_in(maxWidth-1 downto 0);
						when 1 =>
							input(7 downto 0) <= data_in(maxWidth-1 downto 0);
						when 1 =>
							wanted(maxWidth-1 downto 0) <= data_in(maxWidth-1 downto 0);
						when 2 => 
							learn <= data_in(0);
						-- when 107 =>
							calculate  <= '1'; -- queue calculate to happen
							run_counter <= run_counter + to_unsigned(1, run_counter'length);
						when 3 =>
							calculate <= '0'; -- starts calculation
						when others =>
						end case;
					elsif rd = '0' then
						-- calculate <= '0';
						case to_integer(address_in) is
						-- inputA
						-- row 1
						when 0 =>
							data_out(maxWidth-1 downto 0) <= connections_in(maxWidth-1 downto 0);
						when 1 =>
							data_out(maxWidth-1 downto 0) <= wanted(maxWidth-1 downto 0);
						when 2 => 
							data_out <= (others => '0');
							data_out(0) <= learn;
							data_out(1) <= data_rdy;
							data_out(2) <= busy_signal;
							data_out(3) <= calculate;
							data_out(4) <= half_clock;
						when 3 =>
							data_out(maxWidth-1 downto 0) <= connections_out(maxWidth-1 downto 0);
	
						when 200 => 
							data_out <= run_counter;
						when 255 =>
							data_out <= address_in(15 downto 8);
						when others =>
							data_out <= address_in(7 downto 0);
						end case;
					end if;
				end if;
			end if;
		end if;
		-- intermediate_result_out <= intermediate_result;
	end process;
end Behavioral;

