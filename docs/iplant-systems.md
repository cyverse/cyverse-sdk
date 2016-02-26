Setting up CyVerse development systems
=====================================

One of the most interesting features of the new Agave release is its ability to make use of diverse systems for storing data and executing applications. This offers both an opportunity and a challenge if you come to us from Agave V1 application development. Under the V1 model, there were a limted number of monolithic, shared public systems; you had to get special permission to do app development; and debugging was *painful* because your jobs didn't run under your own username on the host systems. Agave 2.0 opens up additional possibilities by allowing you to enroll your own compute and storage resources, as well as create versions of the resources used by CyVerse. A separate tutorial covers creating your own systems. 

A "system" under Agave 2.0 is a combination of login credentials, information about available physical resources, policy descriptions, and configuration options that combine to create an abstraction of a physical computing system. This frees end users from needing to know specific details about the actual computing environment in order to move data to the system and run computing tasks on it. 

We will now set up private versions of all public systems at TACC that CyVerse uses to power Discovery Environment applications. You can accomplish this manually via the systems-clone and systems-list commands, but we have bundled an automated script with the SDK to make it even more straightforward. You only need to do this once, as the systems created here will be forever associated with your CyVerse credentials.

Because we're bridging CyVerse and [Texas Advanced Computing Center](https://www.tacc.utexas.edu/resources/hpc) systems, you will need information from both organizations. We assume you have been in contact with [CyVerse support staff](mailto:support@iplantcollaborative.org) and asked to be added to our list of Agave app developers who are allowed to log into TACC systems, and we assume you have an active CyVerse account. Gather your CyVerse credentials (specifically your password), your TACC username and password, and the full path to your WORK directory on TACC systems. To find out this last bit of information:
```sh
ssh stampede.tacc.utexas.edu 'echo $WORK'
```

Now, type ```tacc-systems-create``` which will iterate through a set of templates create a new, private version of each TACC system for you. Here's an example log from running this:

```sh
 _____  _    ____ ____
|_   _|/ \  / ___/ ___|
  | | / _ \| |  | |
  | |/ ___ \ |__| |___
  |_/_/   \_\____\____|

*Cyverse API Enrollment*

This script will register personal copies of TACC
systems that can be used build and validate Agave
apps. The following steps assume you have created
an Agave Oauth2 client using 'client-create'.

The following 'auth-tokens-create' command will
create and store a temporary access token. To refresh
it after it expires, use 'auth-tokens-refresh -S'.

*Create an OAuth2 token*
API password: 

*Connect Agave to TACC HPC*

The following information will be gathered in order to
configure TACC-managed HPC systems for
use with the Agave API:

  TACC username
  TACC password
  TACC project name (default: iPlant-Collabs)
  The path to your TACC $WORK directory

Do you have these values at the ready? [Yes]: Yes

OK. Let's begin...

Enter your TACC user account []: myusername
Confirmed: myusername
Enter your TACC account password []: 
Enter a TACC project associated with this system [iPlant-Collabs]: 
Confirmed: iPlant-Collabs
Enter your TACC work directory []: /work/12345/myusername
Confirmed: /work/12345/myusername

*Registering systems with Agave API*

Processing template ...
Processing template tacc-lonestar5-compute...
Processing template tacc-maverick-compute...
Processing template tacc-stampede-compute...

Here are up to 10 recently registered private systems owned by myusername
tacc-lonestar5-myusername
tacc-maverick-myusername
tacc-stampede-myusername
```

The systems with your username are private systems that you can use to develop and run Agave apps. We will cover how to share these with your colleagues and eventually make them fully public elsewhere in our tutorial materials.

Now, verify that you can access your private systems (the ones containing your username) as follows:
*files-list -S tacc-stampede-myusername* where -S specifies one of your private systems. This should display a listing of your $WORK directory on the specified TACC computer. 

*This completes the section on setting up private CyVerse execution systems.*

[Back to READ ME](../README.md) | [Next: Creating an CyVerse application for TACC Stampede](iplant-first-app.md)
