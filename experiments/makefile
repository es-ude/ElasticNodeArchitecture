FIRST := 1
LAST := 18
NUMBERS := $(shell seq ${FIRST} ${LAST})
JOBS := $(addprefix job,${NUMBERS})

all: ${JOBS}
	echo "done"

${JOBS}: job%:
	python ../src/genMatrixMultiplicationSkeleton.py $* 
	cd ..; ./compile
	cp ../genericProject_map.xrpt reports/$*.xrpt
	#mv reports/mm/$*.xrpt reports/mm/$*.xml

skeletonTest: ${JOBS}
	echo done!
		# cd ..; ./compile ; \ 
		# cd experiments; cp ../genericProject_map.xrpt reports/$$number.xml ; \
