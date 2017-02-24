Installing the CyVerse software development kit
===============================================

The Agave API comes bundled with a set of command line scripts. Using these scripts is generally easier than hand-crafting cURL commands, but if you prefer that route, consult the [Agave API Documentation](http://agaveapi.co/documentation/). We include these scripts in our SDK and supplement them with additional support scripts, example files, and documents.

If you are installing and working with the CyVerse SDK on your own personal computer, skip ahead to _Change to the directory where you wish to install the SDK_:

Using your Terminal program, *ssh* into the system you will be working with (e.g. Stampede, Lonestar5, etc)

```ssh stampede.tacc.utexas.edu```

Load an updated git module by typing:

```module load git```

Change to the directory where you wish to install the SDK

```cd $HOME```

Clone the SDK repository:

```git clone https://github.com/iPlantCollaborativeOpenSource/cyverse-sdk.git```

Change directory into cyverse-sdk

```cd cyverse-sdk```

Uncompress the cyverse-cli.tgz file

```tar xf cyverse-cli.tgz```

Move the cyverse-cli directory to your preferred installation location. Here, we are using your HOME directory. (Note that if you already have a cyverse-cli directory in your installation location, you'll have to remove it before performing the move command).

```mv cyverse-cli $HOME```

Edit ```~/.bashrc``` to add ```cyverse-cli/bin``` to your ```$PATH``` by adding a line like ```PATH=$PATH:$HOME/cyverse-cli/bin```

Example:

```echo "PATH=\$PATH:\$HOME/cyverse-cli/bin" >> ~/.bashrc```

Reload your ```.bashrc```

```source ~/.bashrc```

Verify that the CLI is available

Typing ```cyverse-sdk-info``` should return a response resembling this:

```
Cyverse CLI v1.0.10
For use with:
    Tenant: iplantc.org
    Agave API: v2/2.1.6+

Copyright (c) 2013, Texas Advanced Computing Center
All rights reserved.
...
```

Now initialize the command line tools for use with Cyverse

```tenants-init -t iplantc.org```

*This completes the section on installing the CyVerse SDK.*

[Back](README.md) | [Next: Creating an OAuth2 client and getting a set of keys](client-create.md)
