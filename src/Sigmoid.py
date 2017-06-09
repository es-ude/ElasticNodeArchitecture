#! /usr/bin/env python

import matplotlib.pyplot as pp
import matplotlib as mpl
import numpy as np
import math

factor = 64
max = 128

def float_sigmoid(x):
	return 1. / (1. + np.exp(-x))

def int_sigmoid(x):
	return factor / (1. + math.exp(-x/factor))

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

	output.append('		if arg < -10*factor then')
	output.append('			ret := zero;')
	output.append('		elsif arg > 10 * factor then')
	output.append('			ret := factor;')


	x = np.linspace(-max/factor, max/factor, 100)
	# y = float_sigmoid(x)
	y2 = np.zeros_like(x)
	for i in range(len(y2) - 1):
		y2[i] = int_sigmoid(int(x[i] * factor))
		output.append('		elsif arg >= to_signed(%d, fixed_point\'length) and arg < to_signed(%d, fixed_point\'length) then' % (factor * x[i], factor * x[i+1]))
		# output.append('			ret := to_signed(%d, fixed_point\'length);' % i)
		output.append('			ret := to_signed(%d, fixed_point\'length);' % y2[i])
	# pp.plot(x, np.array([y2]).T)
	# pp.grid()
	# pp.show()
	output.append('		else')
	output.append('			return factor;')
	output.append('		end if;')
	output.append("		return ret;")
	output.append('	end sigmoid;')
	output.append('end Sigmoid;')

	fopen = open('Sigmoid.vhd', 'w')
	for line in output:
		print>>fopen, line
