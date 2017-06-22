-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library neuralnetwork;
use neuralnetwork.common.all;

ENTITY TestVectorToWeights IS
END TestVectorToWeights;

ARCHITECTURE behavior OF TestVectorToWeights IS 
	signal weights : fixed_point_matrix;
	signal vector : weights_vector;
BEGIN

vtw:
	entity neuralnetwork.VectorToWeights(Behavioral) port map ( vector, weights);

--  Test Bench Statements
tb : PROCESS
BEGIN

wait for 10 ns; -- wait until global set/reset completes
vector <= (others => '1');
-- Add user defined stimulus here
wait for 10 ns; -- wait until global set/reset completes

wait; -- will wait forever
END PROCESS tb;
--  End Test Bench 

END;
