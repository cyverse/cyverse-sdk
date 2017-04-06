Setting up CyVerse/TACC development systems
=====================================

Run the ```tacc-systems-create``` command, which will create a private version of Stampede (or Lonestar5 if logged in there) and create a private storage system for you. 

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
apps. The following steps assume you have created or configured
an Agave Oauth2 client on this host.

If you have not, you may exit out of this script and run:

clients-create -S -N "sdk-stampede" -D "OAuth client for TACC system stampede"

The following 'auth-tokens-create' command will
create and store a temporary access token. To refresh
it after it expires, use 'auth-tokens-refresh -S'.

*Create an OAuth2 token*
API password:
```

Enter your CyVerse password.  When prompted in the next steps, you should be able to simply hit the return key to use the default option.  You should see your own TACC username and path instead of *vaughn*.

```sh

*Connect Agave to the 'stampede' HPC system*

The following information will be generated or gathered to
configure this system for access via Agave:

  Your TACC username
  A short alphanumeric key to identify this system
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
```

Our convention is that systems containing your username are private systems that you can use to develop and run Agave apps. We will cover how to share these with your colleagues and eventually make them fully public elsewhere in our tutorial materials.

If you also want to use Lonestar5 for application development or execution, repeat the steps on this page after logging into Lonestar5 via SSH ```ssh ls5.tacc.utexas.edu```

*This completes the section on setting up CyVerse/TACC development systems*

[Back](getting-started.md) |
