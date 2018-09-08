--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- use ieee.math_real.all;
use IEEE.NUMERIC_STD.all;

--library ieee_proposed;
--use ieee_proposed.fixed_float_types.all;
--use ieee_proposed.fixed_pkg.all;

package Common is

function max (A : in natural; B : in natural) return natural;

constant b					:   integer := 16;

subtype fixed_point is signed(b-1 downto 0);
subtype double_fixed_point is signed(b+b-1 downto 0);

constant inputWidth			:	natural := 2;
constant hiddenWidth		: 	natural := 4;
constant outputWidth		: 	natural := 1;
constant maxWidth			: 	natural := max(max(inputWidth, hiddenWidth), outputWidth);

constant numHiddenLayers	:	natural := 2;
constant totalLayers		:	natural := numHiddenLayers + 1;
constant eps				:	natural := 10;
constant factor				:	fixed_point := to_signed(1024, b);
constant factor_shift		:	natural := 10;
constant factor_shift_2		:	natural := 5;
constant factor_2   		:	fixed_point := to_signed(512, b);
constant zero				:	fixed_point := (others => '0');
constant one				:	fixed_point := factor;
constant minValue			:	fixed_point := ('1', others => '0');
constant maxValue			:	fixed_point := ('0', others => '1');
constant init_weight		:	fixed_point := to_signed(128, b);
--constant input_number		:	natural := 0;
--constant output_number		:	natural := 0;

--constant maximum			:	fixed_point := '0' & (others => '1');
--constant minimum			:	fixed_point := x"FE";

subtype uintw_t is unsigned (maxWidth-1 downto 0);
subtype weights_vector is std_logic_vector(b*maxWidth*maxWidth-1 downto 0);-- used for reading/writing ram
subtype conn_vector is std_logic_vector(b*maxWidth-1 downto 0);-- used for reading/writing ram

-- 0 idle 1 feedforward 2 feedback 3 feedback->feedforward 4 done 5 delay 7 waiting 6 intermediate (between forward and back)
type distributor_mode is (idle, feedforward, feedback, doneQuery, doneLearn, delay, waiting, intermediate);

-- subtype fixed_point is integer range -10000 to 10000;
type fixed_point_vector is array (maxWidth-1 downto 0) of fixed_point;
type fixed_point_matrix is array (maxWidth-1 downto 0) of fixed_point_vector;
type fixed_point_array is array (totalLayers-1 downto 0) of fixed_point_vector;
-- cannot synthesize array of fpm, so make it wider instead
type fixed_point_matrix_array is array (totalLayers-1 downto 0, maxWidth-1 downto 0) of fixed_point_vector; -- in total l x w of vectors (each vector is weights in one neuron)
-- type fixed_point_matrix_array is array (totalLayers-1 downto 0) of fixed_point_matrix;


function log2( i : natural) return integer;
--function maximum_probability (signal probs_in : in fixed_point_vector) return fixed_point;
function weighted_sum (signal weights : fixed_point_vector; signal connections : fixed_point_vector; firstHidden : in boolean) return fixed_point;
--function weighted_sum (signal weights : fixed_point_vector; signal connections : uintw_t; firstHidden : in boolean) return fixed_point;
function sum (signal connections : fixed_point_vector; lastHidden : in boolean) return fixed_point;
--function scale (signal weights : fixed_point_vector; const : real) return fixed_point_vector;
function "+" (A: in fixed_point_vector; B: in fixed_point_vector) return fixed_point_vector;
--function "+" (A: in fixed_point; B: in fixed_point) return fixed_point;
function "*" (A: in integer; B: in fixed_point) return fixed_point;
--function "-" (A: in fixed_point; B: in fixed_point) return fixed_point;
function "-" (A: in fixed_point_vector; B: in fixed_point_vector) return fixed_point_vector;
function "=" (A: in fixed_point_vector; B: in fixed_point_vector) return boolean;
--function "=" (A: in fixed_point; B: in fixed_point) return boolean;
function "=" (A: in fixed_point; B: in real) return boolean;
function "<=" (A: in fixed_point; B: in integer) return boolean;
function ">=" (A: in fixed_point; B: in integer) return boolean;
function "<" (A: in fixed_point; B: in integer) return boolean;
function ">" (A: in fixed_point; B: in integer) return boolean;
function "and" (A: fixed_point_vector; B: std_logic) return fixed_point_vector;
--function "*" (A: in fixed_point; B: in fixed_point) return fixed_point;
function real_to_fixed_point (A: in real) return fixed_point;
function to_fixed_point (A: in real) return fixed_point;
function to_fixed_point (A: in integer) return fixed_point;
function logic_to_fixed_point (A: in std_logic) return fixed_point;
function resize_fixed_point (A : in fixed_point) return fixed_point;
function multiply(A : in fixed_point; B : in fixed_point) return fixed_point;
function round (A : in fixed_point) return std_logic;

function gen_hidden_weights return fixed_point_vector;
function gen_input_weights return fixed_point_vector;
--function exp(A: in fixed_point) return fixed_point;
--function sigmoid(arg : in fixed_point) return fixed_point;
-- function limit(A : in fixed_point) return fixed_point;

constant init_hidden_weights		:	fixed_point_vector := gen_hidden_weights;
constant init_input_weights			: 	fixed_point_vector := gen_input_weights;


end Common;

package body Common is

	function max (A : in natural; B : in natural) return natural is
	begin
		if A > B then 
			return A;
		else
			return B;
		end if;
	end function;

	function gen_hidden_weights  return fixed_point_vector is
		variable weights : fixed_point_vector;
	begin
		for i in 0 to hiddenWidth-1 loop
			weights(i) := resize(factor * (i + 1) / hiddenWidth, b);
		end loop;
		return weights;
	end function;

	function gen_input_weights  return fixed_point_vector is
		variable weights : fixed_point_vector := (others => zero);
	begin
		for i in 0 to inputWidth-1 loop
			weights(i) := resize(factor * (i + 1) / inputWidth, b);
		end loop;
		return weights;
	end function;

--	function maximum_probability (signal probs_in : in fixed_point_vector) return fixed_point is
--	variable max_i : natural := 0;
--	variable max : fixed_point := (others => '0');
--	begin
--		for i in 0 to probs_in'length loop
--			if (probs_in(i) > max) then
--				max := probs_in(i);
--				max_i := i;
--			end if;
--		end loop;
--		return max_i;
--	end maximum_probability;
	function log2( i : natural) return integer is
		variable temp    : integer := i;
		variable ret_val : integer := 0; 
		variable init_div: integer := i/2;
	begin
--		-- increment until next power of 2
--		while (temp + 1) / 2 = init_div loop 
--			temp := temp+1;
--		end loop;
--	
		while temp > 1 loop
			ret_val := ret_val + 1;
			temp    := (temp / 2);
		end loop;
		
		if 2**ret_val < i then
			return ret_val + 1;
		else
			return ret_val;
		end if;
	end function;

	function weighted_sum (signal weights : fixed_point_vector; signal connections : fixed_point_vector; firstHidden : in boolean) return fixed_point is
	variable sum : fixed_point := (others => '0');
	begin
		for i in 0 to inputWidth-1 loop
			-- sum := resize_fixed_point(sum + resize_fixed_point(weights(i) * connections(i)));
			-- scales to factor*factor
			sum := sum + multiply(weights(i), connections(i));
		end loop;
		-- do not add higher than the number of input layer neurons if first hidden layer
		if not firstHidden then
			for i in inputWidth to maxWidth-1 loop
				sum := sum + multiply(weights(i), connections(i));
			end loop;
		end if;
--		return sum / factor;
        return sum;
	end weighted_sum;
	
--	function weighted_sum (signal weights : fixed_point_vector; signal connections : uintw_t; firstHidden : in boolean) return fixed_point is
--	variable sum : fixed_point := (others => '0');
--	begin
--		for i in 0 to inputWidth-1 loop
--			-- sum := resize_fixed_point(sum + resize_fixed_point(weights(i) * connections(i)));
--			-- scales to factor*factor
--			if (connections(i) = '1') then 
--				sum := sum + weights(i);
--			end if;
--		end loop;
--		-- do not add higher than the number of input layer neurons if first hidden layer
--		if firstHidden then
--			for i in inputWidth to maxWidth-1 loop
--				if (connections(i) = '1') then 
--					sum := sum + weights(i);
--				end if;
--			end loop;
--		end if;
----		return sum / factor;
--        return sum;
--	end weighted_sum;

	
	function sum (signal connections : fixed_point_vector; lastHidden : in boolean) return fixed_point is
	variable sum_var : fixed_point := (others => '0');
	begin
		for i in 0 to outputWidth - 1 loop
			sum_var := sum_var + connections(i);
		end loop;
		if not lastHidden then
			for i in outputWidth to maxWidth - 1 loop
				sum_var := sum_var + connections(i);
			end loop;
		end if;
		return sum_var;
	end sum;

	function scale (signal weights : fixed_point_vector; const : fixed_point) return fixed_point_vector is
		variable scaled : fixed_point_vector;
	begin
		for i in 0 to weights'length - 1 loop
			scaled(i) := weights(i) * const;
		end loop;
		return scaled;
	end scale;

	function "+" (A: in fixed_point_vector; B: in fixed_point_vector) return fixed_point_vector is
	variable add : fixed_point_vector := (others => factor);
	begin
		for i in 0 to maxWidth-1 loop
			add(i) := A(i) + B(i);
		end loop;
		return add;
	end "+";

	function "*" (A: in integer; B: in fixed_point) return fixed_point is
	   variable TEMP : double_fixed_point := to_fixed_point(A) * B;
	begin 
		return TEMP(factor_shift+fixed_point'length-1 downto factor_shift);
	end "*";

	--function "-" (A: in fixed_point; B: in fixed_point) return fixed_point is
	--variable add : fixed_point := 0;
	--begin
	--	add := A - B;
	--	return add;
	--end "-";

	function "-" (A: in fixed_point_vector; B: in fixed_point_vector) return fixed_point_vector is
	variable diff : fixed_point_vector := (others => factor);
	begin
		for i in 0 to maxWidth-1 loop
			diff(i) := A(i) - B(i);
		end loop;
		return diff;
	end "-";
	
	function "=" (A: in fixed_point_vector; B: in fixed_point_vector) return boolean is
	variable same : boolean := true;
	begin
		for i in 0 to maxWidth-1 loop
			if abs(A(i) - B(i)) > eps then
				same := false;
			end if;
		end loop;
		return same;
	end "=";

	function "=" (A: in fixed_point; B: in real) return boolean is
	begin
		if abs(A - real_to_fixed_point(B)) > eps then
			return false;
		else 
			return true;
		end if;
	end "=";

	function "<=" (A: in fixed_point; B: in integer) return boolean is
	begin
		if A <= to_signed(B, fixed_point'length) then
			return false;
		else 
			return true;
		end if;
	end "<=";

	function ">=" (A: in fixed_point; B: in integer) return boolean is
	begin
        if A >= to_signed(B, fixed_point'length) then
			return false;
		else 
			return true;
		end if;
	end ">=";

	function "<" (A: in fixed_point; B: in integer) return boolean is
	begin
		if A < to_signed(B, fixed_point'length) then
			return false;
		else 
			return true;
		end if;
	end "<";

	function ">" (A: in fixed_point; B: in integer) return boolean is
	begin
        if A > to_signed(B, fixed_point'length) then
			return false;
		else 
			return true;
		end if;
	end ">";

	--function "=" (A: in fixed_point; B: in fixed_point) return boolean is
	--begin
	--	if abs(A - B) > eps then
	--		return false;
	--	else 
	--		return true;
	--	end if;
	--end "=";

	function "and" (A: fixed_point_vector; B: std_logic) return fixed_point_vector is
	variable ret : fixed_point_vector := (others => factor);
	begin
		for i in 0 to maxWidth-1 loop
			if B = '1' then
				ret(i) := A(i);
			else
				ret(i) := (others => '0');
			end if;
		end loop;
		return ret;
	end "and";

	--function "*" (A: in fixed_point; B: in real) return fixed_point
	--begin
	--	return natural
	--end "*";

	function real_to_fixed_point (A: in real) return fixed_point is
		variable prob : fixed_point;
	begin
		if A = 0.0 then
			return zero;
		elsif A = 1.0 then
			return factor;
		else 
			return factor_2;
		end if;
	end real_to_fixed_point;
	
	function to_fixed_point (A: in real) return fixed_point is
		variable prob : fixed_point;
	begin
		return real_to_fixed_point(A);
	end to_fixed_point;
	
	function to_fixed_point (A: in integer) return fixed_point is
	begin
		return to_signed(A, fixed_point'length);
	end to_fixed_point;

	function logic_to_fixed_point (A: in std_logic) return fixed_point is
	begin
		if A = '0' then
			return (others => '0');
		else 
			return factor;
		end if;
	end logic_to_fixed_point;

	function resize_fixed_point(A : in fixed_point) return fixed_point is
    begin
        return A / factor;
    end resize_fixed_point;

	function multiply(A : in fixed_point; B : in fixed_point) return fixed_point is
		variable TEMP : double_fixed_point;
		variable TEMP2 : fixed_point;
		variable TEMP3 : signed(factor_shift-1 downto 0);
		variable A_short, B_short : signed(fixed_point'length+1-factor_shift downto 0);
	begin
		--A_short := A(fixed_point'length+1-factor_shift_2 downto factor_shift_2);
		--B_short := B(fixed_point'length+1-factor_shift_2 downto factor_shift_2);
		TEMP := A * B;
		--TEMP2 := TEMP(factor_shift+fixed_point'length-1 downto factor_shift);
		--return A_short * B_short;
		TEMP2 := TEMP(factor_shift+fixed_point'length-1 downto factor_shift);
		TEMP3 := TEMP(factor_shift-1 downto 0);
		-- tend to infinity if negative result
		-- add one if result is negative and there is a rest being thrown away
		if TEMP2(fixed_point'length-1) = '1' and TEMP3 /= 0 then
			TEMP2 := TEMP2 + 1;
		end if;
		--return TEMP(factor_shift+fixed_point'length-1 downto factor_shift); -- take result and divide by factor ( >> 10 ) and cut off top
		return TEMP2;
	end multiply;

    
--	 function multiply(A : in fixed_point; B : in fixed_point) return fixed_point is
--	   variable TEMP : double_fixed_point;
--	   variable TEMP2 : fixed_point;
--	begin
--	   TEMP := A * B;
--	   TEMP2 := TEMP(factor_shift+fixed_point'length-1 downto factor_shift);
--	   return TEMP2;
----		return TEMP(25 downto 10); -- take result and divide by factor ( >> 10 ) and cut off top
--	end multiply;
    
    function round (A : in fixed_point) return std_logic is
        variable output : std_logic;
    begin
        if A < factor_2 then
            output := '0';
        else
            output := '1';
        end if;
            
        return output;
    end round;

--	function limit(A : in fixed_point) return fixed_point is
--		variable limited : fixed_point := A;
--	begin
--		if limited > maximum then
--			limited := maximum;
--		elsif limited < minimum then
--			limited := minimum;
--		end if;
--		return limited;
--	end limit;
        
	--function exp(A: in fixed_point) return fixed_point is
	--begin
	--	return to_fixed_point(1.0) + A + (A * A / 2.0) + (A * A * A / 6.0) + (A * A * A * A / 24.0);
	--end exp;
 	


end Common;
