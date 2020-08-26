#!/usr/bin/env sh

DOCKER_GROUP=${DOCKER_GROUP:?Please provide the docker group}

sudo addgroup --system -gid $DOCKER_GROUP docker && sudo usermod -aG docker jenkins

mkdir $HOME/.jenkins | true

if [ -z $OPTIONS ]; then
 java -jar /tmp/slave.jar -jnlpUrl "$JNPL_URL" -secret "$SECRET" -workDir "$WORKDIR"
else
 java -jar /tmp/slave.jar "$OPTIONS" -jnlpUrl "$JNPL_URL" -secret "$SECRET" -workDir "$WORKDIR"
fi
