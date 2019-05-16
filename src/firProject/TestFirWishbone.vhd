-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library work;
use work.all;
use work.firPackage.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.UserLogicInterface.all;

ENTITY TestFirWishBone IS
END TestFirWishBone;

ARCHITECTURE behavior OF TestFirWishBone IS 

	signal clk, reset, writeEnable, stb, ready : std_logic := '0';
	signal datain : int16_t;
	signal dataout : int32_t;
	signal addressIn : std_logic_vector(addressWidth-1 downto 0);
	signal finish : boolean := false;
	constant cycle : time := 10ns;

	BEGIN
	-- Component Instantiation
	uut: entity work.firWishbone PORT MAP(
		clk, reset, writeEnable, stb, ready, addressIn, datain, dataout
	);

		
clkProcess : PROCESS
	BEGIN
		if finish = false then
			clk <= '1';
			wait for cycle/2;
			clk <= '0';
			wait for cycle/2;
		else
			wait;
		end if;
	END PROCESS clkProcess;

--  Test Bench Statements
tb : PROCESS
	BEGIN

		wait for cycle; -- wait until global set/reset completes
		reset <= '1';
		wait for cycle * 2;
		reset <= '0';
		
		wait for cycle*2;
		wait for cycle/2;
--		-- input 0
--		datain <= to_signed(0, datain'length);
		addressIn <= (others => '0');
		writeEnable <= '1';
--		stb <= '1';
--		wait for cycle;
--		stb <= '0';
--		wait for cycle *2;

		-- input 1000
		stb <= '1';
		datain <= to_signed(1, datain'length);
		wait for cycle;
		stb <= '0';
		wait until ready = '1';
		wait for cycle;
		writeEnable <= '0';
		stb <= '1';
		wait for cycle;	
		stb <= '0';
		assert dataOut = to_signed(59, 16);
		wait for cycle;	


		-- input 0
		writeEnable <= '1';
   		stb <= '1';
		datain <= to_signed(0, datain'length);
		wait for cycle;
		writeEnable <= '0';
		stb <= '0';
		wait until ready = '1';
	    wait for cycle;
		writeEnable <= '0';
		stb <= '1';
		wait for cycle;	
		stb <= '0';
		assert dataOut = to_signed(179, 16);
		wait for cycle;	
		
		
		-- long input 0
       writeEnable <= '1';
       stb <= '1';
       wait for cycle;
       stb <= '0';
       writeEnable <= '0';
  		wait until ready = '1';
       stb <= '1';
       wait for cycle;
       assert dataOut = to_signed(492, 16);
       stb <= '0';
    
       writeEnable <= '1';
       stb <= '1';
       wait for cycle;
       stb <= '0';
       writeEnable <= '0';
  		wait until ready = '1';
       stb <= '1';
       wait for cycle;
       assert dataOut = to_signed(829, 16);
       stb <= '0';
    
       writeEnable <= '1';
       stb <= '1';
       wait for cycle;
       stb <= '0';
   		wait until ready = '1';
      writeEnable <= '0';
       stb <= '1';
       wait for cycle;
       assert dataOut = to_signed(974, 16);
       stb <= '0';
    
       writeEnable <= '1';
       stb <= '1';
       wait for cycle;
       stb <= '0';
       writeEnable <= '0';
  		wait until ready = '1';
       stb <= '1';
       wait for cycle;
       assert dataOut = to_signed(829, 16);
       stb <= '0';
    
       writeEnable <= '1';
       stb <= '1';
       wait for cycle;
       stb <= '0';
       writeEnable <= '0';
  		wait until ready = '1';
       stb <= '1';
       wait for cycle;
       assert dataOut = to_signed(492, 16);
       stb <= '0';        

       writeEnable <= '1';
       stb <= '1';
       wait for cycle;
       stb <= '0';
       writeEnable <= '0';
       stb <= '1';
       wait for cycle;
       assert dataOut = to_signed(179, 16);
       stb <= '0';
        
       writeEnable <= '1';
       stb <= '1';
       wait for cycle;
       stb <= '0';
       writeEnable <= '0';
 		wait until ready = '1';
       stb <= '1';
       wait for cycle;
       assert dataOut = to_signed(59, 16);
       stb <= '0'; 
        
       writeEnable <= '1';
       stb <= '1';
       wait for cycle;
       stb <= '0';
       writeEnable <= '0';
       wait until ready = '1';
       stb <= '1';
       wait for cycle;
       assert dataOut = to_signed(0, 16);
       stb <= '0';  
        
           
		-- done
		stb <= '0';
		writeEnable <= '0';
		wait for cycle*4;

		finish <= true;

		wait; -- will wait forever
	END PROCESS tb;
--  End Test Bench 

END;
