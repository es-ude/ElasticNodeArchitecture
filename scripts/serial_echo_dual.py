#! /usr/bin/env python
import time
import serial
import binascii
import threading
import random
import numpy as np
import traceback 
import sys

__dbg__=False
ECHO=True
SLEEP_TIME=0.
SLEEP_START=0.1
SLEEP_BETWEEN=.5
SLEEP_END=2.5
MAX_INT=0xffff
MAX_RANDOM_INT=0xffffffff
BAUD=500000
TIMEOUT=0.001

INPUT_TYPE=np.uint16
OUTPUT_TYPE=np.uint32

MATRIX_MULTIPLICATION=1
VECTOR_DOTPRODUCT=2
DUMMY=3
#app = VECTOR_DOTPRODUCT
app = 2
FLASH_ADDRESS = {MATRIX_MULTIPLICATION:0x0, VECTOR_DOTPRODUCT:0x60000}

MCU_TRANSMIT_PARAMETER_DATA_DIRECTLY 	= 0x0D
FPGA_CALCULATION_RESULT			= 0x0E 

REPEAT = 10

#a = np.array([[0,1,400],[2,0,1],[1,5,0],[1,1,0]])
#b = np.array([[0,1,4,2,7],[0,1,3,2,4],[0,2,3,4,5]])
local = None
local_size = None

np.set_printoptions(formatter={'int_kind':hex})


def print_data(data):
	print data

def read_thread(serial_port, id):
	incoming_data = list()

	for i in range(REPEAT):
		print "REPEAT NUMBER", i
	
		arr = None
		if ECHO:
			print "receiving all"
			while True:
				header = bytearray(serial_port.read(1000))
				if len(header) > 0:
					# print len(header)
					# header = int(binascii.hexlify(bytearray(header)), 16)
					#if len(header) > 30:
					print id, len(header), np.array([header])
					#else:
					#	print id, len(header), np.array([header])
					# print id, len(header), np.array([header])
					# print header
					#header = ''.join(str(v) for v in header)
					#print header,
	
		
print 'opening serial port 1'
ser1 = serial.Serial(sys.argv[1], BAUD, timeout=TIMEOUT)
print 'opening serial port 2'
ser2 = serial.Serial(sys.argv[2], BAUD, timeout=TIMEOUT)

recThread1 = threading.Thread(target=read_thread, args=(ser1,"FPGA "))
recThread1.start()

recThread2 = threading.Thread(target=read_thread, args=(ser2,"MCU  "))
recThread2.start()

size = 1

print 'waiting...'	

#time.sleep(SLEEP_END)

#ser.close()
