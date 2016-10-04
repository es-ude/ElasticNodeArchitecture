#! /usr/bin/env python
import time
import serial
import binascii

print 'opening serial port'
ser = serial.Serial('/dev/tty.usbserial-A9048DYL', 115200)

# ba = bytearray([0x30, 0x10, 0x00, 0x00])
# ba = bytearray([0x30, 0x06, 0x0, 0x0])
ba = bytearray([0x31, 'A', 'B', 'C', 'D', 'E', 0x33])
print 'sending string:', binascii.hexlify(ba)


# ser.write(ba)
for i in range(len(ba)):
	ser.write(chr(ba[i]))
	print 'sent', chr(ba[i]).encode('hex')
	time.sleep(0.1)
	# print ser.read(1).encode('hex')
ser.close()