FROM ghcr.io/felipecrs/jenkins-agent-dind:latest

USER root

# TuxMake
RUN wget -O /usr/share/keyrings/tuxmake.gpg https://tuxmake.org/packages/signing-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/tuxmake.gpg] https://tuxmake.org/packages/ ./" \
    > /etc/apt/sources.list.d/tuxmake.list
RUN apt update
RUN apt install -y tuxmake
