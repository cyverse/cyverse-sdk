# terrain cli

Python tools for the Terrain API

## Installation via GitHub

```
$ git clone https://github.com/jturcino/cyverse-sdk.git
$ git checkout terrain
```

## Setup
Usage of the cli requires a valid access token. The cli defaults to use of a cached token associated with the Agave API. If you do not have a cached Agave access token, tokens may be passed in manually via the -z flag. For more information about creating and caching Agave tokens, and the API generally, please see the repo [here](https://bitbucket.org/agaveapi/cli).

Once you have a valid access token readily available (cached or to be passed in at the command line), enable bash completion.
```
$ source terrain-completion.bash
```

## Usage
This cli is designed to allow you to go through all the steps of selecting an app and running a job through the Cyverse Discovery Environment without using the visual interface. We begin by finding an appropriate app via hierarchies or search, creating a job submission form based on that app's decription, and finallly submitting the job. Additionally, tools are available to list and delete previous jobs.
While walking through usage, I will use the example of counting words in a text file.

### Finding an app
If you are unsure of which app you would like to use, use `hierarchies-list` to find the general topic that interests you. Once found, use the iri of that topic and `apps-list-by-hierarchy` to list apps in that hierarchy.
```
$ ./terrain hierarchies list
{
    "hierarchies": [
        {
            "iri": "http://edamontology.org/topic_0003",
            "label": "Topic",
            "subclasses": [
    ...
}
$ ./terrain apps list -i <some_iri>
```

However, it can be difficult to parse through the long, nested list of hierarchies. If you have an idea of what you are looking for in an app, `apps-search` may be of more use to you. This command requires a single search term; in our wordcount example, we pass in the word "word".
```
$ ./terrain apps search -s word
DE Word Count 67d15627-22c5-42bd-8daf-9af5deecceab
DNASubway Word Count 1.0.0 dnasubway-wc-singularity-stampede-1.0.0u1
wc condor 1.00 wc-osg-1.00u33
Word Count c7f05682-23c8-4182-b9a2-e09650a5f49b
```
Let's use the final app in the provided list, which has an app ID of `c7f05682-23c8-4182-b9a2-e09650a5f49b`.

### Creating a job submission form
Once you have an app, pass its ID into `apps-description` to check that it suits your needs. Alternately, this step may be skipped, and you may procede directly to job template generation. In our word-counting example, the command looks like the following:
```
$ ./terrain apps description -a c7f05682-23c8-4182-b9a2-e09650a5f49b
Word Count:
Counts and summarizes the number of lines, words, and bytes in a target file
```

If the description matches the desired behavior, generate a job submission template via `jobs-template` by passing in the app ID.
```
$ ./terrain jobs template -a c7f05682-23c8-4182-b9a2-e09650a5f49b
{
    "app_id": "c7f05682-23c8-4182-b9a2-e09650a5f49b",
    "archive_logs": true,
    "config": {
        "67781636-854a-11e4-b715-e70c4f8db0dc_2f58fce9-8183-4ab5-97c4-970592d1c35a": "Select an input file"
    },
    "create_output_subdir": true,
    "debug": false,
    "name": "",
    "notify": true,
    "output_dir": ""
}
```
This output must be edited before submission, so it is convientient to send it directly to a file.
````
$ ./terrain jobs template -a c7f05682-23c8-4182-b9a2-e09650a5f49b > job_file.json
```
Once in file form, a name and output directory must be provided. Additionally, the string descriptions given as values for the ID keys in the config block must be replaced by valid input. In the example above, `"Select an input file"` would be replaced by a file path, such as `"/iplant/home/jturcino/word_count.txt"`. If there is a default value for any of these parameters, it will be provided in parentheses. Thus, the final job file for our word count example could look like this:
```
{
    "app_id": "c7f05682-23c8-4182-b9a2-e09650a5f49b",
    "archive_logs": true,
    "config": {
        "67781636-854a-11e4-b715-e70c4f8db0dc_2f58fce9-8183-4ab5-97c4-970592d1c35a": "/iplant/home/jturcino/word_count.txt"
    },
    "create_output_subdir": true,
    "debug": false,
    "name": "wordcount-example",
    "notify": true,
    "output_dir": "/iplant/home/jturcino/analyses"
}
```

### Submitting the job
With a properly completed submission form, you may now submit the job! Simply pass in the name of the job file to `jobs-submit`, which will return the job name, ID, and status.
```
$ ./terrain jobs submit -f jobs-submit.json 
wordcount-example fefc169e-c240-11e6-82ae-008cfa5ae621 Submitted
```

### Other tools
You can list previous and current jobs with `jobs-list`. Additionally, if you provide a particular job ID, a more detailed description of that job will be provided.
```
$ ./terrain jobs list 
wordcount-example fefc169e-c240-11e6-82ae-008cfa5ae621 Completed
terrain-cli-test fcb7c064-be57-11e6-98ab-008cfa5ae621 Completed
...
$ ./terrain jobs list -j fefc169e-c240-11e6-82ae-008cfa5ae621
{
    "app_description": "Counts and summarizes the number of lines, words, and bytes in a target file",
    "app_disabled": false,
    "app_id": "c7f05682-23c8-4182-b9a2-e09650a5f49b",
    "app_name": "Word Count",
    ...
}
```

If you would like to delete a job, simple provide the job ID to `jobs-delete`.
```
$ ./terrain jobs delete -j fefc169e-c240-11e6-82ae-008cfa5ae621
Job fefc169e-c240-11e6-82ae-008cfa5ae621 successfully deleted.
```

### Notes
All commands have a help message and most have verbose output. 

If you are unsure of usage, simply add the `-h` flag after a command. For example, here is the help message for `jobs-submit`:
```
$ ./terrain jobs submit -h
usage: terrain-jobs-submit.py [-h] [-f [DESCRIPTION_FILE]] [-v]
                              [-z [ACCESSTOKEN]]

Submit a job.

optional arguments:
  -h, --help            show this help message and exit
  -f [DESCRIPTION_FILE], --description_file [DESCRIPTION_FILE]
                        file containing JSON job description
  -v, --verbose         verbose output
  -z [ACCESSTOKEN], --accesstoken [ACCESSTOKEN]
                        access token
```

If you would like the full output where available, add the `-v` flag to the command. For example, here is the verbose output for `apps-search` when searching with keyword `word` (compare to the output under [Finding an App](https://github.com/jturcino/cyverse-sdk/tree/terrain/src/scripts#finding-an-app)):
```
$ ./terrain apps search -s word -v
{
    "apps": [
        {
            "app_type": "DE",
            "beta": true,
            "can_favor": true,
            "can_rate": true,
            "can_run": true,
            "deleted": false,
            "description": "Counts the number of words in a file",
            "disabled": false,
            "id": "67d15627-22c5-42bd-8daf-9af5deecceab",
            "integration_date": "2015-08-04T16:30:16Z",
            "integrator_email": "support@iplantcollaborative.org",
            "integrator_name": "Default DE Tools",
            "is_favorite": false,
            "is_public": true,
            "name": "DE Word Count",
            "permission": "read",
            "pipeline_eligibility": {
                "is_valid": true,
                "reason": ""
            },
            "rating": {
                "average": 0.0,
                "total": 0
            },
            "step_count": 1,
            "system_id": "de",
            "wiki_url": ""
        },
        ...
    ],
    "total": 4
}
````
The verbose flag is not available for commands where the full output is already provided (such as `hierarchies-list` and `jobs-template`) or where there is no output returned (such as `jobs-delete`).
