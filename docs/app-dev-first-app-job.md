Running a job with Agave
========================

Agave is a RESTFUL API, and as such, is meant to be interacted with via web applications or software libraries. However, you can easily run jobs by posting a properly configured JSON to the apps service. We will now go through the details of running an instance of the samtools-sort-0.1.19 app registered in the development tutorial. Go ahead and copy the example samtools-sort job to a local directory. You will need edit this file to change the *softwareName* from *samtools-sort-0.1.19* to the APP_ID you created when you registered your own samtools-sort app. 

```sh
cp $HOME/cyverse-sdk/examples/samtools-sort-job.json .
```

Follow along in the file as we dissect the elements of an Agave job specification:

```json
{
    "jobName": "samtools-sort-01",
    "softwareName": "samtools-sort-0.1.19",
    "processorsPerNode": 16,
    "requestedTime": "01:00:00",
    "memoryPerNode": 32,
    "nodeCount": 1,
    "batchQueue": "serial",
    "archive": false,
    "archivePath": "",
    "inputs": {
        "inputBam": "agave://data.iplantcollaborative.org/shared/iplantcollaborative/example_data/Samtools_mpileup/ex1.bam"
    },
    "parameters":{
    	"maxMemSort":800000000,
    	"nameSort":true
    }
}
```

| Field | Mandatory | Type | Description |
| ----- | --------- | ---- | ----------- |
| jobName | X | string | Human readable name for your job. No special characters |
| softwareName | X | string | The application ID for the Agave app you wish to invoke |
| processorsPerNode | | integer | For parallel jobs, how many processes per node to invoke |
| requestedTime | X | string | HH:MM:SS - Time estimate for how long job will take to complete |
| memoryPerNode | | integer | Maximum RAM required for each process |
| nodeCount | | integer | For parallel jobs, the number of physical compute nodes to request |
| batchQueue | | string | The queue on your executionSystem to send the job to. Defaults to normal |
| archive | X | boolean | If true, archive the job output to your tenant default storageSystem |
| archivePath | | string | If archive=true, specifies the path relative to homeDir on your tenant default storageSystem to which result files will be copied |

```sh
# Submit the job for Agave to execute. Don't forget to edit softwareName before
# do this or you will get a pesky error saying you don't have access to samtools-sort-0.1.19
# Here's a log from an example run
jobs-submit -F samtools-sort-job.json
Successfully submitted job 0001397239178196-5056a550b8-0001-007

jobs-status 0001397239178196-5056a550b8-0001-007
RUNNING
```

### Helpful notes
1. State progression for Agave V2 jobs is: PENDING, STAGING_INPUTS, CLEANING_UP, ARCHIVING, STAGING_JOB, FINISHED, KILLED, FAILED, STOPPED, RUNNING, PAUSED, QUEUED, SUBMITTING, STAGED, PROCESSING_INPUTS, ARCHIVING_FINISHED, ARCHIVING_FAILED
2. If you set archive=true, your results will be staged to the CyVerse Data Store, but successful scratch directories are deleted after job completion. While you are debugging your application, it's best to keep it set to false. This way, your scratch directories all remain on the executionSystem. On TACC systems, if you have followed our templates for creating a private executionSystem, the scratch files will be found in $WORK/$TACCUSERNAME. Folders will be named job-$JOBID-$JOBNAME. If you have login access to the executionSystem you can SSH into it and watch the job run through to completion (or error) inside this folder. 

### Post-mortem analysis and debugging jobs

Agave V2 features some handy new features to help you diagnose performance and completion issues with your jobs:

* If you are running on your private executionSystem, you can log into the system (see above) and watch the job progress. This is incredibly valuable.
* Once your job is submitted into the system, you can run jobs-history $JOBID and get a report back.
```sh
# Example jobs-history
jobs-history 0001397239178196-5056a550b8-0001-007
Job accepted and queued for submission.
Attempt 1 to stage job inputs
Identifying input files for staging
Staging agave://data.iplantcollaborative.org/shared/iplantcollaborative/example_data/Samtools_mpileup/ex1.bam to execution system
Copy in progress
Job inputs staged to execution system
Attempt [1] Preparing job for execution and staging binaries to execution system
HPC job successfully placed into queue
Job started running
Job completed. Skipping archiving at user request.
```
* You can list the output of your job, whether it runs to completion or not
```sh
# Example jobs-output
jobs-output 0001397239178196-5056a550b8-0001-007
.agave.archive
bin.tgz
ex1.bam
samtools-sort-01-0001397239178196-5056a550b8-0001-007.err
samtools-sort-01-0001397239178196-5056a550b8-0001-007.out
samtools-sort-01.ipcexe
samtools-sort.json
sort.template
sorted.bam
test
test-sort.sh
```
* You can download specific files, for example the *ipcexe job file
```sh
jobs-output --download --path samtools-sort-01.ipcexe 0001397239178196-5056a550b8-0001-007 
```
* You can get more detailed outputs from any of the Agave CLI commands by adding -v to your command line to output the JSON response, and/or by adding -V which will print STDERR to your screen.

[Back](app-dev.md) | [Next: Sharing your app with others](app-dev-share-app.md)
