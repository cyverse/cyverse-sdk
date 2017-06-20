## Managing Data

Before running an application, it is important to understand how data flows in and out of CyVerse with the Agave CLI.
As a CyVerse user, you are able to store data in the central data store called **data.iplantcollaborative.org**.
To see more information, use the following command:

```systems-list -V data.iplantcollaborative.org```

A "system" in Agave is a server or collection of servers associated with a single hostname.
As you may see in the output from the above command, the CyVerse data store is a cloud-based repository from which data is accessed by all of its technologies.
To make this your default data repository when using the Agave CLI, issue the command:

```systems-setdefault data.iplantcollaborative.org```

Now, when using the Agave CLI `files` commands, you will automatically be configured to interact with this data storage system.
With the Agave CLI `files` commands, you can list available files and directories, upload or download data, copy, move, or delete data, import data from another source, and change permissions on existing data.
To see a Linux-style long listing of what is currently available in your home directory, issue:

```files-list -L username/```


Where `username` is replaced with your CyVerse username.
If this is your first time interacting with the iPlant data store, then your home directory may still be empty.
Create a new folder in your home directory, then list the contents of that folder (empty for now) by typing:

```
files-mkdir -N new-folder username/
files-list -L username/
files-list -L username/new-folder/
```

Create an example file on your local machine, and upload it to the data store:

```
touch new-file.txt
echo "some example text" >> new-file.txt
files-upload -F new-file.txt username/
files-list -L username/
```

Many common Linux file manipulation commands, including `cp` and `mv`, have an analogous command in the Agave CLI:

```
files-copy -D username/new-file-copy.txt username/new-file.txt
files-move -D username/new-folder/new-file-copy.txt username/new-file-copy.txt
files-list -L username/
files-list -L username/new-folder/
```

Files and folders can be deleted, but be cautious because there is no way to recover:

```
files-delete username/new-folder/new-file-copy.txt
files-delete username/new-folder/
files-list -L username/
```

Delete the local copy of `new-file.txt`, then download the remote copy with the `files-get` command:

```
rm new-file.txt
files-get username/new-file.txt
cat new-file.txt
```

This concludes the overview of how to manage data on the data storage system.
At any time, you can issue an Agave command with the `-h` flag to find more information on the function and usage of the command.
Some advanced file operations will be demonstrated in the second part of this tutorial.

[Back to: README](../README.md) | [Next: Searching for an Application](searching_apps.md)
