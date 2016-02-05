#!/bin/bash
 
# Agave automatically writes these scheduler
# directives when you submit a job but we have to
# do it by hand when writing our test

#SBATCH -p development
#SBATCH -t 00:30:00
#SBATCH -n 15
#SBATCH -A iPlant-Collabs 
#SBATCH -J test-samtools
#SBATCH -o test-samtools.o%j

# Set up inputs and parameters
# We're emulating passing these in from Agave
#
#inputBam is the name of one of the inputs we
#will specify later
inputBam="ex1.bam"
# outputPrefix is a parameter we specify later
# For now, we will set it statically
outputPrefix=sorted
# maximum memory for sort, in bytes
maxMemSort=500000000
# Boolean: Sort by name instead of coordinate
nameSort=0

# Unpack the bin.tgz file containing samtools binaries
# If you are relying entirely on system-supplied binaries you don't
# need this bit
tar -xvf bin.tgz
# Set the PATH to include binaries in bin
export PATH=$PATH:"$PWD/bin"
 
# Build up an ARGS string for the program
# Start with empty ARGS...
ARGS=""
# Add -m flag if maxMemSort was specified
if [ ${maxMemSort} -gt 0 ]; then ARGS="${ARGS} -m $maxMemSort"; fi

# Boolean handler for -named sort
if [ ${nameSort} -eq 1 ]; then ARGS="${ARGS} -n "; fi
 
# Run the actual program
samtools sort ${ARGS} $inputBam ${outputPrefix}

# Now, delete the bin/ directory
rm -rf bin

