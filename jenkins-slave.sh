#!/usr/bin/env sh

mkdir $HOME/.jenkins | true

java -jar /tmp/slave.jar "$OPTIONS" -jnlpUrl "$JNPL_URL" -secret "$SECRET" -workDir "$WORKDIR"