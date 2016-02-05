INSTALLATION INSTRUCTIONS
-------------------------

If you checked out the cyverse-sdk project from Github, cd into it now. If you downloaded the versioned release file, uncompress it and cd into the resulting directory. Then...

1. Uncompress the cyverse-cli.tgz file

```
tar xf cyverse-cli.tgz
```

2. Move the cyverse-cli directory to your preferred installation location. Here, we are using your HOME directory.

```
mv cyverse-cli $HOME
```

3. Edit ```~/.bashrc``` to add ```cyverse-cli/bin``` to your ```$PATH```

Example:

```
echo "PATH=\$PATH:\$HOME/cyverse-cli/bin" >> ~/.bashrc
```

4. Reload your ```.bashrc```

```source ~/.bashrc```

5. Verify that the CLI is available

Typing ```cyverse-cli-info``` should return a response resembling this:

```
Cyverse CLI v1.0.1
For use with:
    Tenant: iplantc.org
    Agave API: v2/2.1.6+

Copyright (c) 2013, Texas Advanced Computing Center
All rights reserved.
...
```
