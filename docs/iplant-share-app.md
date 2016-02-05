Sharing your app 
=====================================

To share your app with other specific users, just use two commands:

```sh
systems-roles-addupdate -v -u <iplant username of person sharing with> -r <permission level> <app system name>
apps-pems-update -v -u <iplant username of person sharing with> -p <permission level> <app name>
```

Here is an example of sharing your application "me-foo-0.0.1" with a user with the iplantusername "qwerty" and on your system "stampede-01010000-12340-me" to which your app is registered.

```sh
systems-roles-addupdate -v -u qwerty -r USER stampede-01010000-12340-me
apps-pems-update -v -u qwerty -p READ_EXECUTE me-foo-0.0.1
```

To make your app public, contact Rion Dooley.
