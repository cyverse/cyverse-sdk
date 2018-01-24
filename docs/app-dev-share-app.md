Sharing your app
=====================================

To share your app with other specific users, just use two commands:

```sh
systems-roles-addupdate -v -u <cyverse username of person sharing with> -r <permission level> <app system name>
apps-pems-update -v -u <cyvserse username of person sharing with> -p <permission level> <app name>
```

Here is an example of sharing your application "me-foo-0.0.1" with a user with the CyVerse USERNAME "qwerty" and on your system "stampede-01010000-12340-me" to which your app is registered.

```sh
systems-roles-addupdate -v -u qwerty -r USER stampede-01010000-12340-me
apps-pems-update -v -u qwerty -p READ_EXECUTE me-foo-0.0.1
```

To make your app publicly available to the entirety of CyVerse, join the developer community on [Agave’s Slack communication channel](https://slackin.agaveapi.co) and share your request there.

[Back](app-dev.md)  | [Next: Using Agave argument passing](app-dev-argpass.md)
