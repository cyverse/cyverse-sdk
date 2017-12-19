## Managing Identities

### Multiple tenants

The Agave Platform supports multiple tenants in addition to CyVerse.
It also provides tools for users to seamlessly switch between tenants.
To discover what tenants are available, use the `tenants-list` command:

```
tenants-list
tenants-list -v
```

Verbosely listing tenant information will also reveal relavent websites and contact information.
Configurations and tokens for your current tenant are stored in `~/.agave/current`.
In order to switch to a new tenant, it is convenient to first backup your existing configuration:

```tenants-init -b```

Then, initiate and authenticate with a new tenant as [described previously](initializing.md).
Finally, swapping between configurations can be done using:

```tenants-init -s```

### Gain access to new APIs

As the Agave Platform evolves, new APIs are developed for interacting with your tenant, apps, files, systems, etc.
The client you created to interact with the APIs does not, by default, have access to new APIs.
To list APIs your client can interact with, do:

```clients-subscriptions-list -v my_client```

To add access to a new API, e.g. `transforms`, do:

```cliens-subscriptions-update -v -N transforms my_client```

Alternatively, you may delete your client and re-initialize with the tenant from scratch.



[Back to: README](../README.md) | [Next: Automating Workflows](automating_workflows.md)
