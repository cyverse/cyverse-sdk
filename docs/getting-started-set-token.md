Obtaining an OAuth 2 authentication token
=========================================

Tokens are a form of short-lived, temporary authenticiation and authorization used in place of your username and password. To interact Agave and other CyVerse APIs, you will need to acquire one. Each CyVerse token expires after 4 hours, but can easily be refreshed.

On a host where you have configured an OAuth2 client already, the command to get a new token is:

```auth-tokens-create -S -v```

You will then be prompted to enter your *API password*. Type your CyVerse password.  At this point, you should receive an affirmation of success in your terminal that resembles this one:

```
Token successfully refreshed and cached for 14400 seconds
{
    "access_token": "abc1236eb2c917a4c5796eb1cc2c6f",
    "expires_in": 14400,
    "refresh_token": "abc12315b26ebc1aec5d6e232bb455b",
    "token_type": "bearer"
}
```

If you have installed the SDK on a new host and are creating a token for the first time on that host, you will need to also include the key and secret from your Oauth2 client. In the future, the key and secret will cached on the host and you will not need to pass them in the command line. 

```auth-tokens-create -S -v --apisecret CONSUMER_SECRET --apikey CONSUMER_KEY```

## Refreshing your token

This tutorial won't take very long, but if you are interrupted and come back later, you might find your token has expired. You can always refresh a token as follows:

```auth-tokens-refresh -S -v```

A successful refresh should appear:

```
Token for iplantc.org:vaughn successfully refreshed and cached for 3600 seconds
{
    "access_token": "abc1235418ffce0da7fbdcb193d0ef",
    "expires_in": 3600,
    "refresh_token": "abc123524638e9d7ed0c3adcd3e99d5",
    "scope": "default",
    "token_type": "bearer"
}
```

This topic is covered in great detail at the Agave [Authorization Guide](http://developer.agaveapi.co/#authorization) 

*This completes the section on obtaining an OAuth2 authentication token.*

[Back](getting-started.md) | [Next: Setting up CyVerse development systems](getting-started-systems.md)
