library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

entity KeyboardSkeleton is
generic
(
	PRESCALER	: integer := 1024
);
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
		data_in			: in uint8_t;
		address_in		: in uint16_t;
		data_out			: out uint8_t;
		
		-- direct external connections
		leds				: out kb_led_vector
		);
end KeyboardSkeleton;

architecture Behavioral of KeyboardSkeleton is
	-- interfacing variables
	signal rgb_values		: kb_rgb_value := (others => (others => (others => '0')));
	signal leds_internal	: kb_rgb_led;
	signal calculate 		: std_logic;
begin

dec: entity work.KeyboardRgbLedDecoder(Behavioral)
	port map (leds, leds_internal);

-- userlogic instantiate
kb: entity work.Keyboard(Behavioral)
	generic map (PRESCALER)
	port map (clock, reset, rgb_values, leds_internal);

	-- process data receive 
	process (clock, rd, wr, reset)
	begin
		if reset = '1' then
			done <= '0';
		else
		-- beginning/end
			if rising_edge(clock) then
				-- variable being set
				-- reverse from big to little endian
				if wr = '0' then
					-- process address of written value
					case to_integer(address_in) is
					-- led key 1
					when 0 =>
						rgb_values(0)(0) <= data_in;
						done <= '0';
					when 1 =>
						rgb_values(0)(1) <= data_in;
						done <= '0';
					when 2 =>
						rgb_values(0)(2) <= data_in;
						done <= '1';
--					-- led key 2
--					when 3 =>
--						rgb_values(1)(0) <= data_in;
--					when 4 =>
--						rgb_values(1)(1) <= data_in;
--					when 5 =>
--						rgb_values(1)(2) <= data_in;
--					-- led key 3
--					when 6 =>
--						rgb_values(2)(0) <= data_in;
--					when 7 =>
--						rgb_values(2)(1) <= data_in;
--					when 8 =>
--						rgb_values(2)(2) <= data_in;
					when others =>
					end case;
						
				elsif rd = '0' then
					calculate <= '0';
					
					-- process address of written value
					case to_integer(address_in) is
					-- led key 1
					when 0 =>
						data_out <= rgb_values(0)(0);
					when 1 =>
						data_out <= rgb_values(0)(1);
					when 2 =>
						data_out <= rgb_values(0)(2);
					-- led key 2
--					when 3 =>
--						data_out <= rgb_values(1)(0);
--					when 4 =>
--						data_out <= rgb_values(1)(1);
--					when 5 =>
--						data_out <= rgb_values(1)(2);
--					-- led key 3
--					when 6 =>
--						rgb_values(2)(0) <= data_in;
--					when 7 =>
--						rgb_values(2)(1) <= data_in;
--					when 8 =>
--						rgb_values(2)(2) <= data_in;
					when others =>
					end case;
				else
					calculate <= '0';
				end if;
			end if;
		end if;
	end process;
	

	
end Behavioral;

