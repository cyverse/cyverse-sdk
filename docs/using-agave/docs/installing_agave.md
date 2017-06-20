## Installing the Agave CLI

The Agave CLI is a collection of over 100 different bash scripts.
The purpose of these scripts is to facilitate building cURL commands for interaction with the web API.
In order to make sure you are using an up-to-date version of the Agave CLI, please clone directly from the source.
To begin, open up a terminal window and navigate to a directory where you would like to organize this work.
Then, clone this tutorial:

```git clone https://github.com/wjallen/using-agave```

Navigate into the `using-agave/` directory, then into the `src/` directory:

```cd using-agave/src/```

Here, clone the Agave CLI:

```git clone https://bitbucket.org/agaveapi/cli```

Add the Agave CLI to your PATH, so that you may access the commands from anywhere on the current machine:

```
cd cli/bin/
export PATH=$PWD:$PATH
```

You may also consider adding the whole path to your `~/.bashrc` so that each new terminal session knows the location:

```echo "PATH=/complete/path/to/using-agave/src/cli/bin:\$PATH" >> ~/.bashrc```

(Replace `/complete/path/to` with the actual path to the `using-agave/` directory.
You can determine this by navigating to that directory and typing `pwd`.)
Note that if you move or rename this project directory, the Agave commands will no longer be in your PATH, and the previous steps will need to be repeated.
Finally, verify that the Agave CLI has been added to the PATH by executing:

```which tenants-init```

The path to the Agave CLI should appear, e.g.:

```/home/username/using-agave/src/cli/bin/tenants-init ```

[Back to: README](../README.md) | [Next: Initializing with CyVerse](initializing.md)
