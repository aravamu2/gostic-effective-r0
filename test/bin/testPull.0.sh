#!/bin/bash

testIndex=$1

Rscript --vanilla test/bin/testPull.R             \
	-state WI                                 \
	-inFile test/input/wiFetch.rds            \
	-outFile test/out/wiPull.0.$testIndex.csv \
	1> test/stdout/wiPull.0.$testIndex.out    \
	2> test/stderr/wiPull.0.$testIndex.err    &


Rscript --vanilla test/bin/testPull.R             \
	-state NY                                 \
	-inFile test/input/nyFetch.rds            \
	-outFile test/out/nyPull.0.$testIndex.csv \
	1> test/stdout/nyPull.0.$testIndex.out    \
	2> test/stderr/nyPull.0.$testIndex.err    &


Rscript --vanilla test/bin/testPull.R             \
	-state TX                                 \
	-inFile test/input/txFetch.rds            \
	-outFile test/out/txPull.0.$testIndex.csv \
	1> test/stdout/txPull.0.$testIndex.out    \
	2> test/stderr/txPull.0.$testIndex.err    &

