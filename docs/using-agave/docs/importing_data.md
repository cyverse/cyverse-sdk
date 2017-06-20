## Importing Data from Other Systems or the Web

This tutorial previously covered [managing data](managing_data.md) between a local machine and the CyVerse central data store (data.iplantcollaborative.org).
It also may be useful to import data from other storage systems, or even from the web.
The `files-import` command can be used for that purpose.
First, use `systems-list` to discover publicly available storage systems:

```systems-list -PS```
```
data.iplantcollaborative.org
data.tacc.utexas.edu
irods-2.cyverse.org
ncbi-1000genomes
ncbi-genbank
ncbi-genbank-genomes
ncbi-refseq
ncbi-sra-ftp
us-west-1.data.iplantcollaborative.org
```

The `-P` flag lists public systems only, and the `-S` flag lists storage systems only.
One of the available storage systems is called `ncbi-1000genomes`.
Find out more about that systems by listing it verbosely:

```systems-list -v ncbi-1000genomes```

A subset of the output includes:

```
{
    "description": "NCBI 1000 Genomes data catalog", 
    "id": "ncbi-1000genomes", 
    "lastModified": "2016-01-10T16:21:24.000-06:00", 
    "name": "NCBI 1000 Genomes FTP", 
    "public": true, 
    "revision": 2, 
    "site": "ncbi.nih.gov", 
    "status": "UP", 
    "storage": {
        "auth": {
            "type": "ANONYMOUS"
        }, 
        "homeDir": "/", 
        "host": "ftp.ncbi.nih.gov", 
        "mirror": false, 
        "port": 21, 
        "protocol": "FTP", 
        "proxy": null, 
        "publicAppsDir": null, 
        "rootDir": "/1000genomes/ftp/"
    }, 
    "type": "STORAGE", 
    "uuid": "7184991354511430117-e0bd34dffff8de6-0001-006"
}
```

This storage system is registered to the `ftp.ncbi.nih.gov` host.
(Try dropping that hostname into a web browser).
Currently, your environment may be configured so that `data.iplantcollaborative.org` is your default storage system.
It is still possible to list files on other storage systems as long the identity of the system is explicitly stated.
For example:

```files-list -L -S ncbi-1000genomes /```

The trailing `/` indicates that you want to list the default home directory of that storage system.
One file that appears is called `README.complete_genomics_data`.
Transfer it to your default storage system with the command:

```files-import -U 'agave://ncbi-1000genomes/README.complete_genomics_data' username/```

With the above syntax, the file located at the home directory `/` on the `ncbi-1000genomes` storage system will be imported to your default storage system (if you have been following this tutorial, `data.iplantcollaborative.org`), and placed in your home directory `username/`.

Please also note that even though you are *able* to import files from other Agave storage systems, you may not always *need* to import those files.
Most Agave applications will allow you to provide a complete URI path to the file, e.g. `agave://ncbi-1000genomes/README.complete_genomics_data`.
This is very useful, for example, in the case of large reference libraries.
Pointing to the remote libraries rather than copying them saves time and disk space.

Finally, you can also import files from the web using the URL.
This is useful to import files that are not part of an Agave storage system:

```
files-import -U 'https://github.com/wjallen/using-agave/blob/master/src/sequence12.fasta' username/
files-import -U 'https://github.com/wjallen/using-agave/blob/master/src/sequence12.fasta' -W 'username@email.edu' username/
```

The final example above demonstrates a nice feature that sends an e-mail when the transfer is complete.

[Back to: README](../README.md) | [Next: Sharing Data with Other Users](sharing_data.md)
