#!/bin/bash

#$ -pe smp 2
#$ -q long
#$ -N mc5_52_s1c3

	~/stan/nfi/mc51/mc5_nichemodel sample num_samples=10000 num_warmup=5000 thin=5 data file=~/stan/nfi/scaleddata30Nov1.R init=0.1 output file=/scratch365/qread/stan/mc52out/sp1mod5samples3.csv