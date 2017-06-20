## Initializing with CyVerse

In this step, you need to configure your environment to interact with the CyVerse tenant.
You should already have a CyVerse account (see [Initial Assumptions](initial_assumptions.md)) and know your username and password.
On the command line, type:

```tenants-init -t iplantc.org```

(CyVerse was formerly called "iPlant").
This defines the URL where the Agave CLI will direct its cURL commands (POST, GET, PUT, DELETE).
Now, a "client" that will store your username and information about the method of interaction with the tenant must be registered:

```clients-create -S -N my_client -D "My client used for interacting with CyVerse"```

The `-S` flag stores your API keys on your local system so that you do not need to repeat this step.
The `-N` flag is a name for the client, and the `-D` flag is a brief description.
You will be prompted for a username and password, at which point you should enter your CyVerse credentials.
If everything is successful, you will see a message similar to:

```
Successfully created client my_client
key: g1of3MXVsJkk0avI5QrOopoa 
secret: JILflDQpSsEIGQyDKWGEe9Ia
```

If for some reason you ever need to find and delete existing clients, you can use the `clients-list` and `clients-delete` commands. Finally, obtain an OAuth 2 authentication token by issuing the following command:

```auth-tokens-create -S```

The `-S` flag will store the token on your local system.
Because you previously stored your username, you should now just be prompted for your CyVerse password.
If successful, you will see a message similar to:

```
Token for iplantc.org:username successfully refreshed and cached for 14400 seconds
78a89c1c576e3f36311a3064992
```

This will make it so you do not have to enter your username and password every time you want to interact with CyVerse via the Agave CLI.
As such, the above three command (`tenants-init`, `clients-create`, `auth-tokens-create`) are **one time** actions.
However, the  authentication token expires after four hours.
To check the status of the token, issue:

```auth-check ```

If it is expired, refresh the token using:

```auth-tokens-refresh ```

You are now fully configured to interact with CyVerse via the Agave CLI.

[Back to: README](../README.md) | [Next: Managing Data](managing_data.md)
