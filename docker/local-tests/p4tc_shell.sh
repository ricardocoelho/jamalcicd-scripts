#!/bin/bash

#To be able to run docker tests on shell mode run the follow commands

docker-compose  up -d shell
docker attach p4tc_shell

#docker-compose down
