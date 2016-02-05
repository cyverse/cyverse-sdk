Using an Atmosphere VM as an Agave Execution System
===================================================
As a proof of principle, we will us an Atmosphere virtual machine as an execution host.  This is not a common use case, since usually Agave execution systems are persistent, but it will demonstrate everything you need to know to extend the compute resources of iPlant to include your own systems and apps.

Installing prerequisites
------------------------

First, ssh into your iPlant instance.
```sh
ssh <username>@<ip.address>
```

Once logged in, let us install the tools we need.
```sh
sudo apt-get install git
git clone https://bitbucket.org/taccaci/foundation-cli.git
echo 'export PATH=$PATH:~/foundation-cli/bin' >> ~/.bashrc
git clone https://github.com/iPlantCollaborativeOpenSource/iplant-agave-sdk.git
export PATH=$PATH:~/iplant-agave-sdk/scripts
```

Registering your VM as a system
-------------------------------

To run apps on your VM, you simply need to tell Agave where it is and how to login.  We have made a convenience script to help do this, but you still need to know your iPlant username and password.

```sh
We are going to enroll your current Atmosphere system as an Agave system
so you can run apps on it through Agave.
The following assumes you have created an Agave client via client-create.
We will now ask you to refresh your access token...



API secret [6bA9SOcyi4o8FZ6K9QwN1PYaEkMa]: 
API key [jqcKaswlGH4D5snghfMYfhijQE8a]: 
API username [vaughn]: 
API password: 
Token successfully refreshed and cached for 13150 seconds
ef5f619c98ca45c56d4bc2a29dbc723b

We will now configure a new execution system and need some info from you
    TACC username
	TACC password
	TACC Project name
    The path to your $WORK directory on the VM (usually /home/<username>)

Do you have all the information required? [Yes]: 
OK. Let's begin.
Enter your TACC user account []: vaughn
Confirmed: TACC user account is vaughn
Enter your TACC account password []: \n
Enter your TACC work directory []: /home/vaughn
Confirmed: TACC work directory is 
tacc-atmosphere-template
Enrolling private system tacc-stampede-template
Successfully added system stampede-04012014-1718-vaughn

Here is a listing of your systems:
lonestar4.tacc.teragrid.org
lonestar4-04012014-1718-vaughn
stampede.tacc.utexas.edu
stampede-04012014-1718-vaughn
maverick-04012014-1718-vaughn
data.iplantcollaborative.org
```

### Public Apps
First off, we should find an app that we would like to clone.
```sh
apps-list -n blast
```
The apps-list command returns a list of all apps that are shared with you, both public and private.  Using the **-n** flag, you can provide a search string to filter down the list of apps. In our case, an app with the ID *blastx-stampede-ncbi-db-2.2.26u1* was returned.  Depending on when you try this command, you may see newer versions of blastx as well.

Cloning this app would look something like this:

```sh
apps-clone -V -N new_blastx_app_name -R 2.2.26 -E system_name -S data.iplantcollaborative.org -P IPLANTUSERNAME/applications/new_blastx_app_name-2.2.26/system_name blastx-stampede-ncbi-db-2.2.26u1
```
Here is a brief explanation of the options we used:

| Flag | Purpose |
|------|---------|
|  -V  | verbose output (optional) |
|  -N  | the name of our new app.  This will be used to generate a unique ID, so it could be something like "username-blastx-system". |
|  -R  | version number.  This will also become part of the app ID. |
|  -E  | the new execution system.  You must have "publish" permission on the system, so usually this will be a system like the ones you registered in the [Setting up iPlant development systems] tutorial. |
|  -S  | the destination storage system. |
|  -P  | the destination path relative to rootDir on the destination storage system. (directory will be created if it doesn't exist *AND* you have the correct permissions) |

After filling in the specifics of your system_name, etc. and issuing the command, Agave will return a "success" message along with details of your new app if you used the **-V** flag.

### Testing the App

When cloning a public app, you have the chance to look at what is inside the app bundle.  It is also a chance to see how the author wrote their wrapper script and json description.  When authoring your own apps, it is handy to use good public apps as a reference.

Agave does not support recursive downloads natively, but in this SDK, there is a script called "files-get-recursive" that implements recursion on the client side. You can download your newly cloned app bundle like this:

```sh
files-get-recursive -r -S data.iplantcollaborative.org IPLANTUSERNAME/applications/new_blastx_app_name-2.2.26
```

Once downloaded, take a look at blastx.sge and blastx.json.  Do you see anything that should be changed?

### Updating your app description

Any time you need to update the metadata description of your non-public application, you can just make the changes locally to the JSON file and and re-post it as such. The field *samtools-sort-0.1.19* at the end is the appid you're updating. Agave tries to guess from the JSON file but to remove uncertainty, we recommend always specifying it explicitly. 

```sh
apps-addupdate -F samtools-0.1.19/stampede/samtools-sort.json samtools-sort-0.1.19
```

The next time Agave invokes a job using this application, it will use the new description.

[Creating an iPlant application for TACC Stampede]:./iplant-first-app.md
[Setting up iPlant development systems]:./iplant-systems.md

