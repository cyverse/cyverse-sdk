INSTALLATION INSTRUCTIONS
-------------------------

If you checked out the cyverse-sdk project from Github, cd into it now. If you downloaded the versioned release file, uncompress it and cd into the resulting directory. Then...

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
