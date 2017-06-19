#! /usr/bin/env python

import matplotlib.pyplot as pp
import matplotlib as mpl
import numpy as np
import math

factor = 64.
max = 1280.
eps = 5.729

def float_sigmoid(x):
	return 1. / (1. + np.exp(-x))

def int_sigmoid(x):
        result = round((factor - 2*eps) * 1. / (1. + math.exp(-x)) + eps)
        # limit from edge
        result = max(eps, min(result, factor-eps))
        print x, result
        return int(result)

if __name__ == '__main__':
	output = list()
	output.append('library IEEE;')
	output.append('use IEEE.STD_LOGIC_1164.ALL;')

	output.append('use ieee.numeric_std.all;')

	output.append('library work;')
	output.append('use work.Common.all;')

	output.append('')
	output.append('package Sigmoid is')
	output.append('function sigmoid(arg : in fixed_point) return fixed_point;')
	output.append('end Sigmoid;')

	output.append('')
	output.append('package body Sigmoid is')
	output.append('	function sigmoid (arg: in fixed_point) return fixed_point is')
	output.append("		variable ret : fixed_point;")
	output.append('	begin')

	output.append('		if arg < -%d then' % int(limit*factor))
	output.append('			ret := to_signed(%d, fixed_point\'length);' % eps)
	output.append('		elsif arg > %d then' % int(limit*factor))
	output.append('			ret := to_signed(%d, fixed_point\'length);' % (factor - eps))


	x = np.linspace(-limit, limit, 100)
	y = float_sigmoid(x)* factor
	y2 = np.zeros_like(x)
	for i in range(len(y2) - 1):
		y2[i] = int_sigmoid(x[i])
		output.append('		elsif arg >= to_signed(%d, fixed_point\'length) and arg < to_signed(%d, fixed_point\'length) then' % (int(factor * x[i]), int(factor * x[i+1])))
		# output.append('			ret := to_signed(%d, fixed_point\'length);' % i)
		output.append('			ret := to_signed(%d, fixed_point\'length);' % y2[i])
	pp.plot(x, np.array([y2,y]).T)
	pp.grid()
	pp.show()
	
	output.append('		else')
	output.append('			return factor;')
	output.append('		end if;')
	output.append("		return ret;")
	output.append('	end sigmoid;')
	output.append('end Sigmoid;')

	fopen = open('Sigmoid.vhd', 'w')
	for line in output:
		print>>fopen, line
	fopen.flush()
	# fopen.close()
