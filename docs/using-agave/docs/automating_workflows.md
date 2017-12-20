## Advanced Job Control

### Chain multiple apps

A useful feature of Agave and the CyVerse tenant is the ability to use the output of one job as the input of a second job.
It saves time and avoids unnecessary file transfers to keep the output/input in Agave "Job API" space.
For example, consider the workflow to [Discover Variants](https://wiki.cyverse.org/wiki/pages/viewpage.action?pageId=12880264).
The first step is to align reads in fastq format to a reference genome using `bowtie`:
```
# Create a job template file for step 1:
jobs-template Bowtie2-2.2.6u1 > bowtie.json

# Modify the file to use the following public inputs:
{
  "name": "Bowtie2 test",
  "appId": "Bowtie2-2.2.6u1",
  "archive": false,
  "inputs": {
    "reference_in": "agave://data.iplantcollaborative.org/shared/iplantcollaborative/example_data/bowtie/e_coli.fa",
    "r_file": "agave://data.iplantcollaborative.org/shared/iplantcollaborative/example_data/bowtie/e_coli_10000snp.fq"
  },
  "parameter": {
  }
}

# Submit the job:
job-submit -F bowtie.json
Successfully submitted job 6837303784049414631-242ac113-0001-007

# List job output:
jobs-output-list 6837303784049414631-242ac113-0001-007
```

If all goes well, when the job is finished, the output aligned file is called `output`.
To pipe that output file into the next step of the pipeline, SAM to BAM conversion, you could download the file and re-upload it to an appropriate storage system.
Alternatively, you can point directly to that file via the Agave jobs API:
```
# Create a job template file for step 2:
jobs-template sam_to_sorted_bam-0.0.0u1 > sam_to_bam.json

# Modify the file as follows:
{
  "name": "Sam_to_bam test",
  "appId": "sam_to_sorted_bam-0.0.0u1",
  "archive": false,
  "inputs": {
    "input_file": "https://agave.iplantc.org/jobs/v2/6837303784049414631-242ac113-0001-007/outputs/media/output"
  },
  "parameter": {
  }
}

# Submit the job:
jobs-submit -F sam_to_bam.json
Successfully submitted job 5666588050428915225-242ac113-0001-007

# List job output:
jobs-output-list 5666588050428915225-242ac113-0001-007
```

If everything worked correctly, you should now have a `sorted_output.bam` file.
As long as you remain on the CyVerse tenant, much of the URI to the `input_file` will remain the same:
```
https://agave.iplantc.org/   # base URL - DO NOT CHANGE
jobs/v2/                     # refers to jobs API - DO NOT CHANGE
68373037840494.../           # previous job ID
outputs/media/               # location of output data - DO NOT CHANGE
output                       # name of output file
```


### Customize job parameters

Typically, CyVerse apps are registered to specific execution systems and specific queues.
To change the max run time, total number of nodes, or queue, you must specify the desired resource in the job `json` file.
As an example, consider the FastQC app, used in fastq quality control.
By verbosely querying the app, we find the following metadata:
```
apps-list -v dnasubway-fastqc-singularity-stampede-0.11.4.0u3
{                                                          
  "id": "dnasubway-fastqc-singularity-stampede-0.11.4.0u3",
  "name": "dnasubway-fastqc-singularity-stampede",
  "icon": null,
  "uuid": "1481285364126454246-242ac117-0001-005",
  "parallelism": "SERIAL",
  "defaultProcessorsPerNode": 16,
  "defaultMemoryPerNode": 4,
  "defaultNodeCount": 1,
  "defaultMaxRunTime": "03:00:00",
  "defaultQueue": "serial",
... etc
}
```

By default, this job will run for a maximum of 3 hours, which should be sufficient for FastQC.
Let's imagine, however, we would like to change that to 4 hours.
Create a template for this job using the `-A` flag:
```
# Create a job template:
jobs-template -A dnasubway-fastqc-singularity-stampede-0.11.4.0u3 > fastqc.json

# Modify it to include the following:
{
  "name":"dnasubway-fastqc-singularity-stampede test",
  "appId": "dnasubway-fastqc-singularity-stampede-0.11.4.0u3",
  "maxRunTime": "04:00:00",
  "archive": false,
  "inputs": {
    "input": "agave://data.iplantcollaborative.org/shared/iplantcollaborative/example_data/fastqc/SRR070572_hy5.fastq"
  },
  "parameters": {
  }
}

# Submit the job:
jobs-submit -F fastqc.json
Successfully submitted job 1207252913474965991-242ac113-0001-007
```

In this example, the `maxRunTime` metadata field was automatically placed into the job `json` file by using the `-A` flag with the `jobs-template` command.
The execution system, queue, number of nodes, number of cores, and other parameters can be modified in a similar way.



### Parameter sweeps

Most public CyVerse apps are designed to take one input file or configuration, run an analysis, and return a result.
With some simple scripting, it is possible to perform parameter sweeps using multiple Agave jobs.
For example, consider you would like to run FastQC on a series of `fastq` files named: `fastq_01.fq`, `fastq_02.fq`, `fastq_03.fq`, etc:
```
# Organize data in one folder:
ls fastq_data/
fastq_01.fq  fastq_02.fq  fastq_03.fq

# Then upload all fastqc files to CyVerse data store:
files-upload -F fastq_data/ -S data.iplantcollaborative.org username/

# And make a template json file:
jobs-template dnasubway-fastqc-singularity-stampede-0.11.4.0u3 > fastqc.json
```

The final step is to write a short script that populates the file name into the job `json` file, and submits the job.
Here is an example script:
```
#!/bin/bash

for FILE in ` ls fastq_data/ `
do

cat <<EOF >fastqc.json
{
  "name":"FastQC $FILE",
  "appId": "dnasubway-fastqc-singularity-stampede-0.11.4.0u3",
  "archive": false,
  "inputs": {
    "input": "agave://data.iplantcollaborative.org/username/fastq_data/$FILE"
  },
  "parameters": {
  }
}
EOF

	jobs-submit -F fastqc.json

done
```

This is a simple control script with much room for advanced features and error checking.


[Back to: README](../README.md)
