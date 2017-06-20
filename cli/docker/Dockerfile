######################################################
#
# Agave CLI Image
# Tag: agave-cli
#
# https://bitbucket.org/agaveapi/cli
#
# This container the Agave CLI and can be used for
# parallel environment testing.
#
# docker run -it -v $HOME/.agave:/root/.agave agaveapi/cli bash
#
######################################################

FROM ubuntu:trusty

MAINTAINER Rion Dooley <dooley@tacc.utexas.edu>

RUN apt-get update && \
    apt-get install -y git vim.tiny curl jq && \

    curl -L -sk -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" && \
    chmod a+x /usr/local/bin/jq


    # install the cli from git
    git clone https://bitbucket.org/taccaci/foundation-cli /usr/local/agave-cli && \
    chmod +x /usr/local/agave-cli/bin/*

    # set user's default env. This won't get sourced, but is helpful
    echo HOME=/root >> /root/.bashrc && \
    echo PATH=/usr/local/agave-cli/bin:$PATH >> /root/.bashrc && \
    echo AGAVE_CACHE_DIR=/root/.agave >> /root/.bashrc && \
    echo AGAVE_CACHE_DIR=/root/.agave >> /root/.bashrc && \

    echo export PS1=\""\[\e[32;4m\]agave-cli\[\e[0m\]:\u@\h:\w$ "\" >> /root/.bashrc

    /usr/local/agave-cli/bin/tenants-init -t agave.prod

ENV ENV /root/.bashrc

VOLUME /root/.agave

# Runtime parameters. Start a shell by default
CMD "/bin/bash"
