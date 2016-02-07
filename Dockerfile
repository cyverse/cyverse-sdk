######################################################
#
# Cyverse CLI Image
# Tag: cyverse-cli
#
# https://github.com/iPlantCollaborativeOpenSource/cyverse-sdk
#
# This container a Cyverse-branded, customized Agave CLI 
#
# docker run -it -v $HOME/.agave:/root/.agave iplantc/cyverse-cli bash
#
######################################################

FROM alpine
MAINTAINER Matthew Vaughn <vaughn@tacc.utexas.edu>
RUN apk add --no-cache git \
                       curl \
                       bash \
                       vim \
                       nano \
                       sed \
                       man \
                       wget \
                       grep

RUN curl -L -sk -o /usr/local/bin/jq "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" \
    && chmod a+x /usr/local/bin/jq

ADD cyverse-cli /usr/local/cyverse-cli

# set user's default env. This won't get sourced, but is helpful
RUN echo HOME=/root >> /root/.bashrc && \
    echo PATH=/usr/local/cyverse-cli/bin:$PATH >> /root/.bashrc && \
    echo AGAVE_CACHE_DIR=/root/.agave >> /root/.bashrc

RUN echo export PS1=\""\[\e[32;4m\]cyverse-cli\[\e[0m\]:\u@\h:\w$ "\" >> /root/.bashrc

ENV ENV /root/.bashrc

# Runtime parameters. Start a shell by default
VOLUME /root/.agave
CMD "/bin/bash"
