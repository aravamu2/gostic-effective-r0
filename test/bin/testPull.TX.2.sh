#!/bin/bash

testIndex=$1

## Test 2:  testing various dates for TX
####  
Rscript --vanilla test/bin/testPull.R               \
	-state TX                                   \
	-inFile test/input/txFetch.rds              \
	-outFile test/out/txPull.2.0.$testIndex.csv \
	-beginDate 2020-01-01                       \
	-endDate   2020-10-31                       \
	1> test/stdout/txPull.2.0.$testIndex.out    \
	2> test/stderr/txPull.2.0.$testIndex.err    &

###############################
## Test 2.1  

Rscript --vanilla test/bin/testPull.R               \
	-state TX                                   \
	-inFile test/input/txFetch.rds              \
	-outFile test/out/txPull.2.1.$testIndex.csv \
	-beginDate 2020-05-01                       \
	-endDate   2020-12-31                       \
	1> test/stdout/txPull.2.1.$testIndex.out    \
	2> test/stderr/txPull.2.1.$testIndex.err    &


## Test 2.2  same as 2.0 (with -beginDate NULL)
Rscript --vanilla test/bin/testPull.R               \
	-state TX                                   \
	-inFile test/input/txFetch.rds              \
	-outFile test/out/txPull.2.2.$testIndex.csv \
	-endDate   2020-10-31                       \
	1> test/stdout/txPull.2.2.$testIndex.out    \
	2> test/stderr/txPull.2.2.$testIndex.err    &

###############################
## Test 2.3 same as 2.1 (with -endDate NULL)

Rscript --vanilla test/bin/testPull.R               \
	-state TX                                   \
	-inFile test/input/txFetch.rds              \
	-outFile test/out/txPull.2.3.$testIndex.csv \
	-beginDate 2020-05-01                       \
	1> test/stdout/txPull.2.3.$testIndex.out    \
	2> test/stderr/txPull.2.3.$testIndex.err    &
