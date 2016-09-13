#! /bin/sh

if [ "$1" == "clean" ]; then
	cat remote-clean.sh | ssh -o LogLevel=quiet -q ubuntu_vm
else
	cat remote-make.sh | ssh -o LogLevel=quiet -q ubuntu_vm
fi