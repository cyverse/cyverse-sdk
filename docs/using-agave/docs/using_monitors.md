## Using Monitors to Track System Health

Monitors are an easy way to perform scheduled checks on an Agave storage or execution system.
These proactive checks can alert you if any of your private systems, or if any of your favorite public systems, are for any reason unavailable, inaccessible, or non-functional.
The only information needed to create a new monitor is the name of the system (find this with the `systems-list` command).
To create a new monitor, perform:

```
monitors-addupdate -S data.iplantcollaborative.org -I 720
```

This will create a monitor that checks the availability of the `data.iplantcollaborative.org` storage system every 720 minutes (12 hours).
The response will look like:

```
Successfully created monitor 5187961641892778471-242ac1113-0001-014 on target data.iplantcollaborative.org
```

The long UUID is used to update or disable the monitor in the future.
To change the monitor frequency to, for example, every 24 hours, the command is:
```
monitors-addupdate -S data.iplantcollaborative.org -I 1440 5187961641892778471-242ac1113-0001-014
```

Use `monitors-list` to see all of the monitors you created, then use `monitors-checks-list` with the monitor UUID to see a history of PASSED and /or FAILED checks of the monitor:
```
monitors-checks-list -M 5187961641892778471-242ac1113-0001-014
```

Monitors can be run manually at any time with the `monitors-fire` command, along with the monitor UUID:
```
monitors-fire 5187961641892778471-242ac1113-0001-014
```

To temporarily disable a monitor, or to permanently delete a monitor, use the `monitors-disable` and `monitors-delete` commands:
```
monitors-disable 5187961641892778471-242ac1113-0001-014
monitors-delete 5187961641892778471-242ac1113-0001-014
```

The `monitors-enable` command will re-enable a disabled monitor, but it will not bring back a deleted monitor:
```
monitors-enable 5187961641892778471-242ac1113-0001-014
```

[Back to: README](../README.md) | [Next: Managing Identities](managing_identities.md)
