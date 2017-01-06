#! /usr/bin/env python
import time
import serial
import binascii
import threading
import random
import numpy as np
import traceback 
import sys

__dbg__=True
SLEEP_TIME=0.0
SLEEP_START=0.1
SLEEP_BETWEEN=1
SLEEP_END=2.5
MAX_INT=0xffff
MAX_RANDOM_INT=0xffffffff

INPUT_TYPE=np.uint16
OUTPUT_TYPE=np.uint32

MATRIX_MULTIPLICATION=1
VECTOR_DOTPRODUCT=2
app = VECTOR_DOTPRODUCT

REPEAT = 1

#a = np.array([[0,1,400],[2,0,1],[1,5,0],[1,1,0]])
#b = np.array([[0,1,4,2,7],[0,1,3,2,4],[0,2,3,4,5]])
local = None
local_size = None
#np.set_printoptions(formatter={'int_kind':hex})


def create_random_data():
	a = np.random.randint(MAX_RANDOM_INT, size=(4,3)).astype(INPUT_TYPE)
	b = np.random.randint(MAX_RANDOM_INT, size=(3,5)).astype(INPUT_TYPE)
	return a, b


def print_data(data):
	print data

def read_thread(serial_port):
	incoming_data = list()

	for i in range(REPEAT):
		print "REPEAT NUMBER", i
	
		if app == MATRIX_MULTIPLICATION:
			arr = None
			try:
				header = serial_port.read(1)
				header = int(binascii.hexlify(bytearray(header)), 16)
				if header != 0x05: 
					print 'weird header:', header
				else:
					print 'receiving response...'

				print 'ignoring one byte...'
				serial_port.read(1)
	
				while True:
					result = bytearray(serial_port.read(4))
					if __dbg__:
						print np.array(result)
						print "read", int(binascii.hexlify(result), 16), "HEX", np.array([int(binascii.hexlify(result), 16)])
					incoming_data.append(int(binascii.hexlify(result), 16))
					
					if len(incoming_data) == local_size:
						break
				print len(incoming_data)
		
				arr = np.array(incoming_data, dtype=np.uint32)
				if __dbg__:
					print "printing raw incoming data"
					arr = np.array(incoming_data, dtype=np.uint16)
					print arr
					arr = np.array(incoming_data, dtype=np.uint32)
					print arr
				incoming_data = []
		
			except serial.SerialException:
				print "Serial exception..."
				return	
			if arr is not None:
				remote = np.reshape(arr, np.dot(a,b).shape)
				print 'remote:\n', remote
		
				where = np.where(remote != local)
		
				diff = len(where[0])
				print 'not same:', diff
				if diff > 0:
					print local.dtype
					print remote.dtype
	
					print local[where]
					print remote[where]
			else:
				print "No data received"

		else:
			print "vector dotproduct reader"
			try:
				header = serial_port.read(1)
				header = int(binascii.hexlify(bytearray(header)), 16)
				if header != 0x05: 
					print 'weird header:', header
				else:
					print 'receiving response...'

				print 'ignoring one byte...'
				serial_port.read(1)
	
				result = bytearray(serial_port.read(4))
				if __dbg__:
					print np.array(result)
					print "read", int(binascii.hexlify(result), 16), "HEX", np.array([int(binascii.hexlify(result), 16)])
				
				arr = np.array(incoming_data, dtype=np.uint32)
				if __dbg__:
					print "printing raw incoming data"
					arr = np.array(incoming_data, dtype=np.uint16)
					print arr
					arr = np.array(incoming_data, dtype=np.uint32)
					print arr
				incoming_data = []
		
			except serial.SerialException:
				print "Serial exception..."
				return	
			if arr is not None:
				remote = arr
				print 'remote:\n', remote
		
			else:
				print "No data received"
			
	print "DONE"
	
		
def fpga_sleep():
	ba = bytearray([0x8])
	write_byte_array(ba)

def fpga_wake():
	ba = bytearray([0x9])
	write_byte_array(ba)

def fpga_matrixmultiplication(a, b):
	args = list()
	for i in a.flatten():
		args.append(i)
	for i in b.flatten():
		args.append(i)
	
	fpga_ram_write(args)
	print '\nlocal\n', local

def fpga_vectordotproduct(size):
	args = list()
	args.append(size)
	for i in range(size):
		first = int(random.random() * MAX_RANDOM_INT)
		second = int(random.random() * MAX_RANDOM_INT)
		#first = 0xAB
		#second = 0xCD
		#print 'input:',  first, second
		args.append(first)
		args.append(second)
	fpga_ram_write(args)

	# print local result 
	print 'local', vector_dot_product(args)

def fpga_ram_write(list_of_ints):
	bytes = list()
	# header
	bytes.append(0x3)
	# address
	for i in range(4): bytes.append(0x11)
	size = 4*len(list_of_ints)
	print 'size:', size
	bytes.append(size >> 24 & 0xff)
	bytes.append(size >> 16 & 0xff)
	bytes.append(size >> 8 & 0xff)
	bytes.append(size & 0xff)

	for num in list_of_ints:
		bytes.append(num >> 24 & 0xff)
		bytes.append(num >> 16 & 0xff)
		bytes.append(num >> 8 & 0xff)
		bytes.append(num & 0xff)

	# 0x3 32bit_bytes 32bit_address 32bit_size data
	ba = bytearray(bytes) # bytearray([0x03, 0x1, 0x2, 0x3, 0x4, 0x0, 0x0, 0x0, 0xC, 0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x3])
	write_byte_array(ba)
		
def write_byte_array(ba):
	if __dbg__:
		print 'sending string:', binascii.hexlify(ba)
	# ser.write(ba)
	for i in range(len(ba)):
		ser.write(chr(ba[i]))
		if __dbg__:
			print 'sent', chr(ba[i]).encode('hex')
		time.sleep(SLEEP_TIME)

def vector_dot_product(args):
	# args: size, a,b,a,b
	size = args[0]
	output = 0
	for i in range(1, len(args), 2):
		output += (args[i] * args[i+1])
		#output += (args[i] & MAX_INT * args[i+1] & MAX_INT) & MAX_INT
	return output

print 'opening serial port'
ser = serial.Serial('/dev/tty.usbserial-A9048DYL', 500000)
recThread = threading.Thread(target=read_thread, args=(ser,))
recThread.start()

#ba = bytearray([0x08, 0x09, 0x08, 0x09])
#ba = bytearray([0x8, 0x9, 0x03, 0x1, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x3])
#ba = bytearray([0x03, 0x1, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x3])

time.sleep(SLEEP_START)
fpga_sleep()
time.sleep(SLEEP_START)
fpga_wake()
time.sleep(SLEEP_START)

for i in range(REPEAT):
	if app == MATRIX_MULTIPLICATION:
		a, b = create_random_data()
		local = np.dot(a.astype(OUTPUT_TYPE),b.astype(OUTPUT_TYPE))
		local_size = local.flatten().shape[0]

		fpga_matrixmultiplication(a, b)
		time.sleep(SLEEP_BETWEEN)
	else:
		fpga_vectordotproduct(1)
print 'waiting...'	
time.sleep(SLEEP_END)

ser.close()
