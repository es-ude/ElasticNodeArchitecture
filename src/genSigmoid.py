#! /usr/bin/env python

import matplotlib.pyplot as pp
import matplotlib as mpl
import numpy as np
import math

factor = 1024.
# max = 128.
eps = 0.
limit = 4.

def float_sigmoid(x):
	return eps + (factor - eps*2) * (1. / (1. + np.exp(-x)))

def int_sigmoid(x):
        result = round((factor - 2*eps) * 1. / (1. + math.exp(-x)) + eps)
        # limit from edge
        result = max(eps, min(result, factor-eps))
        # print x, result
        return int(result)

if __name__ == '__main__':
	output = list()
	output.append('library IEEE;')
	output.append('use IEEE.STD_LOGIC_1164.ALL;')

	output.append('use ieee.numeric_std.all;')

	output.append('library work;')
	output.append('use work.Common.all;')

	output.append('')
	output.append('entity Sigmoid is')
	output.append('port (')
	output.append('	arg 	: in fixed_point;')
	output.append('	ret 	: out fixed_point')
	output.append(');')
	output.append('end Sigmoid;')
	# output.append('package Sigmoid is')
	# output.append('function sigmoid(arg : in fixed_point) return fixed_point;')
	# output.append('end Sigmoid;')

	output.append('')
	output.append('architecture Behavioral of Sigmoid is')
	# output.append('package body Sigmoid is')
	# output.append('	function sigmoid (arg: in fixed_point) return fixed_point is')
	# output.append("		variable ret : fixed_point;")
	output.append('	begin')

	output.append('	process (arg) is')
	output.append('	begin')
	output.append('		if arg < %d then' % int(-limit*factor))
	output.append('			ret <= to_fixed_point(%d);' % eps)
	output.append('		elsif arg > %d then' % int(limit*factor))
	output.append('			ret <= to_fixed_point(%d);' % (factor - eps))



	x = np.linspace(-limit, limit, 100)
	y = float_sigmoid(x)
	y2 = np.zeros_like(x)
	r = np.zeros((2,))
	y3 = list()
	oldy = eps
	for i in range(len(y2)):
		y2[i] = int_sigmoid(x[i])
		if y2[i] != oldy:
			oldy = y2[i]
			r[1] = i
			y3.append(np.array([r[0], r[1], oldy]).astype('int'))
			r[0] = i
		#output.append('		elsif arg >= to_signed(%d, fixed_point\'length) and arg < to_signed(%d, fixed_point\'length) then' % (int(factor * x[i]), int(factor * x[i+1])))
		# output.append('			ret := to_signed(%d, fixed_point\'length);' % i)
		#output.append('			ret := to_signed(%d, fixed_point\'length);' % y2[i])
	# last entry:
	y3.append(np.array([r[0], len(y2) - 1, y2[-1]]).astype('int'))

	#pp.figure()
	#pp.hold(True)

	for i in range(len(y3)):
		current = y3[i]
		#print current,
		current[0] = (int(factor * x[current[0]]))
		current[1] = (int(factor * x[current[1]]))

		print current
		pp.plot([current[0], current[1]], [current[2], current[2]], 'b')
		output.append('		elsif arg >= to_fixed_point(%d) and arg < to_fixed_point(%d) then' % (current[0], current[1]))
		output.append('			ret <= to_fixed_point(%d);' % current[2])

	#print y3
	
	#pp.plot(factor * x, np.array([y2]).T, 'r')
	#pp.plot(factor * x, np.array([y]).T, 'g')
	#pp.grid()
	#pp.show()
	
	output.append('		else')
	output.append('			ret <= factor;')
	output.append('		end if;')
	output.append('	end process;')
	# output.append("		return ret;")
	# output.append('	end sigmoid;')
	output.append('end Behavioral;')

	fopen = open('Sigmoid.vhd', 'w')
	for line in output:
		print>>fopen, line
	fopen.flush()
	# fopen.close()
