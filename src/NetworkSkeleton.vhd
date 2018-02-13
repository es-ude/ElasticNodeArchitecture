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

library neuralnetwork;
use neuralnetwork.all;
use neuralnetwork.common.all;


entity NetworkSkeleton is
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
end NetworkSkeleton;

architecture Behavioral of NetworkSkeleton is

	signal learn			:  std_logic;
	signal data_rdy			:  std_logic;
	signal calculate		:  std_logic;
	
	signal connections_in	:  fixed_point_vector;
	signal connections_in_uintw : uintw_t;
	signal wanted				:  fixed_point_vector;
	signal wanted_uintw		:  uintw_t := (others => '1');
	signal connections_out	:  fixed_point_vector;
	signal connections_out_uintw : uintw_t;
	signal run_counter		:  uint8_t;
	
	signal half_clock			: std_logic := '0';
	signal busy_signal		: std_logic;
	
	signal address_s : uint16_t;
	signal index_s : uint16_t;
	signal fp_s : fixed_point;
		
	component FixedPoint_Logic is
		Port (
			fixed_point		:	in fixed_point_vector;
			std_logic_vec	: 	out uintw_t;
			clk			:	in std_logic
		);
	end component;

	component Logic_FixedPoint is
		Port (
			fixed_point		:	out fixed_point_vector;
			std_logic_vec	: 	in uintw_t;
			clk			:	in std_logic
		);
	end component;

begin

lfp: Logic_FixedPoint port map
(
    connections_in, connections_in_uintw, clock
);
lfpw: Logic_FixedPoint port map
(
    wanted, wanted_uintw, clock
);
fpl: FixedPoint_Logic port map
(
	connections_out, connections_out_uintw, clock
);


	calculate_out <= calculate;
	
-- half the clock
--process (reset, clock) is
--	variable val : std_logic := '0';
--	variable counter : integer range 0 to clk_divider := 0;-- slow down to 5 Hz from 50 MHz: 50M/2 /5 = 5M
--begin
--	if reset = '1' then
--		val := '0';
--		counter := 0;
--	elsif rising_edge(clock) then
--		counter := counter + 1;
--		if counter = clk_divider then
--			counter := 0;
--			val := not val;
--			-- half_clock <= val;
--		end if;
--	end if;
--end process;

clockprocess: process(clock) is
begin
	if rising_edge(clock) then
			half_clock <= not half_clock;
	end if;
end process;

nn: entity neuralnetwork.Network(Behavioral)
	port map (half_clock, reset, learn, data_rdy, busy_signal, calculate, connections_in, connections_out, wanted, debug); -- done wired to busy
	busy <= busy_signal;

	-- process data receive 
	process (clock, rd, wr, reset)
		variable address : uint16_t;
		variable index : uint16_t;
		variable fp : fixed_point;
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
				
				-- calculate <= '0'; -- set to not calculate (can be overwritten below)
				
				if wr = '0' or rd = '0' then
					-- variable being set
					-- reverse from big to little endian
					if wr = '0' then
						case to_integer(address_in) is
						
						when 0 =>
							connections_in_uintw(w-1 downto 0) <= data_in(w-1 downto 0);
						when 1 =>
							wanted_uintw(w-1 downto 0) <= data_in(w-1 downto 0);
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
							data_out(w-1 downto 0) <= connections_in_uintw(w-1 downto 0);
						when 1 =>
							data_out(w-1 downto 0) <= wanted_uintw(w-1 downto 0);
						when 2 => 
							data_out <= (others => '0');
							data_out(0) <= learn;
							data_out(1) <= data_rdy;
							data_out(2) <= busy_signal;
							data_out(3) <= calculate;
							data_out(4) <= half_clock;
						when 3 =>
							data_out(w-1 downto 0) <= connections_out_uintw(w-1 downto 0);
	
						when 200 => 
							data_out <= run_counter;
--						when 255 =>
--							data_out <= address_in(15 downto 8);
						when others =>
							address := (address_in - to_unsigned(256, address_in'length));
							index := address / 2;
							fp := connections_out(to_integer(index));
							
							address_s <= address;
							index_s <= index;
							fp_s <= fp;

							-- if odd
							if address(0) = '1' then
								data_out <= unsigned(fp(7 downto 0));
							else
								data_out <= unsigned(fp(15 downto 8));
							end if;
							-- data_out <= address_in(7 downto 0);
						end case;
--					else
--						calculate <= '0';
					end if;
				end if;
			end if;
		end if;
		-- intermediate_result_out <= intermediate_result;
	end process;

	
	-- ready <= '1' when enable = '1' and current_receive_state = receiveN else '0';
	-- calculate <= '1' when current_receive_state = calculating else '0';
end Behavioral;

