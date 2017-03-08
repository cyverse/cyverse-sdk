Creating a client and getting a set of API Keys
===============================================
The Agave API uses OAuth 2 for managing authentication and authorization. Before you work with Agave, you must create an OAuth client application and record the API keys that are returned. This is a one-time action, so if you already have a set of API keys, skip to the next tutorial. 

Create a set of API keys using the Agave clients service as follows:

```clients-create -S -v -N my_api_client -D "Client used for app development" ```

*Note:* The -N flag allows you to specify a machine-readable name for your application and -D provides the description. The -S option stores your API keys for future use, so you will not need to manually enter them when you authenticate later. Please do not forget to include the -S option when creating a client. 

You will be prompted for your CyVerse username and password. Enter them when asked, then wait for a response that resembles this one:

```json
{
    "_links": {
        "self": {
            "href": "https://agave.iplantc.org/clients/v2/my_client"
        },
        "subscriber": {
            "href": "https://agave.iplantc.org/profiles/v2/vaughn"
        },
        "subscriptions": {
            "href": "https://agave.iplantc.org/clients/v2/my_client/subscriptions/"
        }
    },
    "callbackUrl": "",
    "consumerKey": "fMYfhijQE8fauxkeyGH4D5sngh",
    "consumerSecret": "8FZ6K9Qwfauxsecretcyi4oaEkMa",
    "description": "Client used for app development",
    "name": "my_client",
    "tier": "Unlimited"
}
```

You will need access to the ```consumerKey``` and ```consumerSecret``` values when setting up the SDK on other hosts. So, please take a moment and record *client_name*, *consumerKey*, and *consumerSecret* somewhere safe. If you lose these values, you can create new instance of the client by deleting the old client (clients-delete CLIENT_NAME) and creating it again. 

*This completes the section on obtaining API keys.*

[Back](getting-started.md) | [Next: Obtaining an OAuth 2 authentication token](getting-started-set-token.md)
