<a href="https://www.cyverse.org"><img src="cyverse_develop_logo2.png"></a>


# Automate your CyVerse workflows

CyVerse supports multiple avenues for automating your work.

* **The Discovery Environment (DE) Workflow Manager**.  The [CyVerse DE](https://de.cyverse.org) supports creating and editing automated linear pipelines for data processing and analysis, as [documented at this link](https://pods.iplantcollaborative.org/wiki/pages/viewpage.action?pageId=8391828).   Examples of Genomics workflows are available [here](https://pods.iplantcollaborative.org/wiki/display/TUT/Genomics+Workflows).

* **High Throuput Computing**.  Cyverse maintains a Condor cluster at the University of Arizona that supports high throughput workflows that can be initiated either through the [CyVerse DE](https://de.cyverse.org) or through the command line using the DE / Terrain APIs.  Command line tools for the Terrain APIs are available as part of the Cyverse SDK, and full API documentation is available [here](https://cyverse-de.github.io/api/).  Instructions on using the Cyverse SDK as well as an example of running a HTC job are in the [Terrain CLI](./terrain-example.md) page.

* **CyVerse APIs**.  The Cyverse Cyberinfrastructure is almost completely accessible through a set of Science APIs, allowing researchers to write their own scripts for automation and productivity.  The Agave APIs provide access to data management, high performance computing apps and jobs, metadata, and other APIs used to extend the Cyverse cyberinfrastructure.  The [DE APIs](https://cyverse-de.github.io/api/) (mentioned above) are accessible alongside Agave and provide access to Cyverse's HTC app catalogue and job execution.

* **Atmosphere deployment scripts**.  [Atmosphere](http://www.cyverse.org/atmosphere) is Cyverse's cloud-computing platform.  You can automate your workflows through Atmosphere by customizing deployment scripts that run automatically when launching an instance.  Information on this is found under *Step 4* of [Launching a New Instance](https://pods.iplantcollaborative.org/wiki/display/atmman/Launching+a+New+Instance)

* **Atmosphere APIs**.  Programmatic access methods to Atmosphere via APIs are coming soon.

* **BisQue automation**.  [BisQue](http://www.cyverse.org/bisque) (Bio-Image Semantic Query User Environment) allows you to store, visualize, organize and analyze images in the cloud. Learn how to automate analysis of images using [this tutorial](https://wiki.cyverse.org/wiki/display/BIS/Analyzing+BisQue+Data)

* **Agave Command Line Interface (CLI)**. Automate your existing DE workflows using Agave APIs via the command line. Learn how to effectively use the Agave CLI to take advantage of the CyVerse cyberinfrastructure [here](using-agave/README.md).

* **Mac OSX App Development Kit**. Automate CyVerse tasks with the click of a button from your Mac. ***Coming Soon***.

| [Back to CyVerse Developer Portal](../index.md) |
