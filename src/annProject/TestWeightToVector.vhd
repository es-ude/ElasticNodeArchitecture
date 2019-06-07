-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library neuralnetwork;
use neuralnetwork.common.all;

ENTITY TestWeightToVector IS
END TestWeightToVector;

ARCHITECTURE behavior OF TestWeightToVector IS 
	signal weights : fixed_point_matrix;
	signal vector : weights_vector;
BEGIN

wtv:
	entity neuralnetwork.weightstovector(Behavioral) port map ( weights, vector);

--  Test Bench Statements
tb : PROCESS
BEGIN

wait for 10 ns; -- wait until global set/reset completes
weights <= (others => (others => init_weight));
weights(0) <= (others => x"12");
-- Add user defined stimulus here
wait for 10 ns; -- wait until global set/reset completes

wait; -- will wait forever
END PROCESS tb;
--  End Test Bench 

END;
