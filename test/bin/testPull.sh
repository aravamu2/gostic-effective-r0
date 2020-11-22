#!/bin/bash

testIndex=0

Rscript --vanilla test/bin/testPull.R           \
	-state WI                               \
	-inFile test/input/wiFetch.rds          \
	-outFile test/out/wiPull.$testIndex.csv \
	1> test/stdout/wiPull.$testIndex.out    \
	2> test/stderr/wiPull.$testIndex.err    &


testIndex=1

Rscript --vanilla test/bin/testPull.R           \
	-state NY                               \
	-inFile test/input/nyFetch.rds          \
	-outFile test/out/nyPull.$testIndex.csv \
	1> test/stdout/nyPull.$testIndex.out    \
	2> test/stderr/nyPull.$testIndex.err    &

