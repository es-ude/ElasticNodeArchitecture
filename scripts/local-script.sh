#! /bin/sh

script_name="$1/scripts/remote-script.sh"
# arguments: 1. local folder 2. remote folder 3. make target
echo "cd $remote_folder/makefile\nmake $2" > $script_name

cat $script_name | ssh -o LogLevel=quiet -q ${make_host}
