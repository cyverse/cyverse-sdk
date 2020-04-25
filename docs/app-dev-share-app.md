Sharing your app 
=====================================

To share your app with other specific users, just use two commands:

```sh
tapis systems roles grant <app system name> <cyverse username of person sharing with> <permission level>
tapis apps pems grant <app name> <cyvserse username of person sharing with> <permission level>
```

Here is an example of sharing your application "me-foo-0.0.1" with a user with the CyVerse "qwerty" and on your system "stampede-01010000-12340-me" to which your app is registered.

```sh
tapis systems roles grant stampede-01010000-12340-me qwerty USER
tapis apps pems grant me-foo-0.0.1 qwerty READ_EXECUTE
```

To make your app publicly available to the entirety of CyVerse, join the developer community on [Agave’s Slack communication channel](https://slackin.agaveapi.co) and share your request there.

[Back](app-dev.md)  | [Next: Using Agave argument passing](app-dev-argpass.md)
