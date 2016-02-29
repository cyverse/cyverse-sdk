Obtaining an OAuth 2 authentication token
=========================================

Tokens are a form of short-lived, temporary authenticiation and authorization used in place of your username and password. To interact with CyVerse APIs, you will need to acquire one. Your Cyverse token will expire 4 hours, but can easily be refreshed.

The command to accomplish this is:

```sh
# From your terminal interface, type:
auth-tokens-create -S -v
```
* You will then be prompted to enter your *API password*. Type your CyVerse password.
* At this point, you should receive an affirmation of success in your terminal that resembles this one:
```
Token successfully refreshed and cached for 14400 seconds
{
    "access_token": "e431846eb2c917a4c5796eb1cc2c6f",
    "expires_in": 14400,
    "refresh_token": "8212a515b26ebc1aec5d6e232bb455b",
    "token_type": "bearer"
}
```

## Refreshing your token

When your token expires in 4 hours, you may refresh it:

```sh
auth-tokens-refresh -S -v
Token for iplantc.org:vaughn successfully refreshed and cached for 3600 seconds
{
    "access_token": "3baebe5418ffce0da7fbdcb193d0ef",
    "expires_in": 3600,
    "refresh_token": "4a51a7524638e9d7ed0c3adcd3e99d5",
    "scope": "default",
    "token_type": "bearer"
}
```

This topic is covered in great detail at [Authentication Token Management](http://agaveapi.co/authentication-token-management/) in the Agave live docs

*This completes the section on obtaining an OAuth2 authentication token.*

[Back to READ ME](../README.md) | [Next: Setting up CyVerse development systems](iplant-systems.md)
