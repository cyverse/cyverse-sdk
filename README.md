Overview
--------

Cyverse provides full scriptable access to its underlying infrastructure via the Agave API, which provides a comprehensive set of RESTful web services that make it easy for developers and users to:
* Develop and run applications on HPC, Cloud, Condor, and container-based computing systems
* Use MyProxy-based authentication for federated identity
* Bring their own computing and storage resources into Cyverse
* Share data and applications, even with people who aren't Cyverse users
* Connect computing and data tasks via web-based events
* Manage data on any cloud storage platform one has access to
* Build sophisticated web-based applications that take advantage of all these underlying capabilities

We're providing this software development kit to help you with

1. Creating and running in creating your own computing applications to be deployed at Cyverse
2. Using Cyverse applications deployed by other people to analyse your (or other people's) data
3. Sharing data at Cyverse or on other systems with collaborators
4. Bringing your own HPC computing and data resources into Cyverse for yourself or other people to use

Over time, we'll address more use cases, such as working with cloud systems such as Amazon Web Services, Google Compute Engine, or [NSF Jetstream](https://use.jetstream-cloud.org/), building web applications, improving reproducible science and analysis with Docker, and more. 

*Tutorial 1: Application Development at Cyverse*
* [Initial assumptions](docs/iplant-assumptions.md)
* [Installing the SDK](docs/install-sdk.md)
* [Creating an OAuth2 client and getting a set of keys](docs/client-create.md)
* [Obtaining an OAuth 2 authentication token](docs/set-token.md)
* [Setting up Cyverse development systems at TACC](docs/iplant-systems.md)
* [Creating a Cyverse application on TACC Stampede](docs/iplant-first-app.md)
* [Running and debugging a job using your Agave app](docs/iplant-first-app-job.md)
* [Sharing your Agave app with others](docs/iplant-share-app.md)
* [Crafting applications using Agave argument passing](/docs/iplant-first-app-argpass.md)

*Additional Guides*
* [Setting up your own systems](docs/atmo-system.md)
* [Cloning a Cyverse application to your own systems](docs/iplant-clone-app.md)
* [Advanced app authoring with Launcher]

### Reporting errors and getting help
* Visit the *[Ask Cyverse](http://ask.cyverse.org/)* forums for in-depth help. Make sure to mark your questions with the ```Agave_API``` tag so that the API team doesn't miss your questions.
* Find more in-depth technical detail at the [Agave Science-as-a-Service API](http://agaveapi.co/) home page
