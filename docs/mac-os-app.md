## Mac OS App Development Kit

This tutorial shows how to wrap an existing, public CyVerse app into a clickable application on your Mac. This might be useful for you if:

* You want to perform an analysis in as few as possible steps
* You have repetetive tasks / jobs and lots of data
* You want to easily automate an analysis pipeline
* You (or someone you support) has no command line experience

Here, we will go through the steps for creating a Mac OS app for `fastq` quality control with FastQC. The end result will be a clickable app on your Mac that will automatically upload your `fastq` data to the iplant data store, submit a job against the public FastQC Agave app, then download and catalogue the results when it is complete. Then, the user will be able to view and analyze the FastQC HTML output without ever leaving their Mac environment or touching the command line.

This is a relatively simple example using a public data store, public execution system, and public Agave app. It can be made much more powerful by combining this infrastructure with your own [custom apps](app-dev.md), [private systems](register-your-cluster.md), and more complex run control. Please contact us if you have ideas that you want help developing! (lifesci@consult.tacc.utexas.edu)

### Part 1: Create a Dummy App

An 'app' on a Mac is simply a directory tree with defined organization and content. To create the necessary framework, execute the following commands in your Mac Terminal:

```
# jobs will be run from the fastqc_jobs/ folder
mkdir -p ~/Desktop/fastqc_jobs/
cd ~/Desktop/fastqc_jobs/
 
# generic Mac OS app infrastructure
mkdir -p FastQC.app/Contents/MacOS
mkdir -p FastQC.app/Contents/Resources
 
# create the app executable
cat << EOF > FastQC.app/Contents/MacOS/FastQC
#!/bin/bash
HERE="\$(dirname \$0)"
open -a /Applications/Utilities/Terminal.app/Contents/MacOS/Terminal \$HERE/run_script.sh
EOF
 
# create the run script
cat << EOF > FastQC.app/Contents/MacOS/run_script.sh
#!/bin/bash
echo "Hello, world!"
sleep 10
EOF
 
# set permissions to execute
chmod +x FastQC.app/Contents/MacOS/*
```

Adding an icon to the Mac app is not necessary, but relatively easy to do. For example:

* [Download](http://www.cyverse.org/sites/default/files/PoweredbyCyverse_LogoSquare_0_0.png) and/or prepare an image in `.png` format (512x512 pixels works best)
* Open the image with Preview and choose `Edit => Copy`
* Right-click the FastQC.app and choose `Get Info`
* In the top-left corner of the dialog, single click the current icon to select it, then `Edit => Paste`
* You may store the image in the ~FastQC.app/Contents/Resources/ directory

By now, you should have the following directory architecture:

```
$ pwd
~/Desktop/fastqc_jobs/
$ tree .
.
└── FastQC.app
    └── Contents
        ├── MacOS
        │   ├── FastQC
        │   └── run_script.sh
        └── Resources
            └── icon.png

4 directories, 3 files
```

Try double clicking the FastQC.app. If all is working so far, a Terminal window should open with the `Hello, world!` message, and close after 10 seconds.

### Part 2: Doing Something Useful







