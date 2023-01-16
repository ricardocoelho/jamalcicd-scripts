#!/bin/bash

docker compose down --remove-orphans
docker-compose  up -d shell
docker attach p4tc_shell
docker compose down --remove-orphans