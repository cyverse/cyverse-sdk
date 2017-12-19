## Drug Discovery

*Note: To complete this example, you must have TACC credentials and access to the tacc.prod tenant.*

DrugDiscovery@TACC is a web portal that allows users to upload a protein file and perform a virtual screen with pre-defined ligand libraries.
Access to the portal is controlled through a web login with [TACC credentials](https://portal.tacc.utexas.edu/).
Behind the scenes, the portal stages the relevant data on a TACC storage system, assembles a json-format job file, executes the job, and returns the results all using the Agave platform.
More information can be found on [DrugDiscovery@TACC website](https://drugdiscovery.tacc.utexas.edu/).

The web portal provides a nice graphical interface and facilitates the Agave calls.
A user could, however, also run the virtual screen directly from the command line with the Agave CLI.
It is important to know that the applications, storage systems, and execution systems behind the portal are not registered with the CyVerse tenant (**iplantc.org**).
They are registered with the TACC tenant (**tacc.prod**).

The first step is to switch the current tenant for the TACC tenant, preserving the old configuration:

```tenants-init -b -t tacc.prod```

The `-b` flag will backup the current configuration in the `~/.agave/` directory on your local filesystem.
It is always possible to switch back to the previous configuration by using the `-s` flag:

```tenants-init -s```

Now that you are configured to interact with the TACC tenant, make sure your [TACC credentials](https://portal.tacc.utexas.edu/) are ready, then go through the process of registering a client and authentication tokens as described [here](initializing.md).

Identify the correct public application by issuing one of the following two commands:

```
apps-list -P
apps-search name.like=*vina*
```

The most recent revision of the [AutoDock Vina](http://vina.scripps.edu/) application is called `vina-lonestar-1.1.2u4`.
FInd out more information about the application with:

```apps-list -v vina-lonestar-1.1.2u4```

A close read of the result indicates that, as input, a `proteinFile` is required in format `pdb` or `pdbqt`.
The user can also provide `ligandFiles`, but they are not required (`"required": false`).
Many parameters are required for this application, including `sizeX`, `sizeY`, `sizeZ`, `centerX`, `centerY`, `centerZ`, `paramFile` (optional), and `ligandIndices` (optional). To begin to organize all this data into a json-format job script, use the `jobs-template` command:

```jobs-template -N DDP_Job_from_CLI -A vina-lonestar-1.1.2u4 >> vina-job.json```

The resulting `vina-job.json` file should look like:

```
{
  "name":"DDP_Job_from_CLI",
  "appId": "vina-lonestar-1.1.2u4",
  "batchQueue": "",
  "executionSystem": "docking.exec.lonestar",
  "maxRunTime": "01:00:00",
  "memoryPerNode": "1GB",
  "nodeCount": 1,
  "processorsPerNode": 1,
  "archive": true,
  "archiveSystem": "docking.storage",
  "archivePath": null,
  "inputs": {
    "proteinFile": "/work/02875/docking/apps/vina/1.1.2/lonestar/test/2FOM.pdbqt",
    "ligandFiles": [ 
      "/work/02875/docking/apps/vina/1.1.2/lonestar/test/ZINC00000567.pdbqt",
      "/work/02875/docking/apps/vina/1.1.2/lonestar/test/ZINC00000707.pdbqt"
    ]
  },
  "parameters": {
    "sizeY": 22,
    "ligandIndices": -1,
    "centerZ": -4.0899999999999999,
    "sizeZ": 22,
    "centerX": -0.081000000000000003,
    "sizeX": 22,
    "paramFile": "/scratch/01114/jfonner/DockingPortal/TestSet/paramlist",
    "centerY": 2.2130000000000001
  },
  "notifications": [
    {
      "url":"http://requestbin.agaveapi.co/1gcbadn1?job_id=${JOB_ID}&status=${JOB_STATUS}",
      "event":"*",
      "persistent":true
    },
    {
      "url":"username@email.edu",
      "event":"FINISHED",
      "persistent":false
    },
    {
      "url":"username@email.edu",
      "event":"FAILED",
      "persistent":false
    }
  ]
}

```

There are several terms in this job file that need to be understood and modified.
(See Agave documentation on this [here](http://agaveapi.co/documentation/tutorials/app-management-tutorial/).)
First, notice that the `executionSystem` is called `docking.exec.lonestar`.
This seems to indicate that the job will be run on the Lonestar supercomputer.
(This can quickly be confirmed with `systems-list -v docking.exec.lonestar`.)

Why is this important?
The queue settings must match the node architecture of the execution system.
Referring to the Lonestar 4 [documentation](https://portal.tacc.utexas.edu/user-guides/lonestar), we find that the **normal** nodes are **12** core each and have **24GB** of RAM.
To match those settings, use the following options:

```
"batchQueue": "normal",
"executionSystem": "docking.exec.lonestar",
"maxRunTime": "02:00:00",
"memoryPerNode": "24GB",
"nodeCount": 2,
"processorsPerNode": 12,
```

Next, the input `proteinFile` and `ligandFiles` are pointing to absolute paths _on the storage system_.
There are two options to proceed.
First, if you have access to Lonestar, you could upload a `proteinFile` to your $HOME or $WORK space, then provide in this job script the complete path to that file.
Second, you could upload a `proteinFile` to any Agave storage system, and provide the complete Agave URI to that file.
In this tutorial, we will choose the second method.

In order to upload a `proteinFile`, we have to quickly switch back to the **iplantc.org** tenant where we have access to a storage system.
A protein file is provided with this tutorial, located in this git bundle at `~using-agave/src/protein.pdbqt`.
Issue the following commands:

```
tenants-init -s							# switch to iplantc.org tenant
auth-check
auth-tokens-refresh						# if necessary
files-upload -F src/protein.pdbqt username/
files-list -L							# confirm the file is there
tenants-init -s							# switch back to tacc.prod tenant
auth-check
```

Now in the `vina-job.json` file, modify the `proteinFile` input to the complete URI, then delete the optional input called `ligandFiles`, which will not be used in this tutorial:

**Before:**
```
  "inputs": {
    "proteinFile": "/work/02875/docking/apps/vina/1.1.2/lonestar/test/2FOM.pdbqt",
    "ligandFiles": [ 
      "/work/02875/docking/apps/vina/1.1.2/lonestar/test/ZINC00000567.pdbqt",
      "/work/02875/docking/apps/vina/1.1.2/lonestar/test/ZINC00000707.pdbqt"
    ]
  },
```

**After:**
```
  "inputs": {
    "proteinFile": "agave://data.iplantcollaborative.org/username/protein.pdbqt"
  },
```

Notice that the comma `,` was removed from the end of the `proteinFile` line to preserve json formatting.
Next, insert the following box sizes and centers:

```
 "parameters": {
    "sizeY": 24,
    "centerZ": 57.5,
    "sizeZ": 28,
    "centerX": 11,
    "sizeX": 22,
    "paramFile": "/scratch/01114/jfonner/DockingPortal/TestSet/paramlist",
    "centerY": 90.5
  },
```

These values were taken from the [AutoDock Vina tutorial](http://vina.scripps.edu/tutorial.html), which is also the origin of the protein file.
Also notice that the `ligandIndices` parameter was removed.
Finally, use the following path for `paramFile` that points to small ligand library:

```"paramFile": "/scratch/01114/jfonner/DockingPortal/TestSet/paramlist",```

Once everything is ready, submit the job with the command:

```jobs-submit -F vina-job.json```m

A long number, which is the job ID, will be returned if the submission was succesful.
To track the progress of the job, use the `jobs-history`, `jobs-status`, and `jobs-list` commands. For example:

```
jobs-history 706429864087682021-242ac114-0001-007
jobs-statsy 706429864087682021-242ac114-0001-007
jobs-list 706429864087682021-242ac114-0001-007
```

(Execute these commands with the `-h` flag to find more usage information.)
Jobs themselves pass through many different stages including PENDING (waiting for submission), RUNNING (running in the queue), FINISHED (completed), and FAILED (job failed).
A full list of statuses and descriptions can be found [here](http://agaveapi.co/documentation/tutorials/job-management-tutorial/).

If you have access toi the Lonestar supercomputer, you may also check the status of the job in the queue with `showq -u`.
Once the job status is "FINISHED", the results can be listed and downloaded with the following commands:

```
jobs-output-list -L 706429864087682021-242ac114-0001-007
jobs-output-list -L 706429864087682021-242ac114-0001-007 a_folder/
jobs-output-get -r 706429864087682021-242ac114-0001-007
jobs-output-get 706429864087682021-242ac114-0001-007 a_folder/a_file
```

The output can be navigated with `jobs-output-list` in the same way that `files-list` is used to navigate a storage system.
Also, ouput can be downloaded with `jobs-output-get` recursively, or a single file at a time.

[Back to: README](../README.md)
