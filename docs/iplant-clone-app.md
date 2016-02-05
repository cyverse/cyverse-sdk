Cloning and customizing existing Apps
================================================
As discussed in the [Creating an iPlant application for TACC Stampede] tutorial, an Agave app is a bundle that includes the executable, any dependencies, test data, a "wrapper script" and a JSON app description.  The way they are bundled makes them fairly portable, but at the same time, every app is connected to a specific execution system and the login information associated with that system.  To run apps on your own systems, like the ones you registered in the [Setting up iPlant development systems] tutorial, you can clone the app and register it with your own execution system.  That will be the focus of this tutorial.

Cloning an App
---------------
The apps-clone command will help you port an existing app to your own system.  If the app is "private", the app assets (i.e. executable and wrapper script) remain with the original owner, and only the JSON app description is updated with the execution system information that you specify.  For "public" apps, the entire app bundle is copied to the directory you specify, allowing you to edit any parts of the app you wish.  iPlant has published quite a few public apps.  This tutorial will begin by cloning a public app and mention private apps at the end.

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

### Private Apps

Cloning a private app is straightforward.  It is the same as a public app, just without a new destination path:
```sh
apps-clone -V -N new_app_name -R version_number -E system_name agave_app_id
```
With private apps, you are dependent on the original author to register the app in a way that preserves the portability of Agave apps to new systems. If you have access to the app's original destinationPath (outside of Agave), you can copy the app's assets to your own location to adapt them as needed to work with your new system.  If not, the best plan is to try a few test jobs to make sure cloning to a new system works well.  Sharing private apps is a great way to disseminate software without relenquishing control of the source code or executables, but it is incumbent on the author make sure the application still works when other users clone it.

Notes
-----
*The following info could be useful in this tutorial, but it needs to be woven in better.  This is still a work in progress.*
### Uploading the application bundle

Now, upload the application bundle:
```sh
# cd out of the bundle
cd $WORK/iPlant
# Upload using files-upload
files-upload -S data.iplantcollaborative.org -F samtools-0.1.19 IPLANTUSERNAME/applications
```
Any time you need to update the binaries, libraries, templates, etc. in your non-public application, you can just make the changes locally and re-upload the bundle. The next time Agave invokes a job using this application, it will stage out the updated version of the application bundle.

### Updating your app description

Any time you need to update the metadata description of your non-public application, you can just make the changes locally to the JSON file and and re-post it as such. The field *samtools-sort-0.1.19* at the end is the appid you're updating. Agave tries to guess from the JSON file but to remove uncertainty, we recommend always specifying it explicitly. 

```sh
apps-addupdate -F samtools-0.1.19/stampede/samtools-sort.json samtools-sort-0.1.19
```

The next time Agave invokes a job using this application, it will use the new description.

[Creating an iPlant application for TACC Stampede]:./iplant-first-app.md
[Setting up iPlant development systems]:./iplant-systems.md

