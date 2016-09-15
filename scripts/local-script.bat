@echo "Building with make %2"
@set script_name="%1/scripts/remote-script.sh"
@rem arguments: 1. local folder 2. remote folder 3. make target
@echo sh %remote_folder%/scripts/remote-script.sh ; /bin/bash > %script_name%

plink -load %make_host% -t -l burger -m %script_name%