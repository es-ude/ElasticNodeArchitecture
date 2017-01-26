#!/bin/sh

make_host=ubuntu_vm
make_dir=git/fpgamiddlewareproject/
bit_file=papilioDuoMiddleware.bit
tmp_bit_file=bit_file.bit
program_host=arch_pi
flash_location=$1

# fetch bit file
scp ${make_host}:${make_dir}/${bit_file} ${tmp_bit_file}

# upload to programming host
scp ${tmp_bit_file} ${program_host}:${tmp_bit_file} &&
# scp $1/build/${project_name}.bit ${program_host}:bit_file.bit &&

# program fpga
if [ -z ${flash_location} ]
then ssh ${program_host} "sudo /usr/local/bin/papilio-prog -b papilioloadermod/papilio-prog/bscan_spi_lx9.bit -f ${tmp_bit_file} -v"
else ssh ${program_host} "sudo /usr/local/bin/papilio-prog -b papilioloadermod/papilio-prog/bscan_spi_lx9.bit -f ${tmp_bit_file} -a ${flash_location}:${tmp_bit_file} -v"
fi

ssh ${program_host} "sudo /usr/local/bin/papilio-prog -r -v" &&
# ssh ${program_host} "sudo /usr/local/bin/papilio-prog -f bit_file.bit"

rm ${tmp_bit_file}
echo "Done"
