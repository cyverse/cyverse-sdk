Creating an iPlant application for TACC Stampede
================================================

We will now go through the process of building and deploying an Agave application to provide 'samtools sort' functionality on TACC's Stampede system. The following tutorial assumes you have properly installed and configured the iPlant SDK on Stampede. They assume you have defined an environment variable IPLANTUSERNAME as your iPlant username. For example:
export IPLANTUSERNAME=<youriplantusername>

Agave application packaging
---------------------------
Agave API apps have a generalized structure that allows them to carry dependencies around with them. In the case below, _package-name-version.dot.dot_ is a folder that you build on your local system, then store in the iPlant Data Store in a designated location (we recommend /iplant/home/IPLANTUSERNAME/applications/APPFOLDER). It contains binaries, support scripts, test data, etc. all in one package. Agave basically uses a very rough form of containerized applications (more on this later). We suggest you set your apps up to look something like the following:

```sh
package-name-version.dot.dot
|--system_name
|----bin.tgz (optional)
|----lib.tgz (optional)
|----include.tgz (optional)
|----test.sh
|----script.template
|----test_data (optional)
|----app.json
```

Agave runs a job by first transferring a copy of this directory into temporary directory on the target executionSystem. Then, the input data files (we'll show you how to specify those are later) are staged into place automatically. Next, Agave writes a scheduler submit script (using a template you provide i.e. script.template) and puts it in the queue on the target system. The Agave service then monitors progress of the job and, assuming it completes, copies all newly-created files to the location specified when the job was submitted. Along the way, critical milestones and metadata are recorded in the job's history. 

*Agave app development proceeds via the following steps:*

1. Build the application locally on the executionSystem
2. Ensure that you are able to run it directly on the executionSystem
3. Describe the application using an Agave app description
4. Create a shell template for running the app
5. Upload the application directory to a storageSystem
6. Post the app description to the Agave apps service
7. Debug your app by running jobs and updating the app until it works as intended
8. (Optional) Share the app with some friends to let them test it

Build a samtools application bundle
------------------------------------
```sh
# Log into Stampede 
ssh stampede.tacc.utexas.edu

# Unload system's samtools module if it happens to be loaded by default
module unload samtools

# All TACC systems have a directory than can be accessed as $WORK
cd $WORK

# Set up a project directory
mkdir iPlant
mkdir iPlant/src
mkdir -p iPlant/samtools-0.1.19/stampede/bin
mkdir -p iPlant/samtools-0.1.19/stampede/test

# Build samtools using the Intel C Compiler
# If you don't have icc, gcc will work but icc usually gives more efficient binaries
cd iPlant/src
wget "http://downloads.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2"
tar -jxvf samtools-0.1.19.tar.bz2
cd samtools-0.1.19
make CC=icc

# Copy the samtools binary and support scripts to the project bin directory
cp -R samtools bcftools misc ../../samtools-0.1.19/stampede/bin/
cd ../../samtools-0.1.19/stampede

# Test that samtools will launch
bin/samtools

	Program: samtools (Tools for alignments in the SAM format)
	Version: 0.1.19-44428cd
	
	Usage:   samtools <command> [options]
	
	Command: view        SAM<->BAM conversion
	         sort        sort alignment file
	         mpileup     multi-way pileup...

# Package up the bin directory as an compressed archive 
# and remove the original. This preserves the execute bit
# and other permissions and consolidates movement of all
# bundled dependencies in bin to a single operation. You
# can adopt a similar approach with lib and include.
tar -czf bin.tgz bin && rm -rf bin
```

Run samtools sort locally
-------------------------
Your first objective is to create a script that you know will run to completion under the Stampede scheduler and environment (or whatever executionSystem you're working on). It will serve as a model for the template file you create later. In our case, we need to write a script that can be submitted to the Slurm scheduler. The standard is to use Bash for such scripts. You have five main objectives in your script:
* Unpack binaries from bin.tgz
* Extend your PATH to contain bin
* Craft some option-handling logic to accept parameters from Agave
* Craft a command line invocation of the application you will run
* Clean up when you're done

First, you will need some test data in your current directory (i.e., $WORK/iPlant/samtools-0.1.19/stampede/ ). You can use this test file
```sh
files-get -S data.iplantcollaborative.org /shared/iplantcollaborative/example_data/Samtools_mpileup/ex1.bam
```
or you can any other BAM file for your testing purposes. Make sure if you use another file to change the filename in your test script accordingly!

Now, author your script. You can paste the following code into a file called *test-sort.sh* or you can copy it from $IPLANT_SDK_HOME/examples/samtools-0.1.19/stampede/test-sort.sh

```sh
#!/bin/bash
 
# Agave automatically writes these scheduler
# directives when you submit a job but we have to
# do it by hand when writing our test

#SBATCH -p development
#SBATCH -t 00:30:00
#SBATCH -n 16
#SBATCH -A iPlant-Collabs 
#SBATCH -J test-samtools
#SBATCH -o test-samtools.o%j

# Set up inputs and parameters
# We're emulating passing these in from Agave
# inputBam is the name of the file to be sorted
inputBam="ex1.bam"
# outputPrefix is a parameter that establishes
# the prefix for the final sorted file
outputPrefix="sorted"
# Parameter for memory used in sort operation, in bytes
maxMemSort=500000000
# Boolean: Sort by name instead of coordinate
nameSort=0

# Unpack the bin.tgz file containing samtools binaries
# If you are relying entirely on system-supplied binaries 
# you don't need this bit
tar -xvf bin.tgz
# Extend PATH to include binaries in bin
# If you need to extend lib, include, etc 
# the same approach is applicable
export PATH=$PATH:"$PWD/bin"

# Dynamically construct a command line
# by building an ARGS string then
# adding the command, file specifications, etc
#
# We're doing this in a way familar to Agave V1 users
# first. Later, we'll illustrate how to make use of
# Agave V2's new parameter passing functions
#
# Start with empty ARGS...
ARGS=""
# Add -m flag if maxMemSort was specified
# You might want to add a constraint for how large maxMemSort
# can be based on the available memory on your executionSystem
if [ ${maxMemSort} -gt 0 ]; then ARGS="${ARGS} -m $maxMemSort"; fi

# Boolean handler for -named sort
if [ ${nameSort} -eq 1 ]; then ARGS="${ARGS} -n "; fi
 
# Run the actual program
samtools sort ${ARGS} ${inputBam} ${outputPrefix}

# Now, delete the bin/ directory
rm -rf bin
```
### Submit the job to the queue on Stampede...
```sh
chmod 700 test-sort.sh 
sbatch test-sort.sh 
```
You can monitor your jobs in the queue using 
```sh
showq -u your_tacc_username
```
Assuming all goes according to plan, you'll end up with a sorted BAM called *sorted.bam*, and your bin directory (but not the bin.tgz file) should be erased. Congratulations, you're in the home stretch: it's time to turn the test script into an Agave app.

Craft an Agave app description 
-------------------------------
In order for Agave to know how to run an instance of the application, we need to provide quite a bit of metadata about the application. This includes a unique name and version, the location of the application bundle, the identities of the execution system and destination system for results, whether its an HPC or other kind of job, the default number of processors and memory it needs to run, and of course, all the inputs and parameters for the actual program. It seems a bit over-complicated, but only because you're comfortable with the command line already. Your goal here is to allow your applications to be portable across systems and present a web-enabled, rationalized interface for your code to consumers.

Rather than have you write a description for "samtools sort" from scratch, let's systematically dissect an existing file provided with the SDK. Go ahead and copy the file into place and open it in your text editor of choice. If you don't have the SDK installed, you can [grab it here](../examples/samtools-0.1.19/stampede/samtools-sort.json).
```sh
cd $WORK/iPlant/samtools-0.1.19/stampede/
cp $IPLANT_SDK_HOME/examples/samtools-0.1.19/stampede/samtools-sort.json .
```
Open up samtools-sort.json in a text editor or [in your web browser](../examples/samtools-0.1.19/stampede/samtools-sort.json) and follow along below.

### Overview

Your file *samtools-sort.json* is written in [JSON](http://www.json.org/), and conforms to an Agave-specific data model. You can find fully fleshed out details about all fields under *Parameters -> Data Type -> Model* at the [Agave API live docs on the /apps service](http://agaveapi.co/live-docs/#!/apps/add_post_1). We will dive into key elements here:

To make this file work for you, you will be, at a minimum, editting:

1. Its *executionSystem* to match your private instance of Stampede.
2. Its *deploymentPath* to match your iPlant applications path
3. The *name* of the app to something besides "samtools-sort". We recommend "$IPLANTUSERNAME-samtools-sort". 

Instructions for making these changes will follow.

All Agave application descriptions have the following structure:

```json
{	"application_metadata":"value",
	"inputs":[],
	"parameters":[],
	"outputs":[]
}
```

There is a defined list of application metadata fields, some of which are mandatory. Inputs, parameters, and outputs are specified as an array of simple data structures, which will be described below.

### Application metadata

| Field | Mandatory | Type | Description |
| ----- | --------- | ---- | ----------- |
| checkpointable | X | boolean | Application supports checkpointing |
| defaultMemoryPerNode | | integer | Default RAM (GB) to request per compute node |
| defaultProcessorsPerNode | | integer | Default processor count to request per compute node |
| defaultMaxRunTime | | integer | Default maximum run time (hours:minutes:seconds) to request per compute node |
| defaultNodeCount | | integer | Default number of compute nodes per job |
| defaultQueue | | string | On HPC systems, default batch queue for jobs |
| deploymentPath | X | string | Path relative to homeDir on deploymentSystem where application bundle will reside |
| deployementSystem | X | string | The Agave-registered STORAGE system upon which you have write permissions where the app bundle resides |
| executionSystem | X | string | An Agave-registered EXECUTION system upon which you have execute and app registration permissions where jobs will run |
| helpURI | X | string | A URL pointing to help or description for the app you are deploying |
| label | X | string | Human-readable title for the app |
| longDescription | | string | A short paragraph describing the functionality of the app |
| modules | | array[string] | Ordered list of modules on systems that use lmod or modules |
| name | X | string | unique, URL-compatible (no special chars or spaces) name for the app |
| ontology | X | array[string] | List of ontology terms (or URIs pointing to ontology terms) associated with the app |
| parallelism | X | string | Is your application capable of using more than a single compute node? (SERIAL or PARALLEL) |
| shortDescription | X | string | Brief description of the app |
| storageSystem | X | string | The Agave-registered STORAGE system upon which you have write permissions. Default source of and destination for data consumed and emitted by the app |
| tags | | array[string] | List of human-readable tags for the app |
| templatePath | X | string | Path to the shell template file, relative to deploymentPath |
| testPath | X | string | Path to the shell test file, relative to deploymentPath |
| version | X | string | Preferred format: Major.minor.point integer values for app |

* Note *: The combination of *name* and *version* must be unique the entire iPlant API namespace. 

### Inputs

To tell Agave what files to stage into place before job execution, you need to define the app's inputs in a JSON array. To implement the SAMtools sort app, you need to tell Agave that a BAM file is needed to act as the subject of our sort:

```json
   {"id":"inputBam",
     "value":
        {"default":"input.bam",
         "order":0,
         "required":true,
         "validator":"([^\\s]+(\\.(?i)(bam))$)",
         "visible":true},
     "semantics":
        {"ontology":["http://sswapmeet.sswap.info/mime/application/X-bam"],
         "minCardinality":1,
         "fileTypes":["raw-0"]},
     "details":
        {"description":"",
         "label":"The BAM file to sort",
         "argument":null,
         "showArgument":false}}]
```

Here's a walkthrough of what these fields mean:

| Field | Mandatory | Type | Description |
| ----- | --------- | ---- | ----------- |
| id | X | string | This is the "name" of the file. You will use this in your wrapper script later whenever you need to refer to the BAM file being sorted |
| value.default | | string | The path, relative to X, of the default value for the input |
| value.order | | integer | Ignore for now |
| value.required | X | boolean | Is specification of this input mandatory to run a job? |
| value.validator | | string | [Python-formatted regular expression](https://docs.python.org/2/library/re.html) to restrict valid values |
| value.visible | | boolean | When automatically generated a UI, should this field be visible to end users? |
| semantics.ontology | | array[string] | List of ontology terms (or URIs pointing to ontology terms) applicable to the input format |
| semantics.minCardinality | | integer | Minimum number of values accepted for this input |
| semantics.maxCardinality | | integer | Maximum number of values accepted for this input |
| semantics.fileTypes | X | array[string] | List of Agave file types accepted. Always use "raw-0" for the time being |
| details.description | | string | Human-readable description of the input. Often implemented as contextual help in automatically generated UI |
| details.label | | string | Human-readable label for the input. Often implemented as text label next to the field in automatically generated UI |
| details.argument | | string | The command-line argument associated with specifying this input at run time |
| details.showArgument | | boolean | Include the argument in the substitution done by Agave when a run script is generated |

*A note on paths*: In this iPlant-oriented tutorial, we assume you will stage data to and from "data.iplantcollaborative.org", the default storage system for iPlant users. In this case, you can use relative paths relative to homeDir on that system (i.e. vaughn/analyses/foobar). To add portability, marshal data from other storageSystems, or import from public servers, you can also specify fully qualified URIs as follows:
* storageSystem namespace: agave://storage-system-name/path/to/file
* public URI namespace: https://www.cnn.com/index.html

### Parameters

Parameters are specified in a JSON array, and are broadly similar to inputs. Here's an example of the parameter we will define allowing users to specify how much RAM to use in a "samtools sort" operation.

```json
    {"id":"maxMemSort",
     "value":
        {"default":500000000,
         "order":1,
         "required":true,
         "type":"number",
         "validator":"",
         "visible":true},
     "semantics":
        {"ontology":["xs:integer"]},
     "details":
        {"description":null,
         "label":"Maxiumum memory in bytes, used for sorting",
         "argument":"-m",
         "showArgument":false}},
```

| Field | Mandatory | Type | Description |
| ----- | --------- | ---- | ----------- |
| id | X | string | This is the "name" of the parameter. At runtime, it will be replaced in your script template based on the value passed as part of the job specification |
| value.default | | string | If your app has a fixed-name output, specify it here |
| value.order | | integer | Ignore for now. Supports automatic generation of command lines. |
| value.required | | boolean | Is specification of this parameter mandatory to run a job?  |
| value.type | | string | JSON type for this parameter (used to generate and validate UI). Valid values: "string", "number", "enumeration", "bool", "flag" |
| value.validator | | string | [Python-formatted regular expression](https://docs.python.org/2/library/re.html) to restrict valid values |
| value.visible | | boolean | When automatically generated a UI, should this field be visible to end users? |
| semantics.ontology | | array[string] | List of ontology terms (or URIs pointing to ontology terms) applicable to the parameter. We recommend at least specifying an [XSL Schema Simple Type](http://www.schemacentral.com/sc/xsd/s-datatypes.xsd.html). |
| details.description | | string | Human-readable description of the parameter. Often used to create contextual help in automatically generated UI |
| details.label | | string | Human-readable label for the parameter. Often implemented as text label next to the field in automatically generated UI |
| details.argument | | string | The command-line argument associated with specifying this parameter at run time |
| details.showArgument | | boolean | Include the argument in the substitution done by Agave when a run script is generated |


### Outputs

While we don't support outputs 100% yet, Agave apps are designed to participate in workflows. Thus, just as we define the list of valid and required inputs to an app, we also must (when we know them) define a list of its outputs. This allows it to "advertise" to consumers of Agave services what it expects to emit, allowing apps to be chained together. Note that unlike inputs and parameters, output "id"s are NOT passed to the template file.  If you must specify an output filename in the application json, do it as a parameter!  Outputs are defined basically the same way as inputs:

```json
{"id":"bam",
     "value":
        {"default":"sorted.bam",
         "order":0,
         "required":false,
         "validator":"",
         "visible":true},
     "semantics":
        {"ontology":["http://sswapmeet.sswap.info/mime/application/X-bam"],
         "minCardinality":1,
         "fileTypes":["raw-0"]},
     "details":
        {"description":"",
         "label":"Sorted BAM file",
         "argument":null,
         "showArgument":false}}
```

Obligatory field walk-through:

| Field | Mandatory | Type | Description |
| ----- | --------- | ---- | ----------- |
| id | X | string | This is the "name" of the output. It is not currently used by the wrapper script but may be in the future|
| value.default | | string | If your app has a fixed-name output, specify it here |
| value.order | | integer | Ignore for now |
| value.required | X | boolean | Is specification of this input mandatory to run a job? |
| value.validator | | string | [Python-formatted regular expression](https://docs.python.org/2/library/re.html) to restrict valid values |
| value.visible | | boolean | When automatically generated a UI, should this field be visible to end users? |
| semantics.ontology | | array[string] | List of ontology terms (or URIs pointing to ontology terms) applicable to the output format |
| semantics.minCardinality | | integer | Minimum number of values expected for this output |
| semantics.maxCardinality | | integer | Maximum number of values expected for this output |
| semantics.fileTypes | X | array[string] | List of Agave file types that may apply to the output. Always use "raw-0" for the time being |
| details.description | | string | Human-readable description of the output |
| details.label | | string | Human-readable label for the output |
| details.argument | | string | The command-line argument associated with specifying this output at run time (not currently used) |
| details.showArgument | | boolean | Include the argument in the substitution done by Agave when a run script is generated (not currently used) |

*Note*: If the app you are working on doesn't natively produce output with a predictable name, one thing you can do is add extra logic to your script to take the existing output and rename it to something you can control or predict. 

### Tools and Utilities
1. Stumped for ontology terms to apply to your Agave app inputs, outputs, and parameters? SSWAPmeet has many URI-format terms for [MIME](http://sswapmeet.sswap.info/mime/) types, and BioPortal can provide links to [EDAM](http://bioportal.bioontology.org/ontologies/EDAM). 
2. Need to validate JSON files? Try [JSONlint](http://jsonlint.com/) or [JSONparser](http://json.parser.online.fr/)

Craft a shell script template
-----------------------------
Create sort.template using your test-sort.sh script as the starting point.  

```sh
cp test-sort.sh sort.template
```

Now, open sort.template in the text editor of your choice. Delete the bash shebang line and the SLURM pragmas. Replace the hard-coded values for inputs and parameters with variables defined by your app description.

```sh
# Set up inputs...
# Since we don't check these when constructing the
# command line later, these will be marked as required
inputBam=${inputBam}
# and parameters
outputPrefix=${outputPrefix}
# Maximum memory for sort, in bytes
# Be careful, Neither Agave nor scheduler will
# check that this is a reasonable value. In production
# you might want to code min/max for this value
maxMemSort=${maxMemSort}
# Boolean: Sort by name instead of coordinate
nameSort=${nameSort}

# Unpack the bin.tgz file containing samtools binaries
tar -xvf bin.tgz
# Set the PATH to include binaries in bin
export PATH=$PATH:"$PWD/bin"
 
# Build up an ARGS string for the program
# Start with empty ARGS...
ARGS=""
# Add -m flag if maxMemSort was specified
if [ ${maxMemSort} -gt 0 ]; then ARGS="${ARGS} -m $maxMemSort"; fi

# Boolean handler for -named sort
if [ ${nameSort} -eq 1 ]; then ARGS="${ARGS} -n "; fi
 
# Run the actual program
samtools sort ${ARGS} $inputBam ${outputPrefix}

# Now, delete the bin/ directory
rm -rf bin
```
Storing an app bundle on a storageSystem
----------------------------------------
Each time you (or another user) requests an instance of samtools sort, Agave copies data from a "deploymentPath" on a "storageSystem" as part of creating the temporary working directory on an "executionSystem". Now that you've crafted the application bundle's dependencies and script template, it's time to store it somewhere accessible by Agave. 

*Note* If you've never deployed an Agave-based app, you may not have an applications directory in your home folder. Since this is where we recommend you store the apps, create one.
```sh
# Check to see if you have an applications directory
files-list -S data.iplantcollaborative.org $IPLANTUSERNAME/applications
# If you see: File/folder does not exist
# then you need to create an applications directory
files-mkdir -S data.iplantcollaborative.org -N "applications" $IPLANTUSERNAME/
```

Now, go ahead with the upload:
```sh
# cd out of the bundle
cd $WORK/iPlant
# Upload using files-upload
files-upload -S data.iplantcollaborative.org -F samtools-0.1.19 $IPLANTUSERNAME/applications
```

Post the app description to Agave
---------------------------------

As mentioned in the overview, several personalizations to samtools-sort.json are required.  Specifically, edit the samtools-sort.json file to change:
* the *executionSystem* to your private Stampede system, 
* the *deploymentPath* to your own iPlant applications directory for samtools
* the *name* to *$IPLANTUSERNAME-samtools-sort*

Post the JSON file to Agave's app service.
```sh
apps-addupdate -F samtools-0.1.19/stampede/samtools-sort.json
```

*Note*: If you see this error "Permission denied. An application with this unique id already exists and you do not have permission to update this application. Please either change your application name or update the version number", you forgot to change the name or the name you chose conflicts with another Agave application. Change it again in the JSON file and resubmit. 

### Updating your application metadata or bundle

Any time you need to update the metadata description of your non-public application, you can just make the changes locally to the JSON file and and re-post it. The next time Agave creates a job using this application, it will use the new description.

```sh
apps-addupdate -F samtools-0.1.19/stampede/samtools-sort.json $IPLANTUSERNAME-samtools-sort-0.1.19
```

The field *$IPLANTUSERNAME-samtools-sort-0.1.19* at the end is the appid you're updating. Agave tries to guess from the JSON file but to remove uncertainty, we recommend always specifying it explicitly. 

Any time you need to update the binaries, libraries, templates, etc. in your non-public application, you can just make the changes locally and re-upload the bundle. The next time Agave creates a job using this application, it will stage the updated version of the application bundle into place on the executionSystem and it to complete your task. It's a little more complicated to deal with fully public apps, and so we'll cover that in a separate document. 

Verify your new app description
-------------------------------

First, you may check to see if your new application shows up in the bulk listing:

```sh
# Shows all apps that are public, private to you, or shared with you
apps-list 
# Show all apps on a specific system that are public, private to you, or shared with you
apps-list -S stampede.tacc.utexas.edu
# Show only your private apps
apps-list --privateonly
```

You should see *your new app ID* in "apps-list" and "apps-list --privateonly" but not "apps-list -S stampede.tacc.utexas.edu". Why do you think this is the case? Give up? It's because your new app is not registered to the public iPlant-maintained executionSystem called "stampede.tacc.utexas.edu" and so is filtered from display. 

You can print a detailed view, in JSON format, of any app description to your screen:

```sh
apps-list -v APP_ID
```

Take some time to review how the app description looks when printed from app-list relative to how it looked as a JSON file in your text editor. There are likely some additional fields present (generated by the Agave service) and the presentation may differ from your expectation. Understanding the relationship between what the service returns and the input data structure is crucial for being able to debug effectively.

*This completes the section on creating and enrolling your own simple application.*

[Back to READ ME](../README.md) | [Next: Running a job using your Agave app](iplant-first-app-job.md)
