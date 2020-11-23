#!/bin/bash

testIndex=$1

Rscript --vanilla test/bin/testPull.R             \
	-state TX                                 \
	-inFile test/input/txFetch.rds            \
	-outFile test/out/txPull.0.$testIndex.csv \
	1> test/stdout/txPull.0.$testIndex.out    \
	2> test/stderr/txPull.0.$testIndex.err    &

