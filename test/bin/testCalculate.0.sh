#!/bin/bash

testIndex=$1
###################
# Test 0: Calc R0 with -countyIndex 1;  35 samples;
test/bin/testCalculate.sh test/model/wiPull.0.csv test/out/wiCalc.0.$testIndex.csv 1
test/bin/testCalculate.sh test/model/nyPull.0.csv test/out/nyCalc.0.$testIndex.csv 1
test/bin/testCalculate.sh test/model/txPull.0.csv test/out/txCalc.0.$testIndex.csv 1 
