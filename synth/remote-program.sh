#!/bin/sh

scp $1 ubuntu_vm_local:bit_file.bit
ssh -o LogLevel=quiet -q ubuntu_vm_local "papilio-prog -f bit_file.bit"