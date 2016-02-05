Overview
--------
In January 2014, version 2 of the iPlant-developed [Agave API](http://agaveapi.co/) was released, bringing with it some powerful new features including:
* diverse execution paradigms including HPC, command-line, Condor, and Docker containers
* support for MyProxy-based authentication
* the ability to enroll your own computing and storage resources
* notifications via sophisticated callbacks
* job dependencies
* automated, asynchronous data staging
* online support tools for app creation
* live documentation

We have assembled this software development kit with an eye towards developers affiliated with the iPlant Collaborative who are developing scientific applications for use by other users via the graphical Discovery Environment workbench, third party workbench systems, or personal integrations with the Agave SaaS API. With a little tweaking, 90% of the documentation here is generally applicable to using Agave in your own organization.

*Guide to App Development at iPlant*
* [Initial assumptions](docs/iplant-assumptions.md)
* [Installing the SDK](docs/install-sdk.md)
* [Creating an OAuth2 client and getting a set of keys](docs/client-create.md)
* [Obtaining an OAuth 2 authentication token](docs/set-token.md)
* [Setting up iPlant development systems](docs/iplant-systems.md)
* [Creating an iPlant application for TACC Stampede](docs/iplant-first-app.md)
* [Running and debugging a job using your Agave app](docs/iplant-first-app-job.md)
* [Sharing your Agave app with others](docs/iplant-share-app.md)
* [Crafting applications using Agave argument passing](/docs/iplant-first-app-argpass.md)

*Additional Guides*
* [Setting up your own systems](docs/atmo-system.md)
* [Cloning an iPlant application to your own systems](docs/iplant-clone-app.md)
* [Advanced app authoring with Launcher]

### Reporting errors and getting help
* Report issues at the [Service Desk](https://pods.iplantcollaborative.org/jira/servicedesk/customer/sciapi).
* Visit the [Ask iPlant](http://ask.iplantcollaborative.org/questions/) forums for in-depth help.
* Subscribe to [iPlant-API-Dev](http://mail.iplantcollaborative.org/mailman/listinfo/iplant-api-dev) for realtime updates and discussion. 

