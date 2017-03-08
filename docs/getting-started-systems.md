Setting up CyVerse/TACC development systems
=====================================

One interesting feature of Agave is its ability to make use of diverse systems for storing data and executing applications. This offers both an opportunity and a challenge if you come to us from Agave V1 application development. Under the V1 model, there were a limted number of monolithic, shared public systems; you had to get special permission to do app development; and debugging was *painful* because your jobs didn't run under your own username on the host systems. Agave 2.0 opens up additional possibilities by allowing you to enroll your own compute and storage resources, as well as create versions of the resources used by CyVerse. A separate tutorial covers creating your own systems.

A "system" under Agave 2.0 is a combination of login credentials, information about available physical resources, policy descriptions, and configuration options that combine to create an abstraction of a physical computing system. This frees end users from needing to know specific details about the actual computing environment in order to move data to the system and run computing tasks on it.

The following instructions will guide you through setting up Agave-based access to two TACC HPC systems and a private storage system powered by TACC's global file system. 

Because we're bridging CyVerse and [TACC](https://www.tacc.utexas.edu/resources/hpc) systems, you will need some information from both organizations. We assume you are setting up systems at TACC under one of two conditions:

1. You have been added to iPlant-Collabs, a list of Agave app developers for CyVerse who are allowed to log into TACC systems
2. You have your own TACC allocation that allows you to run jobs on Stampede and/or Lonestar5

You will need to log into Stampede and Lonestar5, in succession; install the SDK on each; configure the SDK for access to Agave; and enroll the system you're logged in to. Previous versions of the SDK supported remote setup of TACC HPC and storage systems, but the arrival of increased account security measures at TACC make this infeasible now. 

1. Log in via SSH to Stampede ```ssh stampede.tacc.utexas.edu```
2. Install the SDK as outlined in *[Installing the CyVerse software development kit](install-sdk.md)*
3. Configure the SDK to use your existing Agave OAuth2 client or create a new one as per *[Creating a client and getting a set of API Keys](client-create.md)*
4. Fnally, run the ```tacc-systems-create``` command, which will create a private version of Stampede and a private storage system for you. 

Here is an example of what the script looks like when it runs successfully:

```sh
 _____  _    ____ ____
|_   _|/ \  / ___/ ___|
  | | / _ \| |  | |
  | |/ ___ \ |__| |___
  |_/_/   \_\____\____|

*Cyverse API Enrollment*

This script will register a personal instance of TACC
'stampede' that can be used build and validate Agave
apps. The following steps assume you have configured the
SDK with a valid Agave Oauth2 client key/secret. 

The following 'auth-tokens-create' command will
create and store a temporary access token. To refresh
it after it expires, use 'auth-tokens-refresh -S'.

*Create an OAuth2 token*
API password: 

*Connect Agave to the 'stampede' HPC system*

The following information will be generated or gathered to
configure this system for access via Agave:

  Your TACC username
  A short alphanumeric key to identiy this system
  A SSH keypair for your account on this system
  A TACC Allocation that you have access to
  Path to your TACC $WORK directory

Are you ready to proceed? [Yes]: 

Ensuring existence of an SSH keypair...
Done

Agave system identifier [stampede]: 
Confirmed: stampede

TACC user account [vaughn]: 
Confirmed: vaughn

TACC allocation to be used with this system [iPlant-Collabs]: 
Confirmed: iPlant-Collabs

TACC work directory [/work/01374/vaughn]: 
Confirmed: /work/01374/vaughn
*Registering systems with Agave API*
    Processing template tacc-stampede-compute...
    Processing template tacc-stampede-storage...
Done

Test out private systems you've updated or created today by running a quick files-list operation as illustrated below. You should see the contents of /work/01374/vaughn returned to you after each operation.

    files-list -S tacc-globalfs-vaughn /
    files-list -S tacc-stampede-vaughn /
```

Our convention is that systems containing your username are private systems that you can use to develop and run Agave apps. We will cover how to share these with your colleagues and eventually make them fully public elsewhere in our tutorial materials.

If you also want to use Lonestar5 for application development or execution, repeat the steps on this page after logging into Lonestar5 via SSH ```ssh ls5.tacc.utexas.edu```

*This completes the section on setting up private CyVerse HPC/storage systems.*

[Back](getting-started.md) |
