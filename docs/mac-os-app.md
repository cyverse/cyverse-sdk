## Mac OS App Development Kit

Do you have repetetive tasks that would be much easier with automation? Are you supporting a user with little to no command line experience? Here, we will show you how to create an App for your Mac that can automatically perform Agave tasks. The example here is an automatic FastQC quality control check. From the users perspective, all they have to do is drag the fastq file into a folder, and double click the App. The App will automatically upload the data to the iplant data store, exsubmit a job against the public fastqc Agave app, then download and catalogue the results when it completes. Then, the user is able to view the fastqc html output in a browser in their Mac without ever touching another system.


This is a relatively simple example using public data stores and public Agave apps. It can be made much more powerful by combining this infrastructure with your own [custom apps](link to tutorial), [private systems](link to tutorial), and more advanced run control. Please contact us if you have ideas that you want help developing! (wallen@tacc.utexas.edu

__Part 1: Create a Dummy App__

An `App` on a Mac is actually just a directory tree with defined contents. To create the shell, execute the following commands:

```
cd ~/Desktop/
mkdir fastqc_jobs/
cd fastqc_jobs/
mkdir -p FastQC.app/Contents/MacOS
cat << EOF > FastQC.app/Contents/MacOS/FastQC
#!/bin/bash
HERE="$(dirname $0)"
open -a /Applications/Utilities/Terminal.app/Contents/MacOS/Terminal $HERE/run_script.sh
EOF
cat << EOF > FastQC.app/Contents/MacOS/run_script.sh
#!/bin/bash
echo "Hello, world!"
sleep 10
EOF
chmod +x FastQC.app/Contents/MacOS/*
```

By now, you should have the following directory architecture:
```






