#!/bin/bash

## generic fast job
inFile=$1
outFile=$2
countyIndex=$3

samples=35
warmup=10
cores=1
chains=1

stdout=$(basename $outFile)
stdout=${stdout/csv/out}
stderr=$(basename $outFile)
stderr=${stderr/csv/err}

Rscript --vanilla bin/calculateR0.R   \
    -inFile $inFile -outFile $outFile \
    -countyIndex $countyIndex         \
    -samples $samples -warmup $warmup \
    -cores $cores -chains $chains     \
    1> test/stdout/$stdout            \
    2> test/stderr/$stderr            &
