Installing the iPlant API software development kit
==================================================

The Agave API comes bundled with a set of command line scripts. Using these scripts is generally easier than hand-crafting cURL commands, but if you prefer that route, consult [Getting Started with the Agave API](http://agaveapi.co/getting-started-with-the-agave-api/). We include these scripts in our SDK, and supplement them with additional support scripts, example files, and documents. 

Using a terminal interface, *ssh* into the system you will be working with (e.g. Stampede, Lonestar, etc)

```sh
ssh stampede.tacc.utexas.edu
# Check out the SDK from the iPlant's GitHub
# Load an updated git module by typing:
module load git
# Clone the SDK repository (note the --recursive flag):
git clone https://github.com/iPlantCollaborativeOpenSource/iplant-agave-sdk.git --recursive
# Add SDK scripts to your PATH:
echo "export IPLANT_SDK_HOME=$PWD/iplant-agave-sdk" >> ~/.profile
echo "PATH=\$PATH:\$IPLANT_SDK_HOME/scripts:" >> ~/.profile
echo "export PATH=\$PATH:\$IPLANT_SDK_HOME/foundation-cli/bin" >> ~/.profile
# To re-init bash _type_:
source ~/.profile
# now initialize the command line tools for use with iPlant
tenants-init -t iplantc.org
```
*This completes the section on installing the iPlant Agave SDK.*

[Back to READ ME](../README.md) | [Next: Creating an OAuth2 client and getting a set of keys](client-create.md)
