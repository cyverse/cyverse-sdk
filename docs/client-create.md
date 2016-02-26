Creating a client and getting a set of API Keys
===============================================
The Agave API uses OAuth 2 for managing authentication and authorization. Before you start working with the API, you will need to create a OAuth client application associated with a set of API keys. This is a one-time action, so if you already have a set of API keys, skip to the next tutorial. If not, you can create your keys using the Clients service as follows:

```sh
clients-create -S -v -N my_client -D "Client used for app development"
```

*Note:* The -N flag allows you to specify a machine-readable name for your application; -D provides the description, and -S option stores your API keys for future use, so you will not need to manually enter them when you authenticate later.

After being prompted for your CyVerse username and password, you should get a response from clients-create that looks similar to this:
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
    "consumerKey": "fMYfhijQE8ajqcKaswlGH4D5sngh",
    "consumerSecret": "8FZ6K9QwN1PY6bA9SOcyi4oaEkMa",
    "description": "Client used for app development",
    "name": "my_client",
    "tier": "Unlimited"
}
```
Although much of the process of interacting with the Agave API is automated, you may need access to the consumerKey and consumerSecret for other types of OAuth2-based interaction. If you ever need to retrieve the API keys for a particular client application, you can always do so at https://agave.iplantc.org/store/site/pages/subscriptions.jag using your CyVerse credentials

*This completes the section on obtaining a set of API keys.*

[Back to READ ME](../README.md) | [Next: Obtaining an OAuth 2 authentication token](set-token.md)
