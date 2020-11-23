#!/bin/bash

testIndex=$1

## Test 1.0
####  same answer as without date filtering

Rscript --vanilla test/bin/testPull.R               \
	-state WI                                   \
	-inFile test/input/wiFetch.rds              \
	-outFile test/out/wiPull.1.0.$testIndex.csv \
	-beginDate 2020-01-01                       \
	-endDate   2020-12-31                       \
	1> test/stdout/wiPull.1.0.$testIndex.out    \
	2> test/stderr/wiPull.1.0.$testIndex.err    &

Rscript --vanilla test/bin/testPull.R               \
	-state NY                                   \
	-inFile test/input/nyFetch.rds              \
	-outFile test/out/nyPull.1.0.$testIndex.csv \
	-beginDate 2020-01-01                       \
	-endDate   2020-12-31                       \
	1> test/stdout/nyPull.1.0.$testIndex.out    \
	2> test/stderr/nyPull.1.0.$testIndex.err    &

Rscript --vanilla test/bin/testPull.R               \
	-state TX                                   \
	-inFile test/input/txFetch.rds              \
	-outFile test/out/txPull.1.0.$testIndex.csv \
	-beginDate 2020-01-01                       \
	-endDate   2020-12-31                       \
	1> test/stdout/txPull.1.0.$testIndex.out    \
	2> test/stderr/txPull.1.0.$testIndex.err    &

###############################
## Test 1.1  filtering start and end dates;
Rscript --vanilla test/bin/testPull.R               \
	-state WI                                   \
	-inFile test/input/wiFetch.rds              \
	-outFile test/out/wiPull.1.1.$testIndex.csv \
	-beginDate 2020-04-01                       \
	-endDate   2020-09-30                       \
	1> test/stdout/wiPull.1.1.$testIndex.out    \
	2> test/stderr/wiPull.1.1.$testIndex.err    &

Rscript --vanilla test/bin/testPull.R               \
	-state NY                                   \
	-inFile test/input/nyFetch.rds              \
	-outFile test/out/nyPull.1.1.$testIndex.csv \
	-beginDate 2020-04-01                       \
	-endDate   2020-09-30                       \
	1> test/stdout/nyPull.1.1.$testIndex.out    \
	2> test/stderr/nyPull.1.1.$testIndex.err    &

Rscript --vanilla test/bin/testPull.R               \
	-state TX                                   \
	-inFile test/input/txFetch.rds              \
	-outFile test/out/txPull.1.1.$testIndex.csv \
	-beginDate 2020-04-01                       \
	-endDate   2020-09-30                       \
	1> test/stdout/txPull.1.1.$testIndex.out    \
	2> test/stderr/txPull.1.1.$testIndex.err    &
