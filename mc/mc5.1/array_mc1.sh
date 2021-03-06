#!/bin/bash

#$ -pe smp 2
#$ -q long
#$ -N mc1_51
#$ -t 1-7:1

# Sample three chains

for i in {1..3}
do
	~/stan/nfi/mc51/mc1_nullmodel sample num_samples=15000 num_warmup=5000 thin=10 data file=~/stan/nfi/scaleddata30Nov${SGE_TASK_ID}.R init=0.1 output file=/scratch365/qread/stan/mc51out/sp${SGE_TASK_ID}mod1samples$i.csv
done

