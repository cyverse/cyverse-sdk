Installing the CyVerse software development kit
===============================================

The [Agave API](https://agaveapi.co) comes bundled with a set of command line scripts. Using these scripts is generally easier than hand-crafting cURL commands, but if you prefer that route, consult the [Agave API Documentation](http://agaveapi.co/documentation/). We include these scripts in our SDK and supplement them with additional support scripts, example files, and documents.

If you are installing and working with the CyVerse SDK on your own personal computer, skip ahead to _Run the Installer command_:

Using your Terminal program, *ssh* into the system you will be working with (e.g. Stampede2, Lonestar5, etc)

```ssh USERNAME@stampede2.tacc.utexas.edu```

Now, load the Python module

```module load python```

Run the Installer command
-------------------------

```curl -L https://cyverse.github.io/cyverse-sdk/install/install.sh | sh```

Reload your ```.bashrc```

```source ~/.bashrc```

Verify that the CLI is available
---------------------------------

Entering ```cyverse-sdk-info``` should return a response resembling this:

```
Cyverse CLI v1.4.6
For use with
    Tenant: iplantc.org
    Agave API: v2/2.2.0+
...
```

Updating the SDK
----------------

In the future, you can update the CyVerse CLI automatically to the latest version by typing

```cyverse-sdk-info --update```

Initialize the SDK
------------------

The first time you install the SDK on a computer, you need to initialize it. Do this by entering:


```tenants-init -t iplantc.org```

*This completes the section on Installing the CyVerse SDK.*

[Back](getting-started.md) | [Next: Creating an OAuth2 client and getting a set of keys](getting-started-client-create.md)
