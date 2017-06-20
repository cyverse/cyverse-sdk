## Sharing Data with Other Users

Using Agave storage systems, such as the CyVerse central data store (data.iplantcollaborative.org), it is easy to share data with others users.
As a data sharing demonstration, we will use the `sequence12.fasta` file uploaded previously in this tutorial.
If you do not have that file, either [upload it now](managing_data.md), or work with a file of your own.
To list the permissions on an existing file on the remote storage system, issue:

```files-pems-list username/sequence12.fasta```

The output should look similar to:

```
dooley READ WRITE EXECUTE 
ipcservices READ WRITE 
rodsadmin READ WRITE 
username READ WRITE EXECUTE 
```

Where `username` refers to your CyVerse username.
The Agave CLI has a nice set of tools that can be used to find other users.
View your own user profile by issuing:

```profiles-list -v me```

You can search for your colleagues either by name (`-N`), e-mail address (`-E`), or username (`-U`), provided they have credentials with the same tenant:

```
profiles-list -v -N "My Collaborator"
profiles-list -v -E "my_collaborator@email.edu"
profiles-list -v -U my_collaborator
```

Once the username of the target person is known, permissions can be updated by performing the following:

```
files-pems-update -U my_collaborator -P ALL username/sequence12.fasta
files-pems-list username/sequence12.fasta
```
```
dooley READ WRITE EXECUTE 
ipcservices READ WRITE 
rodsadmin READ WRITE 
my_collaborator READ WRITE EXECUTE
username READ WRITE EXECUTE 
```

Now, a user with CyVerse username `my_collaborator` has permissions to access the file.
Valid values for setting permission with the `-P` flag are READ, WRITE, EXECUTE, READ_WRITE, READ_EXECUTE, WRITE_EXECUTE, ALL, and NONE.
This same action can be performed recursively on directories using the `-R` flag.

### Sharing Data using PostIts

Another convenient way to share data is the Agave postits service.
Postits generate a short URL with a user-specified lifetime and limited number of uses.
Anyone with the URL can paste it into a web browser, or curl against it on the command line.
Continuing with the above example file (`sequence12.fasta`) located on the CyVerse central data storage system, the process to create a postit to that file is as follows:

```postits-create -m 5 -l 3600 https://agave.iplantc.org/files/v2/media/system/data.iplantcollaborative.org//username/seqence12.fasta```

The json response from this command is the URL, e.g.:

``` https://agave.iplantc.org/postits/v2/866d55b36a459e8098173655e916fa15 ```

This postit is only good for 5 downloads (`-m 5`) and only available for one hour (3600 seconds, `-l 3600`). The creator of the postit can list and delete their postits with the following commands:

```
postits-list -V
postits-delete 866d55b36a459e8098173655e916fa15
```

The long alphanumeric string is the postit UUID displayed by the verbose postits-list command.

  
[Back to: README](../README.md) | [Next: Using Monitors to Track System Health](using_monitors.md)
