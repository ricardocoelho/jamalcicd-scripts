#!/bin/bash

docker build -f Dockerfile.s390x -t mojatatucicd/s390x .

sh export-fs.sh

docker build -f Dockerfile.cross-s390x -t mojatatucicd/cross-s390x .

