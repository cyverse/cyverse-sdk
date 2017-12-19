## Advanced Job Control

Coming soon...




### Chain multiple apps

A useful feature of Agave and the CyVerse tenant is the ability to use the output of one job as the input of a second job.
It saves time and avoids unnecessary file transfers to keep the output/input in Agave "Job API" space.
Here is an example:





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
