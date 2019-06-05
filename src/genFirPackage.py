#!/usr/bin/env python2
# coding: utf-8

test = False
unit = True
predef_coeff = False

import sys
if test:
	import matplotlib.pyplot as pp
	import pylab as pl
import numpy as np
import math
import scipy.signal as sp
import datetime 

scalingFactor = 1 << 12
print "scalingFactor", scalingFactor

initial = "\
library IEEE;\n\
use IEEE.NUMERIC_STD.ALL;\n\
use IEEE.STD_LOGIC_1164.ALL;\n\
\n\
\n\
package firPackage is\n\
\n\
-- data width\n\
constant firWidth		: natural := 16;\n\
constant fifoDepth 		: natural := 50;\n\
\n\
-- /* 32-by-N matrix array structure (as in RAM). Similar to integer_vector, difference being base vector is 32-bit unsigned. */\n\
type signed_vector is array(natural range <>) of signed(firWidth-1 downto 0);\n\
type signedx2_vector is array(natural range<>) of signed(firWidth*2-1 downto 0);"

orderDef = "\
\n\n\
-- filter order\n\
constant order : natural := {};\n\
\n\
-- addresses\
\n"

addressDef = "\
constant addressWidth : integer := {}; -- ceil(log2(1 + order))\n\
constant u_address : std_logic_vector(addressWidth-1 downto 0) := std_logic_vector(to_unsigned(0, addressWidth));\n\
constant y_address : std_logic_vector(addressWidth-1 downto 0) := std_logic_vector(to_unsigned(0, addressWidth));\n\
\n"
# subtype b_addresses is range Natural range 1 to order;\n\

signed_vectorDef = "\
-- /* Filter length = number of taps = number of coefficients = order + 1 */\n\
constant fir_coeff:signed_vector(0 to order):=(\n"

post = "\
\
);\n\
\n\
end package;"

if __name__ == "__main__":
	# check arguments
	if len(sys.argv) < 2:
		print ("Usage: ./genFirPackage.py ORDER")
		order = 8
		print ("Assuming ORDER=%d" % order)
		# sys.exit(1)
	else:
		order = int(sys.argv[1])

	print ("Generating FIR filter with order", order)

	# create package file
	outputFile = open("src/firPackage.vhd", "w")

	outputFile.write("-- generated %s\n" % datetime.datetime.now())
	outputFile.write(initial)
	# print initial

	outputFile.write(orderDef.format(order))

	outputFile.write(addressDef.format(int(math.ceil(np.log2(1 + order)))))

	outputFile.write(signed_vectorDef)
	# print signed_vectorDef;

	if predef_coeff:
		lpf = np.array([0.00533285, -0.02111187,  0.04466487, -0.03372319, -0.0547435, 0.17851653, -0.21703974, 0.09887411, 0.09887411, -0.21703974,  0.17851653, -0.0547435,
 -0.03372319, 0.04466487, -0.02111187, 0.00533285]) * scalingFactor
		print lpf

	else:
		# create the filter coeffs
		fs = 1000
		t = np.arange(0, 1, 1.0/fs)
		s = np.sin(2*math.pi*50*t)+np.sin(2*math.pi*200*t)+np.sin(2*math.pi*300*t)+0.8*np.random.randn(len(t))
		gt = np.sin(2*math.pi*50*t)

		lpf = sp.firwin(order+1, 50, fs=fs, scale=100) * scalingFactor	
		sout = sp.lfilter(lpf, 1, s)

		firStr = ["0xFFEF",
			"0xFFED",
			"0xFFE8",
			"0xFFE6",
			"0xFFEB",
			"0x0000",
			"0x002C",
			"0x0075",
			"0x00DC",
			"0x015F",
			"0x01F4",
			"0x028E",
			"0x031F",
			"0x0394",
			"0x03E1",
			"0x03FC",
			"0x03E1",
			"0x0394",
			"0x031F",
			"0x028E",
			"0x01F4",
			"0x015F",
			"0x00DC",
			"0x0075",
			"0x002C",
			"0x0000",
			"0xFFEB",
			"0xFFE6",
			"0xFFE8",
			"0xFFED",
			"0xFFEF"]
		fir = list()
		for firStrSingle in firStr:
			val = int(firStrSingle, 0)
			if val > 0x7FFF:
				val -= 0x10000
			fir.append(val)
		sout2 = sp.lfilter(fir, 1, s)
		print "Coefficients:", (lpf)

	unitInputData = np.zeros((100,))
	unitInputData[0] = 1
	unitOutputData = sp.lfilter(lpf, 1, unitInputData)

	if unit:
		print 'unit output:'
		print unitOutputData

	if test:
		if unit:


			pp.plot(unitInputData)
			pp.plot(unitOutputData, 'x-')
			pp.show()
		else:
			ft = pl.fft(s)/len(s)
			ftout = pl.fft(sout)/len(sout)
			ftgt = pl.fft(gt)/len(gt)
			pp.plot(20*pl.log10(abs(ftgt)))
			pp.plot(20*pl.log10(abs(ft)))
			pp.plot(20*pl.log10(abs(ftout)))
			pp.legend(["original",  "groundtruth", "filtered"])

			pp.figure()
			w, h = sp.freqz(lpf)
			pp.plot(w/(2 * math.pi), 20*pl.log10(abs(h)))
			w, h = sp.freqz(fir)
			pp.plot(w/(2 * math.pi), 20*pl.log10(abs(h)))
			pp.legend(["LPF", "FIR"])

			pp.figure()
			pp.plot(t[:100], s[:100]);
			pp.plot(t[:100], sout[:100] / scalingFactor)
			pp.plot(t[:100], gt[:100])
			# pp.plot(t[:100], sout2[:100])
			pp.legend(["original", "filtered", "groundtruth"])
			pp.show()

	# write filter coefficients
	for i in range(len(lpf)):
		coef = lpf[i]
		if coef < 0:
			coef += 0x10000
		outputFile.write("\tx\"%04X\"" % coef)
		if i < len(lpf)-1:
			outputFile.write(",\n")
		else:
			outputFile.write("\n")


	outputFile.write(post)
	outputFile.close()
	# print post
