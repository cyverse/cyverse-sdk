Setting up iPlant development systems
=====================================

One of the most interesting features of the new Agave release is its ability to make use of diverse systems for storing data and executing applications. This offers both an opportunity and a challenge if you come to us from Agave V1 application development. Under the V1 model, there were a limted number of monolithic, shared public systems; you had to get special permission to do app development; and debugging was *painful* because your jobs didn't run under your own username on the host systems. Agave 2.0 opens up additional possibilities by allowing you to enroll your own compute and storage resources, as well as create versions of the resources used by iPlant. A separate tutorial covers creating your own systems. 

A "system" under Agave 2.0 is a combination of login credentials, information about available physical resources, policy descriptions, and configuration options that combine to create an abstraction of a physical computing system. This frees end users from needing to know specific details about the actual computing environment in order to move data to the system and run computing tasks on it. 

We will now set up private versions of all public systems that iPlant uses to power Discovery Environment applications. You can accomplish this manually via the systems-clone and systems-list commands, but we have bundled an automated script with the SDK to make it even more straightforward. You only need to do this once, as the systems created here will be forever associated with your iPlant credentials (until you delete them from service).

Because we're bridging iPlant and [Texas Advanced Computing Center](https://www.tacc.utexas.edu/resources/hpc) systems, you will need information from both organizations. We assume you have been in contact with [iPlant support staff](mailto:support@iplantcollaborative.org) and asked to be added to our list of Agave app developers who are allowed to log into TACC systems, and we assume you have an active iPlant account. Gather your iPlant credentials (specifically your password), your TACC username and password, and the full path to your WORK directory on TACC systems. To find out this last bit of information:
```sh
ssh stampede.tacc.utexas.edu 'echo $WORK'
```

Now, type *iplant-systems-create* which will iterate through a set of templates stored in $IPLANT_SDK_HOME and create a new, private version of each TACC system for you. Here's an example log from running this for myself:

```sh
We are going to create and enroll personal copies of various HPC systems
used by iPlant staff developers to build apps.
The following assumes you have created an Agave client via client-create.
We will now ask you to refresh your access token...

API secret [6bA9SOcyi4o8FZ6K9QwN1PYaEkMa]: 
API key [jqcKaswlGH4D5snghfMYfhijQE8a]: 
API username [vaughn]: 
API password: 
Token successfully refreshed and cached for 13150 seconds
ef5f619c98ca45c56d4bc2a29dbc723b

We will now configuring TACC-managed systems and need some info from you
    TACC username
	TACC password
	TACC Project name
	The path to your $WORK directory on TACC systems

Do you have all the information required? [Yes]: 
OK. Let's begin.
Enter your TACC user account []: vaughn
Confirmed: TACC user account is vaughn
Enter your TACC account password []: \n
Enter a TACC project associated with this system [iPlant-Collabs]: 
Confirmed: TACC project is iPlant-Collabs
Enter your TACC work directory []: /work/01374/vaughn
Confirmed: TACC work directory is 
tacc-lonestar4-template
Enrolling private system tacc-lonestar4-template
Successfully added system lonestar4-04012014-1718-vaughn
tacc-maverick-template
Enrolling private system tacc-maverick-template
Successfully added system maverick-04012014-1718-vaughn
tacc-stampede-template
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

The systems with your (in the above case *vaughn*) username are private systems that you can use to develop and run Agave apps. We will cover how to share these with your colleagues and eventually make them fully public elsewhere in our tutorial materials.

*Note* In your current working directory, you will find several JSON files. These contain the descriptions of the private systems created, *including your password for each system*. A future version of Agave will support use of SSH keys in place of directly embedding credentials. Until such time, be very careful with your system description files. Either delete them or set their permissions so that only you can read them:
```sh
chmod 600 *.json
```

Now, verify that you can access your private systems (the ones containing your username) as follows:
*files-list -S maverick-04012014-1718-vaughn* where -S specifies one of your private systems. This should display a listing of your $WORK directory on the specified TACC computer. 

*This completes the section on setting up private iPlant execution systems.*

[Back to READ ME](../README.md) | [Next: Creating an iPlant application for TACC Stampede](iplant-first-app.md)
