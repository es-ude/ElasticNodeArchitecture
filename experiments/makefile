LAST := 0
NUMBERS := $(shell seq 0 ${LAST})
JOBS := $(addprefix job,${NUMBERS})

${JOBS}: job%:
	python ../src/genMatrixMultiplicationSkeleton.py $* 
	cd ..; ./compile
	cp ../genericProject_map.xrpt reports/$*.xrpt

skeletonTest: ${JOBS}
	echo done!
		# cd ..; ./compile ; \ 
		# cd experiments; cp ../genericProject_map.xrpt reports/$$number.xrpt ; \
