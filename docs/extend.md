# Extend CyVerse Capabilities

CyVerse allows user-developers to integrate their own resources and applications for their own use, and to share these with their collaborators at their discretion.

* **Dockerize Your Tools for the CyVerse Discovery Environment.** [Docker](https://www.docker.com/) facilitates platform-independent installation of software, enhancing reproducibility.  [Click here for instructions](https://wiki.cyverse.org/wiki/display/DEmanual/Dockerizing+Your+Tools+for+the+CyVerse+Discovery+Environment) on how to use Docker to add new applications to the CyVerse DE.  There is also a helpful [video tutorial](https://wiki.cyverse.org/wiki/display/Events/Focus+Forum+Webinar+-+Using+Docker+to+Bring+Tools+into+the+Discovery+Environment) available.

* **Bring in new Metadata templates.** CyVerse supports [metadata templates](https://pods.iplantcollaborative.org/wiki/display/DEmanual/Using+Metadata+in+the+DE) to facilitate associating attributes with data.  To add a new metadata template to CyVerse, please contact [data_curator@cyverse.org](mailto:data_curator@cyverse.org).

* **Publish your own image in Atmosphere.**
[Atmosphere](https://atmo.cyverse.org/) is CyVerse's cloud-computing platform. 
Customize your own preconfigured virtual machine and create a sharable template (i.e. image).
Simply launch an instance, install the software and 
files you want to use, and then request an image of the instance 
using the Request Imaging form within Atmosphere, as [detailed here](https://pods.iplantcollaborative.org/wiki/display/atmman/Requesting+an+Image+of+an+Instance).

* **Add new algorithms to Bisque.**
[Bisque](https://bisque.cyverse.org) supports viewing, annotating, processing, 
and sharing image data through a web-based platform. 
Additional image analysis algorithms, or modules, can be be integrated and shared 
using the Python API wrapping of the Bisque REST interfaceas as described in this [downloadable pdf document](https://wiki.cyverse.org/wiki/download/attachments/22675956/BisqueOverviewModules.pdf).

* **Bring in new tools and resources using the Agave APIs.**
CyVerse provides full scriptable access to its underlying infrastructure.  Use the [CyVerse SDK](cyversesdk.md) to quickly interface with the [Agave API](https://www.agaveapi.co) to customize your capabilites and infrastructure within CyVerse.

| [Back to CyVerse Developer Portal](../index.md) |
