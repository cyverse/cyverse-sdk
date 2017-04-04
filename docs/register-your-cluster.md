# Tutorial: Use Your Own Cluster on CyVerse

The [application development tutorial](app-dev.html) guides developers through the process of creating apps that run on [TACC](https://www.tacc.utexas.edu/) supercomputers, which requires both a TACC account and an active allocation.
Users without an active allocation can request access to the [iPlant-Collabs allocation](getting-started-initial-assumptions.html), which allows developers to *prototype* CyVerse applications.
We stress the word prototype because the iPlant-Collabs allocation is relatively small and shared between all developers, so long-running applications will quickly deplete it for everyone.
This methodology is great to generate new apps, and experience the HPC environment they will run on, but they will always need to be reviewed and published by administrators before they can be run at scale on CyVerse.

This tutorial explains how to register your own cluster with CyVerse to enable:
- Higher job throughput
- Private large-scale applications
- Personal applications dependent on licenses

<script>
function gVal(id) {
	return document.getElementById(id).value;
}
function gInt(id) {
	return parseInt(gVal(id));
}
function updateJSON() {
	// Create systemJSON
	var authObj = {
		username:gVal("username"),
		privateKey:gVal("private").replace(/\n+$/,''),
		publicKey:gVal("public").replace(/\n+$/,''),
		type:"SSHKEYS"
	};
	var systemJSON = {
		description:"Personal executionSystem for "+gVal("name"),
		type:"EXECUTION",
		name:gVal("name"),
		site:gVal("host").split(".").slice(-2).join("."),
		executionType:"HPC",
		startupScript:"./bashrc",
		default:false,
	};
	systemJSON.id = gVal("username")+"-"+gVal("name").replace(/ /g, '-');
	systemJSON.login = {
		port:22,
		protocol:"SSH",
		host:gVal("host"),
		auth:authObj
	};
	systemJSON.queues = [{
		maxProcessorsPerNode:gInt("maxPPN"),
		maxMemoryPerNode:gVal("maxMEM")+"GB",
		name:gVal("queue"),
		maxNodes:gInt("maxNodes"),
		maxRequestedTime:gVal("runtime")+":00:00",
		customDirectives:gVal("directives"),
		default:true
	}];
	systemJSON.maxSystemJobs = gInt("maxJobs");
	systemJSON.scheduler = gVal("scheduler");

	systemJSON.scratchDir = gVal("scratchDir");
	systemJSON.storage = {
		mirror:false,
		port:22,
		homeDir:gVal("homeDir"),
		protocol:"SFTP",
		host:gVal("host"),
		rootDir:"/",
		auth:authObj
	};
	// Insert JSON into HTML
	document.getElementById("outJSON").innerHTML = JSON.stringify(systemJSON, null, 2);
}
</script>

To reinforce why anyone would want to go through the extra effort of registering a system of their own, this guide lays out how to register Indiana University's [Mason](https://kb.iu.edu/d/bbhh) supercomputer as an Agave *[executionSystem](http://developer.agaveapi.co/#execution-systems)*.
Mason is an ideal example because it is [available](https://kb.iu.edu/d/bbhh#account) to all

- IU students, staff, and faculty
- NSF-funded life sciences researchers
- XSEDE researchers

and [each of the 18 nodes](https://kb.iu.edu/d/bbhh#info) also have 512GB of RAM, making it desirable for running memory-hungry software.

## Prerequisites

To create this and any other executionSystem, you will need

- [Login credentials](#login-credentials)
- [Knowledge on how jobs are scheduled](#scheduler-information)
- [System information](#system-information)
- [Storage paths for jobs](#storage-paths)

This guide also contains forms, which populate a valid *executionSystem* JSON at the end.
Editing any field will automatically update the final JSON for you send to Agave.
At no point is any of this information transmitted, so you can safely add your login credentials without worry, but you can always fill in your RSA keys outside of this tutorial.
The inputs to these forms are pre-populated with information about Mason, so you will need to adapt the values and the JSON description for other systems.

### Login Credentials

Whenever you launch a job on CyVerse, Agave uses the main CyVerse user credentials to access TACC systems to run jobs.
Similarly, Agave stores and uses your own personal credentials after running [tacc-systems-create](getting-started-systems.html) while following the CyVerse SDK guide.
So, the first requirement to creating a new *executionSystem* is having `ssh` access to it.
One usually accesses Mason using ssh with the command

```shell
$ ssh user@mason.indiana.edu
```

and then entering their password when prompted.
Agave does support password authentication, but handing your password over to strange systems is generally a bad habit.
Allowing systems to authenticate to your account using ssh keys is much more secure, and makes it impossible for them to change your account password.
Please follow the directions below to generate a set of keys for agave.

```shell
[mason]$ cd ~/.ssh/
[mason]$ ssh-keygen -q -t rsa -b 4096 -C user@email.com -f agave_rsa -N ''
[mason]$ cat agave_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIJKAIBAAKCAgEApQQ+n7AsXzAHqkd+xhkmLTIuhLIYiDGNr4DNuFiV+/LsFKRE
ZyqacqOwf3ZA51C9XcsPLfaglNrBbCiRl70W8z8zybQUdW3hJPjC7qrG2lAJBfjE
BcodjwtR0DVny8JGyWwSdCw6/I4TFxS/+dT6CQ7XoYpfguC8IG4JxbtKxAMaVuAj
.
.
.
Owhcksd0X5swsCLzoivhf+EpALcohwAwR6fbreavprdIJikwDIBs0ruPOZ7nk4nz
OOYL2M7VZ1XdHzg70IvblLDZCOX/sghRPvBZZwdKHVbCDlLBKuOP4CdnZmpCD3Yx
V/qIgePP+LanugxaRdzdZLcQJ7crk1L+3/2McMWaAtNwpvDCk31rQhIVpJE=
-----END RSA PRIVATE KEY-----
[mason]$ cat agave_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAgEApQQ+n7AsXzAHqkd+xhkmLTIuhLIY
iDGNr4DNuFiV+/LsFKREZyqacqOwf3ZA51C9XcsPLfaglNrBbCiRl70W8z8zybQU
dW3hJPjC7qrG2lAJBfjEBcodjwtR0DVny8JGyWwSdCw6/I4TFxS/+dT6CQ7XoYpf
guC8IG4JxbtKxAMaVuAjV1VH+Z7gl+mNu/gbWtX16GD0SCM/C7YY3fPisHDfyJGi
oHMNlcPC+YrHIoRuHphSdCKUImIVzAKkKr8fnayFPXi2aP095OJAdhGhvTrIyCAg
KjeAZFQK4s0HBwmUJR6BK6UwuHw0M95T8aBgSj48vbN53nvTFcnq3ECFCnKdO1F1
Q8f5zen+ExDaExdir3C3ukHf+NR2ZMrOm++YtxLjlYCK/QUj8BN+RFEeQQFBCg6j
6XjitBAKdH49cnYwvxTkbsrC50xiM0V6pVfzsX4LpHjoB+yu5etaT45bcLS5h1TR
8b7mo9ohvseLE9EqAHLhDzmiu9v0VxF3I2txkYfxWS09Syfn7914FYBgF9zQs4hW
lJKIsWo03nTTtZo+z/o+5hzpfJZ61acAM7PtRgXrcGwwnMo5N45CrNj17yfzsKFN
hoYscep6R3el6jxsjSxA+/JYawkZtg3dnKhG5XXQW1+SrQVwbh7u+p+5wMtQhVss
32h20jr/+hHKb8U= user@email.com
```

Your public key now needs to be added to your authorized key file for automatic authentication.

```
[mason]$ cat agave_rsa.pub >> ~/.ssh/authorized_keys
```

Copy your **entire** private key (agave\_rsa), including the `---` header and footer, and paste into the corresponding field below. Do the same with your public key (agave\_rsa.pub), including the "ssh-rsa" and your email at the end.

| Description | Value |
|--|--|
| Cluster Name | <input type="text" id="name" style="width:300px; box-sizing:border-box;" value="IU mason" oninput="updateJSON()"> |
| SSH address | <input type="text" id="host" style="width:300px; box-sizing:border-box;" value="mason.indiana.edu" oninput="updateJSON()"> |
| Username | <input type="text" id="username" style="width:300px; box-sizing:border-box;" value="user" oninput="updateJSON()"> |
| Private Key | <textarea id="private" rows="10" style="width:300px; box-sizing:border-box;" oninput="updateJSON()"></textarea> |
| Public Key | <textarea id="public" rows="5" style="width:300px; box-sizing:border-box;" oninput="updateJSON()"></textarea> |

Remember, if you ever want to revoke Agave's access to your system, you only need to

```shell
[mason]$ rm ~/.ssh/agave_rsa*
```

to permanently delete the keys from the system. After granting basic access, Agave will need specific knowledge about the cluster itself.

### Scheduler Information

When Agave runs a job on CyVerse, it submits a job to the SLURM schedulers at TACC. Agave needs to know what scheduler your cluster runs, which queue, and any other necessary accounting information.
The SLURM scheduler on Stampede enforces [many rules](https://portal.tacc.utexas.edu/user-guides/stampede#running-slurm-queue) to ensure that user experiences are fair and consistent.
[Mason](https://kb.iu.edu/d/bbhh#info) doesn't have as many, but it is good practice to know the constraints of each system you use.

| Description | Value |
|--|--|
| Scheduler | <select id="scheduler" onchange="updateJSON()"><option value="TORQUE">TORQUE</option><option value="MOAB">MOAB</option><option value="SLURM">SLURM</option><option value="LSF">LSF</option><option value="LOADLEVELER">LOADLEVELER</option><option value="PBS">PBS</option><option value="SGE">SGE</option><option value="FORK">FORK</option><option value="COBALT">COBALT</option></select> |
| Max Jobs | <input type="number" id="maxJobs" min="-1" max="100" value="50" oninput="updateJSON()"> |
| Queue | <input type="text" id="queue" style="width:200px; box-sizing:border-box;" value="batch" oninput="updateJSON()"> |
| Max Nodes | <input type="number" id="maxNodes" min="-1" max="1000" value="18" oninput="updateJSON()"> |
| Max Runtime (hours) | <input type="number" id="runtime" min="-1" max="120" value="48" oninput="updateJSON()"> |
| Custom queue directives | <input type="text" id="directives" style="width:200px; box-sizing:border-box;" value="" oninput="updateJSON()"> |

You technically can register a single workstation to Agave by setting the *executionType* to `CLI`, but this guide is looking to enable large-scale computing, so the automatic JSON is built to register a cluster.

### System Information

Agave also needs information on the physical configuration of each compute node in your desired queue so resources, so resources can never be over-requested by a job.

| Description | Value |
|--|--|
| Max Processors per Node | <input type="number" id="maxPPN" min="-1" max="128" value="32" oninput="updateJSON()"> |
| Max Memory per Node (GB) | <input type="number" id="maxMEM" min="-1" max="4000" value="512" oninput="updateJSON()"> |

### Storage Paths

Lastly, Agave needs to know what paths to use for storing job data each time an app is run.
Before submitting to a scheduler, Agave first stages all app (binaries) and input data in a folder unique to that job.
This folder is created in a location relative to a directory you choose.
The *executionSystem* home path should be set to your `$HOME` directory so Agave can find your `.bashrc` and properly load your environment.
You should also set your scratch path to a directory with a lot of storage and also capable of handling a significant i/o load. At TACC, we would set it to the `$SCRATCH` directory, but IU uses the [Data Capacitor](https://kb.iu.edu/d/avvh) found at `/N/dc2/scratch/user` for scratch (no quota and temporary) space. Jobs are stored in the following layout:

```
scratchDir/
|- user1
   |- job0001
   \- job0002
|- user2
   \- job0005
\- user3    
   |- job0006
   \- job0010
```

To reduce clutter in the root of your personal folder, you should create a CyVerse folder

```shell
[mason]$ mkdir /N/dc2/scratch/user/CyVerse
```

for Agave to store user and job directories in. In the fields below, please change `user` to your own username, or change the locations to a more preferable directory.

| Description | Value |
|--|--|
| Home path | <input type="text" id="homeDir" style="width:200px; box-sizing:border-box;" value="/N/u/user/Mason" oninput="updateJSON()"> |
| Scratch path | <input type="text" id="scratchDir" style="width:200px; box-sizing:border-box;" value="/N/dc2/scratch/user/CyVerse" oninput="updateJSON()"> |

<br>
<div class="language-json highlighter-rouge"><pre class="highlight"><code id="outJSON"></code></pre></div>
<script>updateJSON();</script>

## Registering with Agave

Assuming you have a working version of the [CyVerse SDK](https://github.com/cyverse/cyverse-sdk), you just need to copy the JSON above into a file on your system. In the example below, we copied and pasted it into the file `user-mason.json`.

```shell
[mason]$ auth-tokens-refresh -S
Token for iplantc.org:user successfully refreshed and cached for 14400 seconds
45098349583490859034859304859043

[mason]$ systems-addupdate -F user-mason.json
Successfully added system user-IU-mason

[mason]$ systems-list -Q
user-IU-mason
```

Assuming you successfully added your new Mason system, you can quickly test it by listing the files in your home directory. If this does not work, double-check that your password is correct and consistent in both `auth` sections of the JSON file.

```shell
[mason]$ files-list -S user-IU-mason .
.
.bash_history
.bash_logout
.bash_profile
.bashrc
.forward
.history
.lesshst
.local
.modulesbeginenv
.mozilla
.ssh
.vim
.viminfo
.Xauthority
454AllContigs.fna
blastScript.sh
blatScript.sh
combineFiles.sh
gzipFiles.sh
hs_err_pid1987.log
runBlast.py
runBlat.py
scripts
scripts_backup.tar.gz
software
splitFiles.sh
tmp
trinity-avo.sh

[mason]$ ls -a ~
.                  .forward            scripts
..                 gzipFiles.sh        scripts_backup.tar.gz
454AllContigs.fna  .history            software
.bash_history      hs_err_pid1987.log  splitFiles.sh
.bash_logout       .lesshst            .ssh
.bash_profile      .local              tmp
.bashrc            .modulesbeginenv    trinity-avo.sh
blastScript.sh     .mozilla            .vim
blatScript.sh      runBlast.py         .viminfo
combineFiles.sh    runBlat.py          .Xauthority
```

Your new Mason *executionSystem* is ready for use!

[Back to Overview](../README.md) |
