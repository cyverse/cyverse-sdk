## Creating and Submitting a Job

Continuing from the previous example of ClustalW, we know that the only input taken is a single fasta file. An example, non-aligned FASTA file, courtesy of the [ClustalW developers](http://www.ebi.ac.uk/Tools/msa/clustalw2/help/faq.html#11),  has been included with this repository.
Upload that sample file to the CyVerse data store by first navigating to the `using-agave/` directory, then by issuing:

```
files-upload -F src/sequence12.fasta username/
files-list -L username/
```

(Please replace `username` with your CyVerse username).
The only other thing needed is a job script that describes the application you intend to run, the system on which the job will be executed, the location of the input data, and any other necessary parameters.
The `jobs-template` command is used to help assemble a job script specific to an application:

```jobs-template -A Clustalw-2.1.0u2 >> Clustalw-job.json```

The `-A` flag indicates to use all fields in the json job template file.
Open up the resulting file, `Clustalw-job.json`, in a Linux text editor such as VIM.

```vim Clustalw-job.json```

```
{
  "name":"Clustalw test-1459832693",
  "appId": "Clustalw-2.1.0u2",
  "batchQueue": "normal",
  "executionSystem": "stampede.tacc.utexas.edu",
  "maxRunTime": "23:56:00",
  "memoryPerNode": "32GB",
  "nodeCount": 1,
  "processorsPerNode": 16,
  "archive": true,
  "archiveSystem": "data.iplantcollaborative.org",
  "archivePath": null,
  "inputs": {
    "inputFasta": ""
  },
  "parameters": {
    "format": "CLUSTAL",
    "T": "DNA",
    "outname": "clustalw2.aln",
    "arguments": ""
  },
  "notifications": [
    {
      "url":"http://requestbin.agaveapi.co/1i1th851?job_id=${JOB_ID}&status=${JOB_STATUS}",
      "event":"*",
      "persistent":true
    },
    {
      "url":"username@tacc.utexas.edu",
      "event":"FINISHED",
      "persistent":false
    },
    {
      "url":"username@tacc.utexas.edu",
      "event":"FAILED",
      "persistent":false
    }
  ]
}
```

The important part to edit here is lines 13-15, which point to the location of the fasta file.
Use the `agave://` prefix to give a full description of the location of your staged data:

```
  "inputs": {
    "inputFasta": "agave://data.iplantcollaborative.org/username/sequence12.fasta"
  },
```

(Please replace `username` with your CyVerse username). Finally, submit the job by issuing:

```jobs-submit -F Clustalw-job.json```

If there are no errors, you will see a success message upon submission.
This indicates that the application, data, and any other instructions you provide have been bundled and sent to the execution system for processing.
You can monitor the progress of the jobs-list command, with or without the job id:

```
jobs-list
jobs-list -v 658585977227923941-242ac114-0001-007
```

Once the job status is `FINISHED`, you can list what output is available:

```jobs-output-list 658585977227923941-242ac114-0001-007```

Which should result in:

```
clustalw2.79585.err
clustalw2.aln
clustalw-test-1459832693-658585977227923941-242ac114-0001-007.err
clustalw-test-1459832693-658585977227923941-242ac114-0001-007.out
sequence12.dnd
sequence12.fasta
```

The important output here is the `clustalw2.aln` file which contains the aligned sequences.
The `.err` or `.out` files also may contain important information if there were any errors during the job.
Download a single file, or download the whole directory to your local machine with:

```
jobs-output-get 658585977227923941-242ac114-0001-007 clustalw2.aln
jobs-output-get -r 658585977227923941-242ac114-0001-007
```

Congratulations! You have successfully completed a job within the CyVerse cyberinfrastructure using the Agave CLI.

[Back to: README](../README.md)
