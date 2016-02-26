Installing the CyVerse software development kit
==================================================

The Agave API comes bundled with a set of command line scripts. Using these scripts is generally easier than hand-crafting cURL commands, but if you prefer that route, consult [Getting Started with the Agave API](http://agaveapi.co/getting-started-with-the-agave-api/). We include these scripts in our SDK, and supplement them with additional support scripts, example files, and documents. 

Using a terminal interface, *ssh* into the system you will be working with (e.g. Stampede, Lonestar, etc)

```ssh ls5.tacc.utexas.edu```

Load an updated git module by typing:

```module load git```

Clone the SDK repository (note the --recursive flag):

```git clone https://github.com/iPlantCollaborativeOpenSource/cyverse-sdk.git --recursive```

Uncompress the cyverse-cli.tgz file

```
tar xf cyverse-cli.tgz
```

Move the cyverse-cli directory to your preferred installation location. Here, we are using your HOME directory. (Note that if you already have a cyverse-cli directory in your installation location, you'll have to remove it before performing the move command).

```
mv cyverse-cli $HOME
```

Edit ```~/.bashrc``` to add ```cyverse-cli/bin``` to your ```$PATH``` by adding a line like ```PATH=$PATH:$HOME/cyverse-cli/bin```

Example:

```
echo "PATH=\$PATH:\$HOME/cyverse-cli/bin" >> ~/.bashrc
```

Reload your ```.bashrc```

```source ~/.bashrc```

Verify that the CLI is available

Typing ```cyverse-sdk-info``` should return a response resembling this:

```
Cyverse CLI v1.0.1
For use with:
    Tenant: iplantc.org
    Agave API: v2/2.1.6+

Copyright (c) 2013, Texas Advanced Computing Center
All rights reserved.
...
```

Now initialize the command line tools for use with iPlant

```tenants-init -t iplantc.org```

*This completes the section on installing the CyVerse SDK.*

[Back to READ ME](../README.md) | [Next: Creating an OAuth2 client and getting a set of keys](client-create.md)
