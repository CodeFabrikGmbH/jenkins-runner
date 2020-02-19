#!/usr/bin/env sh

mkdir $HOME/.jenkins | true

java -jar /tmp/slave.jar -jnlpUrl $JNPL_URL -secret $SECRET