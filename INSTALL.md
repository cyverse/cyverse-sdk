INSTALLATION INSTRUCTIONS
=========================

Prerequisites
-------------

Disclaimer: CyVerse SDK works best on macOS and Linux. Your best option on Windows is to use the official Docker image. 

* Unix-like operating system (macOS or Linux)
* Bash should be installed (v3.2 or more recent).
* curl should be installed
* git should be installed

Use curl Installer
------------------

```
curl -L https://cyverse.github.io/cyverse-sdk/install/install.sh | sh
source ~/.bashrc
cyverse-sdk-info
```

Install from source
-------------------

```
git clone https://github.com/cyverse/cyverse-sdk.git
cd cyverse-sdk
make && make install
# Append $HOME/cyverse-cli/bin to $PATH
echo "PATH=\$PATH:\$HOME/cyverse-cli/bin" >> ~/.bashrc
source ~/.bashrc
# Test that one of the tools is runnable
cyverse-sdk-info
```

Use the official Docker image
-----------------------------

```
docker pull cyverse/cyverse-cli
docker run -it -v $HOME/.agave:/root/.agave cyverse/cyverse-cli cyverse-sdk-info
```

_Insert Docker+Powershell instructions for Win10 here_
