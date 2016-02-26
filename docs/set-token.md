Obtaining an OAuth 2 authentication token
=========================================
In order to interact with CyVerse Science API services, you will need to acquire a authentication token, which is tied to the client application you have created. The command for accomplishing this is:
```sh
# From your terminal interface, type:
auth-tokens-create -S -v
```
* You will first be prompted to enter your *Consumer Secret*. Copy your consumerSecret from before, when you created a client application, and paste it in your terminal interface where prompted.
* You will next be prompted to enter your *Consumer Key*. Copy your *consumerKey *and paste this in your terminal interface where prompted.
* You will then be prompted to enter your *Agave tenant username*. Type your iPlant username.
* You will then be prompted to enter your *Agave tenant password*. Type your iPlant password.
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

If your token at some point in time expires, simply re-run the *auth-tokens-create -S* command. You'll only need to enter your iPlant password, as the other values will be automatically remembered. You will need to configure the iPlant API SDK on each system you plan to develop on. To do so, clone the repo from GitHub, update your environment variables as above, then run *auth-tokens-create -S* using the consumerSecret and consumerKey for your Oauth2 client.

More information on this step is available at [Authentication Token Management](http://agaveapi.co/authentication-token-management/) in the Agave live docs

*This completes the section on obtaining an OAuth2 authentication token.*

[Back to READ ME](../README.md) | [Next: Setting up CyVerse development systems](iplant-systems.md)
