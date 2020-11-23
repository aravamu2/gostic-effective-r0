#!/bin/bash

testIndex=$1
####  same answer as without date filtering
Rscript --vanilla test/bin/testPull.R           \
	-state WI                               \
	-inFile test/input/wiFetch.rds          \
	-outFile test/out/wiPull.$testIndex.0.csv \
	-beginDate 2020-01-01                   \
	-endDate   2020-12-31                   \
	1> test/stdout/wiPull.$testIndex.0.out    \
	2> test/stderr/wiPull.$testIndex.0.err    &


Rscript --vanilla test/bin/testPull.R           \
	-state NY                               \
	-inFile test/input/nyFetch.rds          \
	-outFile test/out/nyPull.$testIndex.0.csv \
	-beginDate 2020-01-01                   \
	-endDate   2020-12-31                   \
	1> test/stdout/nyPull.$testIndex.0.out    \
	2> test/stderr/nyPull.$testIndex.0.err    &

###############################
Rscript --vanilla test/bin/testPull.R           \
	-state WI                               \
	-inFile test/input/wiFetch.rds          \
	-outFile test/out/wiPull.$testIndex.1.csv \
	-beginDate 2020-04-01                   \
	-endDate   2020-09-30                   \
	1> test/stdout/wiPull.$testIndex.1.out    \
	2> test/stderr/wiPull.$testIndex.1.err    &


Rscript --vanilla test/bin/testPull.R           \
	-state NY                               \
	-inFile test/input/nyFetch.rds          \
	-outFile test/out/nyPull.$testIndex.1.csv \
	-beginDate 2020-04-01                   \
	-endDate   2020-09-30                   \
	1> test/stdout/nyPull.$testIndex.1.out    \
	2> test/stderr/nyPull.$testIndex.1.err    &

