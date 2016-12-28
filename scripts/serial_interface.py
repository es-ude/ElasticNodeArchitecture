#! /usr/bin/env python
import time
import serial
import binascii
import threading
import random

SLEEP_TIME=0
MAX_INT=0xffff
MAX_RANDOM_INT=0xff

def print_data(data):
	print data

def read_thread(serial):
	try:
		while True:
			header = serial.read(1)
			header = int(binascii.hexlify(bytearray(header)), 8)
			if header != 0x05: 
				print 'weird header:', header

			result = bytearray(serial.read(4))
			print "read", int(binascii.hexlify(result), 16)
	except: 
		print "receive dead"

def fpga_sleep():
	ba = bytearray([0x8])
	write_byte_array(ba)

def fpga_wake():
	ba = bytearray([0x9])
	write_byte_array(ba)

def fpga_ram_write_queue(size):
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
	# print 'sending string:', binascii.hexlify(ba)
	# ser.write(ba)
	for i in range(len(ba)):
		ser.write(chr(ba[i]))
		# print 'sent', chr(ba[i]).encode('hex')
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
ba = bytearray([0x8, 0x9, 0x03, 0x1, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x3])
#ba = bytearray([0x03, 0x1, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x3])

#fpga_sleep()
#fpga_wake()
#fpga_sleep()
#fpga_wake()
fpga_ram_write_queue(10000)

# print ser.read(1).encode('hex')
#print ser.read(1).encode('hex')

print 'waiting...'	
time.sleep(1)

ser.close()
