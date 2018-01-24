#!/bin/bash
#
# Postit helper script. This is pretty rough - user is responsible for ensuring
# files exist on storage system, paths are correct, etc. This script assumes
# you want to share files on the CyVerse data store, but is easily modifiable to
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
cat << EOF >> post_this.html
<a href="$LINK"> $FILE </a>
<br>
EOF
done

# Finish writing the postit html page
cat << EOF >> post_this.html
</body></html>
EOF

# Upload the postit html page to CyVerse data store, user home directory
files-upload -F post_this.html -S data.iplantcollaborative.org /wallen/
rm -f post_this.html
echo ""

# Create a postit for the postit html page
postits-create -l 600 -m 10  https://agave.iplantc.org/files/v2/media/system/data.iplantcollaborative.org/wallen/post_this.html
echo "Finished! Click or share the link above to access your files."
