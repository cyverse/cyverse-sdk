## Postit Helper Tool

Postits are a quick way to share a file with someone else via an HTML link. But, what if you want to share multiple files, or the contents of a directory? This page will show you how to script the creation of multiple postits, then share all postits at once through a single HTML-rendered page.


### Part 1: Create a list of files to share

This tutorial assumes you are sharing files located on the iplant data store - `data.iplantcollaborative.org`. But, it could easily be adapted to other Agave storage systems.

The list of files you would like to share should include the full path to each file relative to the "root" directory on the storage system. For example, when I list the contents of my home directory on the iplant data store, I see:

```
$ files-list -S data.iplantcollaborative.org /username/
.
analyses
applications
archive
my_data_fastqc.zip
protein.pdbqt
sequence12.fasta
```

(Replace `username` with your CyVerse username). If I wanted to share the three files located in my home directory, I would need to create a text file that contiains:

```
cat << EOF > list_of_files.txt
/username/my_data.fastqc.zip
/username/protein.pdbqtp
/username/sequence12.fasta
EOF
```


### Part 2: Run the postit helper script

Next, copy the following postit helper script into a new file:

```
#!/bin/bash
#
# Postit helper script. This is pretty rough - user is responsible for ensuring
# files exist on storage system, paths are correct, etc. This script assumes
# you want to share files on the iplant data store, but is easily modifiable to
# share data from other storage systems.
#

# Check to make sure a list is provided
if [ "$1" == "" ]; then
	echo "usage: $0 <list_of_files.txt>"; exit
fi

# Start writing the postit html page
cat << EOF > post_this.html
<html><body>
<font size=2><i>Rendered by a postit helper script. Click a file below to download.</i></font>
<br><br>
EOF

# Iterate over files, post each and capture link
for FILE in $(cat $1)
do
echo "Posting $FILE ..."
LINK=$(postits-create -l 600 -m 10 https://agave.iplantc.org/files/v2/media/system/data.iplantcollaborative.org/$FILE)
cat <<EOF >>post_this.html
<a href="$LINK">$FILE</a>
<br>
EOF
done

# Finish writing the postit html page
cat <<EOF >>post_this.html
</body></html>
EOF

# Upload the postit html page to iplant data store, user home directory
files-upload -F post_this.html -S data.iplantcollaborative.org /wallen/
rm -f post_this.html
echo ""

# Create a postit for the postit html page
postits-create -l 600 -m 10  https://agave.iplantc.org/files/v2/media/system/data.iplantcollaborative.org/wallen/post_this.html
echo "Finished! Click or share the link above to access your files."

```

This sample script is not extremely robust in that it does very little error checking. It does not check, for example, for correctness in the `list_of_files.txt` or whether the files actually exist. Further, the number of accesses (10) and time available (600s), and storage system (`data.iplantcollaborative.org`) are hard coded into the script. It is left to the user to customize beyond the default settings.

Once it is copied, simply execute the script providing the list of files as a command line argument:

```
$ bash postit_helper.sh list_of_files.txt
```

The final result will return a link to a page where all your files can be downloaded by name in an HTML interface.






[Back to: README](../README.md)
