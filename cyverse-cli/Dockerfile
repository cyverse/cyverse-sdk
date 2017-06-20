######################################################
#
# Agave CLI Image
# Tag: agave-cli
#
# https://bitbucket.org/agaveapi/cli
#
# This is the official image for the Agave CLI and can be used for
# parallel environment testing.
#
# docker run -it -v $HOME/.agave:/agave agaveapi/cli bash
#
######################################################

FROM ubuntu:trusty

MAINTAINER Rion Dooley <dooley@tacc.utexas.edu>

# base environment and user
ENV CLI_USER agave
ENV AGAVE_CLI_HOME /usr/local/agave-cli

# update dependencies
RUN apt-get update && \
    apt-get install -y git vim.tiny curl jq unzip bsdmainutils ttyrec

# Create non-root user.
RUN mkdir /home/$CLI_USER && \
    cp /etc/skel/.bash* /home/$CLI_USER/ && \
    cp /etc/skel/.profile /home/$CLI_USER/ && \
    echo "$CLI_USER:x:6737:6737:Ngrok user:/home/$CLI_USER:/bin/false" >> /etc/passwd && \
    echo "$CLI_USER:x:6737:" >> /etc/group && \
    chown -R $CLI_USER:$CLI_USER /home/$CLI_USER && \
    chmod -R go=u,go-w /home/$CLI_USER && \
    chmod go= /home/$CLI_USER

# configure ngrok to locally receive webhooks behind a NAT
RUN curl -sk -o /ngrok.zip 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip' && \
    unzip ngrok.zip -d /bin && \
    rm -f ngrok.zip && \

    mkdir -p $AGAVE_CLI_HOME/http/log && \
    touch $AGAVE_CLI_HOME/http/log/httpmirror.log && \
    chown -R $CLI_USER:$CLI_USER $AGAVE_CLI_HOME/http/log && \
    mkdir /.ngrok2 && \
    echo "web_addr: 0.0.0.0:4040" >> /.ngrok2/ngrok.yml && \
    chmod -R 755 /.ngrok2 && \
    echo alias ngrok_url=\''curl -s http://localhost:4040/api/tunnels | jq -r ".tunnels[0].public_url"'\' >> /home/$CLI_USER/.bashrc

# install bats test harness
RUN git clone https://github.com/calj/bats.git && \
    cd bats && \
    ./install.sh /usr/local

# configure environment and init default tenant
RUN echo export PS1=\""\[\e[32;4m\]agave-cli\[\e[0m\]:\u@\h:\w$ "\" >> /home/$CLI_USER/.bashrc && \
    echo 'export PATH=$PATH:$AGAVE_CLI_HOME/bin:$AGAVE_CLI_HOME/http/bin' >> /home/$CLI_USER/.bashrc  && \

    # Fix the vim.tiny terminal emulation
    curl -sk 'https://bitbucket.org/!api/2.0/snippets/deardooley/AEddG/master/files/.vimrc' >> /home/$CLI_USER/.vimrc && \

    mkdir /agave && \
    chown -R $CLI_USER:$CLI_USER /agave && \
    chown -R $CLI_USER:$CLI_USER $AGAVE_CLI_HOME


# switch to cli user so we don't run as root
USER $CLI_USER
WORKDIR /home/$CLI_USER

# enable bash completion
RUN echo ". $AGAVE_CLI_HOME/completion/agave-cli" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_SHOW_FILES=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_SHOW_JOB_OUTPUTS_PATHS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_APPS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_CLIENTS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_FILES=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_JOBS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_METADATA=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_MONITORS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_NOTIFICATIONS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_POSTITS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_PROFILES=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_SYSTEMS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_TAGS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_TENANTS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_TRANSFERS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_CACHE_TRANFORMS=yes" >> $HOME/.bashrc && \
    echo "export AGAVE_CLI_COMPLETION_SHOW_FILE_PATHS=yes" >> $HOME/.bashrc

ENV PS1 "\[\e[32;4m\]agave-cli\[\e[0m\]:\u@\h:\w$ "
ENV SHELL /bin/bash
ENV HTTP_PORT 3000
ENV PATH $PATH:$AGAVE_CLI_HOME/bin:$AGAVE_CLI_HOME/http/bin
ENV AGAVE_DEVEL_MODE ''
ENV AGAVE_DEVURL ''
ENV AGAVE_CACHE_DIR /agave
ENV AGAVE_JSON_PARSER jq
ENV WEBHOOK_LOG $AGAVE_CLI_HOME/http/log/httpmirror.log
ENV TERM xterm

# add CLI assets
COPY . $AGAVE_CLI_HOME

# init public denant by default
RUN auth-switch -b https://public.agaveapi.co -t agave.prod -S

# shipping a static binary to save some build time. uncomment to rebuild binary from source
#RUN apt-get install -y golang && \
#    cd $AGAVE_CLI_HOME/http && \
#    GOBIN=$AGAVE_CLI_HOME/http/bin go install src/HttpMirror.go && \
#    apt-get remove -y golang


EXPOSE 4040

# Runtime parameters. Start a shell by default
VOLUME /agave
VOLUME /home/agave
VOLUME /usr/local/agave-cli

CMD "/bin/bash"
