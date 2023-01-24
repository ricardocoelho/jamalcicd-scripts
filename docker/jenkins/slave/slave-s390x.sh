#!/bin/bash

docker run -d --init --privileged --network host --device=/dev/kvm --cap-add=NET_ADMIN --restart=on-failurejoseloolo/s390-docker \
--env-file .env \
/bin/bash -c 'java -jar agent.jar -jnlpUrl http://${JENKINS_URL}:8080/manage/computer/${JENKINS_AGENT_NAME}/jenkins-agent.jnlp -secret ${JENKINS_SECRET} -workDir "/home/jenkins/agent/"'
