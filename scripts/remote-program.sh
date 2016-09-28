#!/bin/sh

scp $1/build/${project_name}.bit ${program_host}:bit_file.bit &&

ssh ${program_host} "sudo /usr/local/bin/papilio-prog -f bit_file.bit"
