#!/bin/sh

scp ../build/$1 ${program_host}:bit_file.bit

ssh -o LogLevel=quiet -q ${program_host} "sudo papilio-prog -f bit_file.bit"
