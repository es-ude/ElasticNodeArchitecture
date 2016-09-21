#!/bin/sh

scp ../build/${project_name}.bit ${program_host}:bit_file.bit

ssh -o LogLevel=quiet -q ${program_host} "sudo papilio-prog -f bit_file.bit"
