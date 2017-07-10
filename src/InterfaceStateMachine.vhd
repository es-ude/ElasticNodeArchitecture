----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

entity InterfaceStateMachine is
	generic
	(
		control_region		: unsigned(15 downto 0) := x"00ff"
		-- MULTIBOOT			: unsigned(23 downto 0) := x"000000"
	);
	port(
		clk					: in std_logic;							-- clock
		reset					: in std_logic;							-- reset everything
		
		-- icap interface
		icap_address		: out uint24_t_interface;
		
		-- uart interface
		uart_tx				: out uint8_t_interface;
		uart_tx_done		: in std_logic;
		uart_rx				: in uint8_t_interface;
		
		-- sram interface
		sram_address		: in uint16_t;
		sram_data_out		: out uint8_t;
		sram_data_in		: in uint8_t;
		sram_rd				: in std_logic;
		sram_wr				: in std_logic;
		
		-- userlogic interface
		userlogic_reset	: out std_logic;
		userlogic_busy 	: in std_logic;
		userlogic_data_in	: out uint8_t;
		userlogic_address	: out uint16_t;
		userlogic_data_out: in uint8_t;
		userlogic_rd		: out std_logic;
		userlogic_wr		: out std_logic;
		
		leds 					: out std_logic_vector(3 downto 0)
	);
end InterfaceStateMachine;

architecture Behavior of InterfaceStateMachine is 
	constant MULTIBOOT : uint16_t := x"0005";
	constant LED : uint16_t := x"0003";
	constant USERLOGIC_CONTROL : uint16_t := x"0004";
begin
	-- main data receiving process
	process (reset, clk, sram_rd, sram_wr) 
		variable data_var : std_logic_vector(7 downto 0);
		variable wr_was_low : boolean := false;
	begin
		if reset = '1' then
			icap_address.ready <= '0';
			leds <= (others => '0');
			sram_data_out <= (others => '0');
			userlogic_reset <= '1';
			userlogic_rd <= '1';
			userlogic_wr <= '1';
		else
			if rising_edge(clk) then
				if sram_rd = '0' or sram_wr = '0' then -- or wr_was_low then
					-- writing to an address
					-- only respond when sram_wr goes high again
					if sram_wr = '0' then
--						wr_was_low := true;
--					elsif wr_was_low then
--						wr_was_low := false; -- respond only once
						
						-- control region
						if sram_address <= control_region then
							-- icap
							case sram_address is
							when MULTIBOOT =>
								icap_address.data(7 downto 0) <= sram_data_in;
							when MULTIBOOT + 1 =>
								icap_address.data(15 downto 8) <= sram_data_in;
							when MULTIBOOT + 2 =>
								icap_address.data(23 downto 16) <= sram_data_in;
								icap_address.ready <= '1'; -- will go low automatically when done with multiboot
							when LED =>
								data_var := std_logic_vector(sram_data_in);
								leds <= data_var(3 downto 0);
							when USERLOGIC_CONTROL =>
								data_var := std_logic_vector(sram_data_in);
								userlogic_reset <= data_var(0);
							when others =>
							end case;
						-- data region
							userlogic_wr <= '1';
						else
							userlogic_wr <= '0';
							-- userlogic_address <= sram_address - control_region - 1;
							userlogic_data_in <= sram_data_in;
						end if;
					-- otherwise reading
					else
						-- control region
						if sram_address <= control_region then
							sram_data_out <= sram_address(7 downto 0);
						-- data region
							userlogic_rd <= '1';
						else
							-- userlogic_address <= sram_address - control_region - 1;
							sram_data_out <= userlogic_data_out;
							userlogic_rd <= '0'; -- need rd to be low for at least 2 clk
						end if;
					end if;
				else
					userlogic_rd <= '1';
					userlogic_wr <= '1';
				end if;
			end if;
		end if;
	end process;
end Behavior;




