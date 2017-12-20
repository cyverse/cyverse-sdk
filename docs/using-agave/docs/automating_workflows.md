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
https://agave.iplantc.org/   # base URL
jobs/v2/                     # refers to jobs API
68373037840494.../           # previous job ID
outputs/media/               # location of output data
output                       # name of output file
```


### Parameter sweeps

Most public CyVerse apps are designed to take one input file or configuration, run an analysis, and return a result.
With some simple scripting, it is possible to perform parameter sweeps using multiple Agave jobs.
For example:






### Customize job parameters

Typically, CyVerse apps are registered to specific execution systems and specific queues.
To change the max run time, total number of nodes, and queue, perform the following:












Tools covered in this tutorial:

```
jobs-delete
jobs-history
jobs-kick
jobs-pems-list
jobs-pems-update
jobs-restore
jobs-resubmit
jobs-run-this
jobs-search
jobs-status
jobs-stop
```
  
[Back to: README](../README.md)
