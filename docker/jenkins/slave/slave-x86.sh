#!/bin/bash

docker build . -t jenkins-slave
docker run -d --init --network host --device=/dev/kvm --restart=on-failure --env-file .env jenkins-slave