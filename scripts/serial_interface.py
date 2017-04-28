#! /usr/bin/env python
import time
import serial
import binascii
import threading
import random
import numpy as np
import traceback 
import sys
import array 

__dbg__=False
SLEEP_TIME=0.0
SLEEP_START=0.25
SLEEP_BETWEEN=0.5
SLEEP_END=1.5
MAX_INT=0xffff
MAX_RANDOM_INT=0xffffffff

INPUT_TYPE=np.uint16
OUTPUT_TYPE=np.uint32

MATRIX_MULTIPLICATION=1
VECTOR_DOTPRODUCT=2
DUMMY=3
#app = VECTOR_DOTPRODUCT
app = 2
FLASH_ADDRESS = {MATRIX_MULTIPLICATION:0x0, VECTOR_DOTPRODUCT:0x60000}

MCU_TRANSMIT_PARAMETER_DATA_DIRECTLY 	= 0x0D
FPGA_CALCULATION_RESULT					= 0x0E 
FPGA_READY								= 0x10

REPEAT = 10

#a = np.array([[0,1,400],[2,0,1],[1,5,0],[1,1,0]])
#b = np.array([[0,1,4,2,7],[0,1,3,2,4],[0,2,3,4,5]])
local = None
local_size = None

np.set_printoptions(formatter={'int_kind':hex})


def create_random_data(size=None):
	if app == MATRIX_MULTIPLICATION:
		a = np.random.randint(MAX_RANDOM_INT, size=(4,3)).astype(INPUT_TYPE)
		b = np.random.randint(MAX_RANDOM_INT, size=(3,5)).astype(INPUT_TYPE)
	elif app == VECTOR_DOTPRODUCT:
		a = np.random.randint(MAX_RANDOM_INT, size=(size,)).astype(INPUT_TYPE)
		b = np.random.randint(MAX_RANDOM_INT, size=(size,)).astype(INPUT_TYPE)
	else:
		a = np.random.randint(MAX_RANDOM_INT, size=(1,)).astype(INPUT_TYPE)[0]
		b = None
	return a, b

def print_data(data):
	print data

def read_thread(serial_port):
	incoming_data = list()

	for i in range(REPEAT):
		print "REPEAT NUMBER", i
	
		arr = None
		try:

			# while True:
			# 	header = serial_port.read(1)
			# 	header = int(binascii.hexlify(bytearray(header)), 16)
			# 	print 'received:', np.array([int(header)])

			answer_ready = False

			while not answer_ready:
				header = serial_port.read(1)
				header = int(binascii.hexlify(bytearray(header)), 16)

				if header == FPGA_CALCULATION_RESULT:
					print 'receiving response...'
					answer_ready = True
				elif header == FPGA_READY: 
					print 'fpga ready...'
				else:
					print 'weird header:', np.array([int(header)])
			
			# header = serial_port.read(1)
			# header = int(binascii.hexlify(bytearray(header)), 16)
			# print header
			# if header != FPGA_CALCULATION_RESULT: 
			# 	print 'weird header:', np.array([int(header)])
			# else:
			# 	print 'receiving response...'
			
			#print 'ignoring one byte...'
			#skip = serial_port.read(1)
			#if __dbg__: print 'skipped:', ord(skip), np.array([skip])

			size = serial_port.read(4) [::-1]
			print np.array(bytearray(size))
			size = int(binascii.hexlify(bytearray(size)), 16)
			if __dbg__: 
				print "size received: ", size
				

			while True:
				result = bytearray(serial_port.read(4)[::-1])
				if __dbg__:
					print np.array(result), "read", int(binascii.hexlify(result), 16), "HEX", np.array([int(binascii.hexlify(result), 16)])
				incoming_data.append(int(binascii.hexlify(result), 16))
				
				
				if len(incoming_data) == local_size:
					break
	
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
		if app == MATRIX_MULTIPLICATION:
			print 'arr in:', arr
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
		elif app == VECTOR_DOTPRODUCT:
			remote = arr
			print remote
		
	print "DONE"
	
		
def fpga_sleep():
	print "sleeping userlogic"
	ba = bytearray([0x8])
	write_byte_array(ba)

def fpga_wake():
	print "waking userlogic"
	ba = bytearray([0x9])
	write_byte_array(ba)

def fpga_multiboot(address):
	bytes = list()
	# add header
	bytes.append(0x06)
	# add address
	bytes.append(address >> 16 & 0xff)
	bytes.append(address >> 8 & 0xff)
	bytes.append(address & 0xff)
	
	ba = bytearray(bytes)
	print "uploading new multiboot address:", hex(address)
	print ba

	write_byte_array(ba)

def fpga_matrixmultiplication(a, b):
	args = list()
	for i in a.flatten():
		args.append(i)
	for i in b.flatten():
		args.append(i)
	
	fpga_ram_write(args)
	# print '\nlocal\n', local

def fpga_vectordotproduct(size, a, b):
	args = list()
	args.append(size)
	for i in range(size):
		first = a[i] # int(random.random() * MAX_RANDOM_INT)
		second = b[i] # int(random.random() * MAX_RANDOM_INT)
		#first = 0xAB
		#second = 0xCD
		#print 'input:',  first, second
		args.append(first)
		args.append(second)
	fpga_ram_write(args)

	# print local result 
	print 'local', np.array([vector_dot_product(args)])

def fpga_dummy(a):
	args = list()
	args.append(a)
	fpga_ram_write(args)

	# print local result 
	print 'local', np.array([a])

def fpga_ram_write(list_of_ints):
	bytes = list()
	# header
	bytes.append(MCU_TRANSMIT_PARAMETER_DATA_DIRECTLY)
	# address
	#for i in range(4): bytes.append(0x11)
	size = 4*len(list_of_ints)
	if __dbg__: print 'size:', size
	bytes.append(size & 0xff)
	bytes.append(size >> 8 & 0xff)
	bytes.append(size >> 16 & 0xff)
	bytes.append(size >> 24 & 0xff)

	for num in list_of_ints:
		bytes.append(num & 0xff)
		bytes.append(num >> 8 & 0xff)
		bytes.append(num >> 16 & 0xff)
		bytes.append(num >> 24 & 0xff)

	# 0x3 32bit_bytes 32bit_address 32bit_size data
	ba = bytearray(bytes) # bytearray([0x03, 0x1, 0x2, 0x3, 0x4, 0x0, 0x0, 0x0, 0xC, 0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x3])
	write_byte_array(ba)
		
def write_byte_array(ba):
	if __dbg__:
		print 'sending string:', binascii.hexlify(ba)
	# ser.write(ba)
	for i in range(len(ba)):
		ser.write(chr(ba[i]))
		# if __dbg__:
		# 	print 'sent', chr(ba[i]).encode('hex')
		time.sleep(SLEEP_TIME)

def vector_dot_product(args):
	# args: size, a,b,a,b
	args = np.array(args).astype(OUTPUT_TYPE)
	size = args[0]
	output = 0
	for i in range(1, len(args), 2):
		output += (args[i] * args[i+1])
		#output += (args[i] & MAX_INT * args[i+1] & MAX_INT) & MAX_INT
	return output

print 'opening serial port'
ser = serial.Serial('/dev/tty.usbserial-AI02KF2A', 500000)

time.sleep(SLEEP_START)
fpga_sleep()
time.sleep(SLEEP_START)
fpga_wake()
time.sleep(SLEEP_START)

#app = DUMMY
#recThread = threading.Thread(target=read_thread, args=(ser,))
#recThread.start()

'''
app = MATRIX_MULTIPLICATION

# first application
a, b = create_random_data()
local = np.dot(a.astype(OUTPUT_TYPE),b.astype(OUTPUT_TYPE))
local_size = local.flatten().shape[0]

SLEEP_TIME=0.

fpga_matrixmultiplication(a, b)
time.sleep(3)
SLEEP_TIME=0.05


time.sleep(2)
# switch app
fpga_multiboot(0x60000)
time.sleep(3)

'''
# app = VECTOR_DOTPRODUCT

#ser.close()
#ser = serial.Serial('/dev/tty.usbserial-A9048DYL', 500000)

recThread = threading.Thread(target=read_thread, args=(ser,))
recThread.start()


size = 1

# fpga_multiboot(0x60000)

# second application
for i in range(REPEAT):
	if app == MATRIX_MULTIPLICATION:
		a, b = create_random_data()
		local = np.dot(a.astype(OUTPUT_TYPE),b.astype(OUTPUT_TYPE))
		local_size = local.flatten().shape[0]
		fpga_matrixmultiplication(a, b)
		time.sleep(SLEEP_BETWEEN)
	elif app == VECTOR_DOTPRODUCT:
		# a, b = create_random_data(size)
		a, b = [10],[20]
		local_size = 1
		fpga_vectordotproduct(size, a, b)
		time.sleep(SLEEP_BETWEEN)
		# print 'input', a, b
	
	else:
		a, _ = create_random_data()
		fpga_dummy(a)
		time.sleep(SLEEP_BETWEEN)
		
print 'waiting...'	

time.sleep(SLEEP_END)

ser.close()
