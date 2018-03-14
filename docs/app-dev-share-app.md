Sharing your App and Job Output with Others
=====================================

### Sharing your app 

To share one of your private apps with other users, use the following commands:

```sh
apps-pems-update -v -u <cyvserse username> -p <permission level> <app name>
systems-roles-addupdate -v -u <cyverse username> -r <permission level> <app execution system name>
systems-roles-addupdate -v -u <cyverse username> -r <permission level> <app deployment system name>
```

The first command will grant necessary privileges to run the app, the second command will grant necessary privileges to submit jobs on the execution system, and the third command will grant read access of the actual app assets. Here is an example of sharing your application "me-foo-0.0.1" with a user with the CyVerse USERNAME "qwerty", which is tied to exection system "tacc-stampede-me" and deployment system "tacc-globalfs-me" to which your app is registered.

```sh
apps-pems-update -v -u qwerty -p READ_EXECUTE me-foo-0.0.1
systems-roles-addupdate -v -u qwerty -r USER tacc-stampede-me
systems-roles-addupdate -v -u qwerty -r GUEST tacc-globalfs-me
```

In this case, USER roll is required on the execution system to run jobs, and GUEST roll is needed on the app deployment system in order to read the app assets. Full descriptions of each available permission level can be found using the `-h` flag with one of the above commands.

### Sharing your job output

To share the output of a job with other specific users, use the following command:

```sh
jobs-pems-update -v -u <cyverse username> -r <permission level> <job id>
```

For example, to share job output for job id "1209467051736568296-242ac113-0001-007" with a user with the CyVerse Username "qwerty", perform:

```sh
jobs-pems-update -v -u qwerty -r READ 1209467051736568296-242ac113-0001-007
```

Now the user "qwerty" can see the status of the job, and view / download the output.


### Making the app public

To make your app publicly available to the entirety of CyVerse, join the developer community on [Agave’s Slack communication channel](https://slackin.agaveapi.co) and message `jfonner` and `jcarson` with the app name. Once published, make sure to test the public app with a sample job to make sure it is working as intended.

[Back](app-dev.md)  | [Next: Using Agave argument passing](app-dev-argpass.md)
