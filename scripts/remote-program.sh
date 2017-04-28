#!/bin/sh

make_host=ubuntu_vm
make_dir=git/fpgamiddlewareproject/
bit_file=genericProject.bit
tmp_bit_file=bit_file.bit
program_host=arch_pi


# fetch bit file
scp ${make_host}:${make_dir}/${bit_file} ${tmp_bit_file}

# upload to programming host
scp ${tmp_bit_file} ${program_host}:${tmp_bit_file} &&
# scp $1/build/${project_name}.bit ${program_host}:bit_file.bit &&

# program fpga
ssh ${program_host} "sudo /usr/local/bin/papilio-prog -f ${tmp_bit_file}" &&
# ssh ${program_host} "sudo /usr/local/bin/papilio-prog -f bit_file.bit"

rm ${tmp_bit_file}
echo "Done"
