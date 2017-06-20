## Searching for an Application

The CyVerse catalog has hundreds of public applications that are available to run right now.
Each application is already registered to a compute resource, called an **execution system**, where the task will run.
Thus, there is no need at this time to create your own execution system.
(Please see the [Cyverse SDK](https://github.com/iPlantCollaborativeOpenSource/cyverse-sdk) if you are interested in creating your own personal copies of applications and execution systems.)

At this stage, presumably you have already formulated a scientific objective independent of CyVerse and Agave.
For example, your objective may be to **perform a multiple sequence alignment with ClustalW**.
Use the `apps-search` command to see if the ClustalW application is available in the CyVerse library: 

```
apps-search -h
apps-search public=true name.like=*Clustalw*
```

The output of this command lists two possible matches:

```
Clustalw-2.1.0u2
Clustalw-2.1.0u1
```

Two copies of ClustalW version 2.1.0 are available.
To examine the later revision of the application (u2) in more detail, issue:

```apps-list -V Clustalw-2.1.0u2```

The output of `apps-list` is a `json` description of the program including metadata, inputs, parameters, and outputs.
For example, the `metadata` includes the following:

```json
"id" : "Clustalw-2.1.0u2",
"name" : "Clustalw",
"icon" : null,
"uuid" : "5672198795481584101-e0bd34dffff8de6-0001-005",
"parallelism" : "SERIAL",
"defaultProcessorsPerNode" : 16,
"defaultMemoryPerNode" : 32,
"defaultNodeCount" : 1,
"defaultMaxRunTime" : "23:56:00",
"defaultQueue" : "normal",
"version" : "2.1.0",
"revision" : 2,
"isPublic" : true,
"helpURI" : "http://http://www.clustal.org/clustal2",
"label" : "ClustalW",
"shortDescription" : "Multiple alignment of nucleic acid and protein sequences",
"longDescription" : "Multiple alignment of nucleic acid and protein sequences", 
"tags" : [
  "msa",
  "multiple sequence alignment"
],
"ontology" : [
  "http://sswapmeet.sswap.info/agave/apps/Application"
],
"executionType" : "HPC",
"executionSystem" : "stampede.tacc.utexas.edu",
"deploymentPath" : "/api/v2/apps/Clustalw-2.1.0u2.zip",
"deploymentSystem" : "data.iplantcollaborative.org",
"templatePath" : "clustalw_wrapper.sh",
"testPath" : "../test/testwrap.sh",
"checkpointable" : false,
"lastModified" : "2015-10-26T15:03:56.000-05:00",
"modules" : [
  "purge",
  "load TACC",
  "load irods",
  "load intel/13.0.2.146",
  "load clustalw2/2.1"
],
"available" : true
```

From this description, you can see the name of the application, a short description, that the application runs in serial with 32 GB of RAM, and that the application is configured to send calculations to the [Stampede](https://www.tacc.utexas.edu/stampede/) supercomputer, among other details.

The `inputs` section of the app contains the following:

```json
"inputs" : [
  {
    "id" : "inputFasta",
    "value" : {
      "validator" : "",
      "visible" : true,
      "required" : false,
      "order" : 0,
      "enquote" : false,
      "default" : ""
    },
    "details" : {
      "label" : "Input path with filename",
      "description" : "(non-aligned) FASTA sequences to be aligned",
      "argument" : null,
      "showArgument" : false,
      "repeatArgument" : false
    },
    "semantics" : {
      "minCardinality" : 1,
      "maxCardinality" : 1,
      "ontology" : [
        "http://sswapmeet.sswap.info/mime/text/X-multiFasta"
      ],
      "fileTypes" : [
        "FASTA-0"
      ]
    }
  }
]
```

It appears that only one input is taken: a fasta file.
According to the description, it should be a "(non-aligned) FASTA sequences to be aligned."

Another useful approach to browse applications is with the `tags` keyword. For example:

```apps-search tags.like=*assembly*```

```
FALCON-0.4.2u3
idba_ud_1000gb_24h-1.1.2u1
idba_ud_32gb_24h-1.1.2u1
idba_ud_32gb_4h-1.1.2u1
trinity_normalize_kmer_coverage_lonestar-11.10.13u1
trinity-stmpde-11.10.13u2
dnasubway-cuffdiff-lonestar-2.1.1u4
dnasubway-cuffmerge-lonestar-2.1.1u1
dnasubway-cuffmerge-lonestar-2.1.1u2
dnasubway-cufflinks-lonestar-2.1.1u3
dnasubway-cuffdiff-lonestar-2.1.1u5
HTProcess_Jellyfish-2.0.0u1
```

```apps-search tags.like=*variant*```

```
savp-bwa-mem-0.4.0u1
savp-bwa-aln-0.4.0u1
savp-refprep-0.4.0u2
savp-0.3.1u1
GATK_haplotypecaller-3.2.2u1
GATK_combinegvcfs-3.2.2u1
GATK_genotypegvcfs-3.2.2u1
Platypus-0.7.9.5u1
Freebayes-0.9.20u1
GATK_unifiedgenotyper-3.2.2u1
ianimal-savp-bwa-mem-0.3.0u1
ianimal-savp-refprep-0.3.0u1
ianimal-savp-0.3.0u1
ianimal-savp-bwa-aln-0.3.0u1
```

Once the appropriate application has been identified, then the next steps are to stage the necessary data, create a job template, and submit the job. For more information on the syntax of searching, please see the [Agave Documentation](http://agaveapi.co/documentation/search-guide/).

[Back to: README](../README.md) | [Next: Creating and Submitting a Job](creating_submitting_jobs.md)
