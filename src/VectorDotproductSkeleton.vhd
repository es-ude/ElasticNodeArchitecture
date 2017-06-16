----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:39:26 03/15/2017 
-- Design Name: 
-- Module Name:    VectorDotproductSkeleton - Behavioral 
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

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VectorDotproductSkeleton is
port (
		-- control interface
		clock				: in std_logic;
		reset				: in std_logic; -- controls functionality (sleep)
		
		-- run				: in std_logic; -- indicates the beginning and end
		done 				: out std_logic; -- done with entire calculation
		
		-- indicate new data or request
		rd					: in std_logic;	-- request a variable
		wr 				: in std_logic; 	-- request changing a variable
		
		-- data interface
		data_in			: in uint8_t; -- std_logic_vector(31 downto 0);
		address_in		: in uint16_t;
		data_out			: out uint8_t -- std_logic_vector(31 downto 0)
		);
end VectorDotproductSkeleton;

architecture Behavioral of VectorDotproductSkeleton is
	-- internal variables
	-- constant OUTPUT_SIZE : unsigned := to_unsigned(4, 32);
	
	-- interfacing variables
	signal vectorA, vectorB, result : uint32_t;
	signal width : uint32_t;
	signal calculate : std_logic;
	
	-- debug
	signal current_dimension_s : uint32_t;
begin

	-- done <= '1' when result = x"0ABCD000" else '0';
	-- done <= '1' when address_in = x"0003" else '0';

-- userlogic instantiate
vdp: entity work.VectorDotproduct(Behavioral)
	port map (clock, reset, calculate, vectorA, vectorB, result);

	-- process data receive 
	process (clock, rd, wr, reset)
		variable inputA, inputB : uint16_t;
		variable vector_width, current_dimension : uint32_t := (others => '0');
	begin
		current_dimension_s <= current_dimension;
		if reset = '1' then
			data_out <= (others => '0');
			current_dimension := (others => '0');
			calculate <= '0';
			-- done <= '0';
		else
		-- beginning/end
			if rising_edge(clock) then
				-- process address of written value
				
				calculate <= '0'; -- set to not calculate (can be overwritten below)
				
				-- variable being set
				-- reverse from big to little endian
				if wr = '0' then
					case to_integer(address_in) is
					-- vector_width
					when 0 =>
						width(7 downto 0) <= data_in;
						-- done <= '0'; -- recognise this as a new sum
					when 1 =>
						width(15 downto 8) <= data_in;
					when 2 =>
						width(23 downto 16) <= data_in;
					when 3 =>
						width(31 downto 24) <= data_in;
					-- inputA
					when 4 =>
						vectorA(7 downto 0) <= data_in;
					when 5 =>
						vectorA(15 downto 8) <= data_in;
					when 6 =>
						vectorA(23 downto 16) <= data_in;
					when 7 =>
						vectorA(31 downto 24) <= data_in;
					-- inputB
					when 8 =>
						vectorB(7 downto 0) <= data_in;
					when 9 =>
						vectorB(15 downto 8) <= data_in;
					when 10 =>
						vectorB(23 downto 16) <= data_in;
					when 11 =>
						vectorB(31 downto 24) <= data_in;
				
						-- do not calculate, unless accessing vectorB
						calculate  <= '1'; -- trigger calculate high for one clock cycle
						current_dimension := current_dimension + 1;
						if current_dimension >= width then
							-- done <= '1';
							current_dimension := (others => '0');
						end if;
					--when 16 => 
					--	calculate <= '0';
					when others =>
					end case;
				elsif rd = '0' then
					calculate <= '0';
					case to_integer(address_in) is
					-- vector_width
					when 0 =>
						data_out <= width(7 downto 0);
					when 1 =>
						data_out <= width(15 downto 8);
					when 2 =>
						data_out <= width(23 downto 16);
					when 3 =>
						data_out <= width(31 downto 24);
					-- inputA
					when 4 =>
						data_out <= vectorA(7 downto 0);
					when 5 =>
						data_out <= vectorA(15 downto 8);
					when 6 =>
						data_out <= vectorA(23 downto 16);
					when 7 =>
						data_out <= vectorA(31 downto 24);
					-- inputB
					when 8 =>
						data_out <= vectorB(7 downto 0);
					when 9 =>
						data_out <= vectorB(15 downto 8);
					when 10 =>
						data_out <= vectorB(23 downto 16);
					when 11 =>
						data_out <= vectorB(31 downto 24);
						
					-- result
					when 12 =>
						data_out <= result(7 downto 0);
					when 13 =>
						data_out <= result(15 downto 8);
					when 14 =>
						data_out <= result(23 downto 16);
					when 15 =>
						data_out <= result(31 downto 24);
					when others =>
						data_out <= address_in(7 downto 0) + address_in(15 downto 8);
					end case;
				else
					calculate <= '0';
				end if;

			end if;
		end if;
		-- intermediate_result_out <= intermediate_result;
	end process;
	
	
end Behavioral;

