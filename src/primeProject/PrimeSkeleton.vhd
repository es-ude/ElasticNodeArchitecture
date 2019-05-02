
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
 
library work; 
use work.MatrixMultiplicationPackage.all; 
 
 
entity PrimeSkeleton is 
	port ( 
		-- control interface 
		clock			: in std_logic; 
		reset			: in std_logic; -- controls functionality (sleep) 
		busy			: out std_logic; 
		-- done 		: out std_logic; -- done with entire calculation 
				
		-- indicate new data or request 
		rd				: in std_logic;	-- request a variable 
		wr 				: in std_logic; 	-- request changing a variable 
		
		-- data interface 
		data_in			: in uint8_t; -- std_logic_vector(31 downto 0); 
		address_in		: in uint16_t; 
		data_out		: out uint8_t -- ; -- std_logic_vector(31 downto 0) 
	); 
end PrimeSkeleton; 
 
architecture Behavioral of PrimeSkeleton is 


	constant PR_ID : uint8_t := x"CA";
begin 
 
	
prime: entity work.PrimeRange(Behavioral) 
	port map (clock, reset, startQuery, endQuery, inputQuery, outputValue, outputReady, outputAck); 
	
	busy <= busy_s; 
	--calculate_out <= calculate; 
	
	-- process data receive  
	process (clock, rd, wr, reset) 
	begin 
		
		if reset = '1' then 
			data_out <= (others => '0'); 
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
							startQuery(7 downto 0) <= data_in;
						when 1 =>
							startQuery(15 downto 8) <= data_in;
 						when 2 =>
							endQuery(7 downto 0) <= data_in;
						when 3 =>
							endQuery(15 downto 8) <= data_in;
						when 4 =>
							inputReady <= data_in(0);
							-- inputReady <= data_in(1);
							outputAck <= data_in(3);
						when 107 =>
						when others =>
						end case;
					elsif rd = '0' then
						calculate <= '0';
						case to_integer(address_in) is
						when 0 =>
							data_out <= startQuery(7 downto 0);
						when 1 =>
							data_out <= startQuery(15 downto 8);
						when 2 =>
							data_out <= endQuery(7 downto 0);
						when 3 =>
							data_out <= endQuery(15 downto 8);
						when 4 =>
							data_out(0) <= inputReady;
							data_out(1) <= outputReady;
							data_out(2) <= done;
						when 5 =>
							data_out <= outputValue(7 downto 0);
						when 3 =>
							data_out <= outputValue(15 downto 8); 
						when 255 =>
							data_out <= PR_ID;
						when others =>

						end case; 
					else 
					end if; 
				end if; 
			end if; 
		end if; 
		-- intermediate_result_out <= intermediate_result; 
	end process; 
end Behavioral; 
 
