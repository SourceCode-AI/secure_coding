FROM ubuntu:latest
ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ="Europe/Prague"



RUN apt-get update &&\
    apt-get install -y diffoscope nano gcc wget jq screen python3-venv python3-pip strip-nondeterminism tree &&\
    pip3 install build


CMD ["/bin/bash"]
