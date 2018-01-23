## Installing the Agave CLI
The [Agave API](https://agaveapi.co) comes bundled with a set of command line scripts. Using these scripts is generally easier than hand-crafting cURL commands, but if you prefer that route, consult the [Agave API Documentation](http://agaveapi.co/documentation/). We include these scripts in our SDK and supplement them with additional support scripts, example files, and documents.

To begin, open up a terminal window and navigate to a directory where you would like to organize this work.

Run the Installer command
-------------------------

```curl -L https://cyverse.github.io/cyverse-sdk/install/install.sh | sh```

Reload your ```.bashrc```

```source ~/.bashrc```

The installer should automatically export the `/cyverse-cli/bin` PATH to your `~/.bashrc`. But if you are using the terminal app on a Mac, you may need to add the PATH to your `~/.bash_profile` so that each new terminal session knows the location. I recommend adding the following line to your `~/.bash_profile`:  

```
if [ -r ~/.bashrc]; then
source ~/.bashrc
fi
```

This will cause your `~/.bash_profile` to source the `~/.bashrc` when you open the Terminal app, and the API commands will be immediately available to you.

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


Finally, verify that the Agave CLI has been added to the PATH by executing:

```which tenants-init```

The path to the Agave CLI should appear, e.g.:

```/home/username/cyverse-sdk/cli/bin/tenants-init ```

<iframe width="560" height="315" src="https://www.youtube.com/embed/mRJvdQsOB0M" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

[Back to: README](../README.md) | [Next: Initializing with CyVerse](initializing.md)
