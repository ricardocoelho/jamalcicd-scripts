#!/bin/bash

docker build . -t jenkins-tuxmake-slave
docker run -d --init --privileged --network host --device=/dev/kvm \
  --restart=always --env-file .env --group-add=docker jenkins-tuxmake-slave
