----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:20:16 07/27/2015 
-- Design Name: 
-- Module Name:    Network - Behavioral 
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

library neuralnetwork;
use neuralnetwork.Common.all;

library fpgamiddlewarelibs;
use fpgamiddlewarelibs.userlogicinterface.all;

--library ieee_proposed;
--use ieee_proposed.fixed_float_types.all;
--use ieee_proposed.fixed_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity SignedANN is
	generic (
        sram_addr_width : integer := hw_sram_addr_width;
        sram_data_width : integer := hw_sram_data_width
    );
	port (
			clk					: 	in std_logic;
			reset				:	in std_logic;
			
			learn				:	in std_logic;
			data_rdy			:	out std_logic := '0';
			busy				:  	out std_logic;
        	calculate      		:   in std_logic;
            
			connections_in		:	in uintw_t;
			connections_out		:	out uintw_t := (others => '0');

			--errors_in			:	in fixed_point_vector;
			wanted				:	in uintw_t;

			reset_weights 		:	in std_logic;
			sram_address		:	in uint24_t;
			load_weights		:	in std_logic;
			store_weights		:	in std_logic;
			flash_ready			:	out std_logic;

			ext_sram_addr                : out std_logic_vector(sram_addr_width-1 downto 0);
		    ext_sram_data                : inout std_logic_vector(hw_sram_data_width-1 downto 0);
			ext_sram_output_enable       : out std_logic;
            ext_sram_write_enable        : out std_logic;

			--weights_wr_en 		:	in std_logic;
			--weights 			:	inout weights_vector;

         	debug		      	:  	out uint8_t
		);
end SignedANN;

architecture Behavioral of SignedANN is

	--component FixedPoint_Logic is
	--	Port (
	--		fixed_point		:	in fixed_point_vector;
	--		std_logic_vec	: 	out uintw_t;
	--		clk				:	in std_logic
	--	);
	--end component;

	--component Logic_FixedPoint is
	--	Port (
	--		fixed_point		:	out fixed_point_vector;
	--		std_logic_vec	: 	in uintw_t;
	--		clk				:	in std_logic
	--	);
	--end component;

	signal hidden_connections_out_fp : fixed_point_vector;
	--signal connections_out_fp : fixed_point_vector;
	signal err_out 					: fixed_point_vector;
	signal data_rdy_s				: std_logic := '0';
	
	-- signal wanted_fp	: fixed_point_vector;
	--signal conn_in_real	: fixed_point_vector;
	--signal conn_out_real: fixed_point_vector;

	--signal learn		: std_logic := '0';
	signal n_feedback_bus 	: std_logic_vector(totalLayers downto 0) := (others => 'Z');
	signal n_feedback		 	: integer range 0 to 2;
	signal n_feedback_buffered : integer range 0 to 2;
	signal current_layer  	: uint8_t;
	signal current_neuron	: uint8_t;
	
	
	signal connections_in_fp   : fixed_point_vector := (others => real_to_fixed_point(0.0));
	signal wanted_fp           : fixed_point_vector := (others => real_to_fixed_point(0.0));
	signal connections_out_fp  : fixed_point_vector;

	signal error_out : fixed_point;
	signal error_out_abs : fixed_point;

	signal weights_signal : weights_vector;

begin

	ann: entity work.FixedPointANN(Behavioral) port map
	(
		clk	=> clk,
		reset => reset,
		
		learn => learn,
		data_rdy => data_rdy,
		busy => busy,
    	calculate => calculate,
        
		connections_in_fp => connections_in_fp,
		connections_out_fp => connections_out_fp,

		wanted_fp => wanted_fp,

		reset_weights => reset_weights,
		sram_address => sram_address,
		load_weights => load_weights,
		store_weights => store_weights,
		flash_ready => flash_ready,

		-- SRAM interface
        ext_sram_addr => ext_sram_addr,
        ext_sram_data => ext_sram_data,
        ext_sram_output_enable => ext_sram_output_enable,
        ext_sram_write_enable => ext_sram_write_enable,
		
		--weights_wr_en => weights_wr_en,
		--weights => weights_signal,

     	debug => debug
	);

	--weights_signal <= weights when weights_wr_en = '1' else (others => 'Z');

	fpl: entity work.FixedPoint_Logic(Behavioral) port map
	(
	    connections_out_fp, connections_out, clk
	);

	lfp: entity work.Logic_FixedPoint(Behavioral) port map
	(
	    connections_in_fp, connections_in, clk
	);

	lfpw: entity work.Logic_FixedPoint(Behavioral) port map
	(
	    wanted_fp, wanted, clk
	);

end Behavioral;

