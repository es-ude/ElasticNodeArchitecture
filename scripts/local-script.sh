#! /bin/sh

echo "Creating local compile script"
script_name="$1/scripts/remote-script.sh"
echo ${script_name}

# arguments: 1. local folder 2. remote folder 3. make target
# add project name to make target: 
if [ $2 = "ngc" ];
	then
	target=${project_name}.ngc
elif [ $2 = "bit" ];
	then
	target=${project_name}.bit
else
	target=$2
fi 
echo "target: '${target}'"
echo "cd ${remote_folder}/makefile\nmake ${target}" > ${script_name}

echo "created script '${script_name}'"

echo "Connecting to make host ${make_host}"
cat ${script_name} | ssh -o LogLevel=quiet -q ${make_host}
