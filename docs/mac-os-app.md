## Mac OS App Development Kit

Do you have repetetive tasks that would be much easier with automation? Are you supporting a user with little to no command line experience? Here, we will show you how to create an App for your Mac that can automatically perform Agave tasks. The example here is an automatic FastQC quality control check. From the users perspective, all they have to do is drag the fastq file into a folder, and double click the App. The App will automatically upload the data to the iplant data store, exsubmit a job against the public fastqc Agave app, then download and catalogue the results when it completes. Then, the user is able to view the fastqc html output in a browser in their Mac without ever touching another system.


This is a relatively simple example using public data stores and public Agave apps. It can be made much more powerful by combining this infrastructure with your own [custom apps](link to tutorial), [private systems](link to tutorial), and more advanced run control. Please contact us if you have ideas that you want help developing! (wallen@tacc.utexas.edu

__Part 1: Create a Dummy App__

An `App` on a Mac is actually just a directory tree with defined contents. To create the shell, execute the following commands:

```
# jobs will be run from the fastqc_jobs folder
mkdir -p ~/Desktop/fastqc_jobs/
cd ~/Desktop/fastqc_jobs/
 
# generic Mac OS App infrastructure
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

It is also very easy to add an Icon to the app. Download any image and resize it to 512x512 pixels, saving as a png. Open the image with Preview, then choose `Edit => Copy`. Then right click the FastQC.app and choose `Get Info`. In the top-left corner of the dialog, single click the current image to select it, then `Edit => Paste`. Although it is not necessary, you may store the image in a ~FastQC.app/Contents/Resources/ directory.

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

__Part 2: Doing Something Useful__







