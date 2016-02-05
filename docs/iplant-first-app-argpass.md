Crafting applications using Agave argument passing
==================================================
Agave now supports limited forms of automatic command line generation. We will demonstrate how to take advantage of it.

Background
----------
One great challenge in wrapping command line programs in abstraction layers is the incredible diversity in the way they are parameterized. Some use --long flags, some use Java-style KEY=VALUE pairs, some use config.files, and so on. iPlant's Discovery Environment provides a sophisticated, fully-automated command line builder, while previous releases of Agave required that you painstakingly handle every command flag in your template script. The former approach is great when it works, and leads to rapid application development, but is a challenge for a solid 40% of applications. The latter approach provides perfect flexibility at the price of requiring the app developer to write a lot of (often repetitive) conditional shell script code. Agave V2 includes new features to help streamline this process. To use them, you need to make subtle changes to your template script and modify your input, parameter, and output definitions a bit. 

Technical Details
-----------------
When the Agave service creates an execution script on the executionSystem, it takes the app's template file and performs find-and-replace substitutions, replacing variables matching input.id, parameter.id, and output.id in the template with values passed as part of the job invocation process. The original implementation of Agave dropped in just the value, and it was up to developers to specify the command flag. Now, you may specify, in your app description, a value for "input.details.argument" indicating (if needed) a leading command flag. If you then specify *"input.details.showArgument": true*, when the execution script is created it will replace ${input.id} in the template with "argument value" instead of just "value". The same applies to parameters. Here's a simple example to illustrate how to craft a specific command line:

```sh
# Here's a silly command that we want to run as part of our job
a.out --input foobaz.txt --beastmode --over 9000 --powerlevel --dragonball=Z > stdout.txt
```

### Template file
```sh
ARGS="--beastmode ${keyvalParam} ${flagParam}"
if [ -n "${manualKeyvalParam}" ]; then ARGS="$ARGS --dragonball=${manualKeyvalParam}"
a.out ${inputFile} $ARGS > stdout.txt
```

### Input specification
```json
{"inputs":[
    {"id":"inputFile",
     "value":
        {"default":"shared/foobaz.txt",
         "order":0,
         "required":true,
         "validator":".txt$",
         "visible":true},
     "semantics":
        {"ontology":["http://sswapmeet.sswap.info/mime/text/Plain"],
         "minCardinality":1,
         "fileTypes":["raw-0"]},
     "details":
        {"description":"",
         "label":"The Text File",
         "argument":"--input ",
         "showArgument":true}}]}
```

### Parameters
```json
{"parameters":[
    {"id":"keyvalParam",
     "value":
        {"default":"9000",
         "order":1,
         "required":true,
         "type":"number",
         "validator":"",
         "visible":true},
     "semantics":
        {"ontology":["xs:integer"]},
     "details":
        {"description":null,
         "label":"An innumerable quantifier",
         "argument":"--over ",
         "showArgument":true}},
	{"id":"manualKeyvalParam",
     "value":
        {"default":"Z",
         "order":1,
         "required":false,
         "type":"string",
         "validator":"",
         "visible":true},
     "semantics":
        {"ontology":["xs:string"]},
     "details":
        {"description":"",
         "label":"Which Dragonball are you?",
         "argument":"",
         "showArgument":false}},
    {"id":"flagParam",
     "value":
        {"default":false,
         "order":1,
         "required":false,
         "type":"flag",
         "validator":"",
         "visible":true},
     "semantics":
        {"ontology":["xs:boolean"]},
     "details":
        {"description":null,
         "label":"Refers to power level",
         "argument":"--powerlevel",
         "showArgument":true}}]}
```

### Resulting execution script
```sh
ARGS="--beastmode --over 9000 --powerlevel  --dragonball=Z"
a.out --input foobaz.txt ${ARGS} > stdout.txt
```

### Explanatory notes
1. Use of the "flag" type for flagParam: If the value at run time is true, the argument value is passed in and used for authoring the execution script, otherwise it is not. 
2. Static ARGS: We always want to run a.out in Beast Mode. This could be modeled as an immutable, invisible parameter, but can also just be hard-coded into the ARGS string.
3. Mixing passed-arguments with manually-handled parameters: This use case is illustrated by the handling of our "dragonball" parameter.
4. Note the trailing spaces on arguments for inputFile and keyvalParam. Agave concatenates argument and value without automatically adding any whitespace. This allows you to construct arguments that look like --ion_cannon=low-orbit

Implementation: "samtools sort" using argument passing
-------------------------------------------------------

Here we show the updated files for "samtools sort" using argument passing.  The two files updated are samtools-sort.json and sort.template.  The job file, samtools-sort-02-job.json, did not need to be modified but is shown for completeness.  

### samtools-sort.json

In our previous example of samtools-sort.json, showArgument was set to "false" for each parameter.  Seen below, it is now set to "true" for the parameter maxMemSort.  In addition, we've added the ability to specify the output filename, outputBam, which will also use argument passing.

```sh
{"available":true,
 "checkpointable":false,
 "defaultMemoryPerNode":32,
 "defaultProcessorsPerNode":16,
 "defaultMaxRunTime":"08:00:00",
 "defaultNodeCount":1,
 "defaultQueue":"serial",
 "deploymentPath":"jcarson/applications/samtools-0.1.19/stampede",
 "deploymentSystem":"data.iplantcollaborative.org",
 "executionSystem":"stampede-04242014-1023-jcarson",
 "executionType":"HPC",
 "helpURI":"http://samtools.sourceforge.net/samtools.shtml",
 "label": "SAMtools sort",
 "longDescription":"",
 "modules":[],
 "name":"jcarson-samtools-sort",
 "ontology":["http://sswapmeet.sswap.info/agave/apps/Application"],
 "parallelism":"SERIAL",
 "shortDescription":"Sort a BAM file by name or coordinate",
 "tags":["aligner","NGS","SAM"],
 "templatePath":"sort.template",
 "testPath":"test-sort.sh",
 "version":"0.1.19",
 "inputs":[
    {"id":"inputBam",
     "value":
        {"default":"",
         "order":0,
         "required":true,
         "validator":".bam$",
         "visible":true},
     "semantics":
        {"ontology":["http://sswapmeet.sswap.info/mime/application/X-bam"],
         "minCardinality":1,
         "fileTypes":["raw-0"]},
     "details":
        {"description":"",
         "label":"The BAM file to sort",
         "argument":null,
         "showArgument":false}}],
 "parameters":[
   {"id":"maxMemSort",
     "value":
        {"default":"500000000",
         "order":1,
         "required":true,
         "type":"number",
         "validator":"",
         "visible":true},
     "semantics":
        {"ontology":["xs:integer"]},
     "details":
        {"description":null,
         "label":"Maximum memory in bytes, used for sorting",
         "argument":"-m ",
         "showArgument":true}},
    {"id":"nameSort",
     "value":
        {"default":false,
         "order":1,
         "required":false,
         "type":"bool",
         "validator":"",
         "visible":true},
     "semantics":
        {"ontology":["xs:boolean"]},
     "details":
        {"description":null,
         "label":"Sort by name rather than coordinate",
         "argument":"-n ",
         "showArgument":false}},
    {"id":"outputBam",
     "value":
        {"default":"sorted.bam",
         "order":1,
         "required":true,
         "type":"string",
         "validator":"",
         "visible":true},
     "semantics":
        {"ontology":["xs:string"]},
     "details":
        {"description":null,
         "label":"Sorted BAM filename",
         "argument":"-f ",
         "showArgument":true}}],
 "outputs":[
   {"id":"bam",
     "value":
        {"default":"sorted.bam",
         "order":0,
         "required":false,
         "validator":".bam$",
         "visible":true},
     "semantics":
        {"ontology":["http://sswapmeet.sswap.info/mime/application/X-bam"],
         "minCardinality":1,
         "fileTypes":["raw-0"]},
     "details":
        {"description":"",
         "label":"Sorted BAM file",
         "argument":null,
         "showArgument":false}}]}
```

### sort.template

With the use of argument passing, the template file is accordingly simplified.

```sh
input_bam="${inputBam}"
output_bam="${outputBam}"
max_mem_sort="${maxMemSort}"
name_sort=${nameSort}

tar -xvf bin.tgz

export PATH=$PATH:"$PWD/bin"

ARGS=""

ARGS="$ARGS ${max_mem_sort}"

if [ ${name_sort} -eq 1 ]; then ARGS="${ARGS} -n "; fi

samtools sort ${ARGS} ${input_bam} ${output_bam}

rm -rf bin

```

### samtools-sort-02-job.json

For completeness, the job json file used in this example is shown below.

```sh
{
    "jobName": "samtools-sort-02",
    "softwareName": "jcarson-samtools-sort-0.1.19",
    "processorsPerNode": 16,
    "requestedTime": "01:00:00",
    "memoryPerNode": 32,
    "nodeCount": 1,
    "batchQueue": "serial",
    "archive": false,
    "archivePath": "",
    "inputs": {
        "inputBam": "agave://data.iplantcollaborative.org/shared/iplantcollaborative/example_data/Samtools_mpileup/ex1.bam"
    },
    "parameters": {
    	"maxMemSort":800000000,
    	"nameSort":true
        "outputBam": "ex1_sorted.bam"
    }
    "outputs": {
    	"bam": "ex1_sorted.bam"
    }
}
```

The resulting generated command is:
```sh
samtools sort  -m 800000000 -n  ex1.bam -f ex1_sorted.bam
```

### CLI utilized

As a reminder, the sequence of command line calls used in this example is shown below.  Be sure to substitute your own iPlant username below, as well as in the above scripts as appropriate.
```sh
IPLANTUSERNAME=jcarson
auth-tokens-create -S -v
files-upload -S data.iplantcollaborative.org -F samtools-0.1.19/stampede/sort.template $IPLANTUSERNAME/applications/samtools-0.1.19/stampede/
files-upload -S data.iplantcollaborative.org -F samtools-0.1.19/stampede/samtools-sort.json $IPLANTUSERNAME/applications/samtools-0.1.19/stampede/
apps-addupdate -F samtools-0.1.19/stampede/samtools-sort.json
jobs-submit -F jobs/samtools-sort-02-job.json
```



*This completes the section on using Agave argument passing in your apps.*

[Back to READ ME](../README.md)
