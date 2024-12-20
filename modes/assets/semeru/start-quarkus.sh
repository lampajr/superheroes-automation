#!/bin/bash

ENDPOINT=${1}

# Check if the directory "cr" exists
if [ -d "cr" ]; then
    exec dumb-init --rewrite 15:2 -- "./restore.sh"
else
    echo "start checkpoint run"
    for i in {1..500}; do ./pidplus.sh; done
    mkdir cr
    $JAVA_HOME/bin/java -XX:CRaCCheckpointTo=cr -Dopenj9.internal.criu.unprivilegedMode=true ${JAVA_OPTS} ${JAVA_OPTS_APPEND} -jar ${JAVA_APP_JAR} 1>out 2>err </dev/null &

    sleep 5

    if [[ "${ENDPOINT}" != "" ]]
    then
      for i in {1..3}; do curl -s -w ''%{http_code}'' ${ENDPOINT} ; echo ""; done
    fi
    $JAVA_HOME/bin/jcmd ${JAVA_APP_JAR} JDK.checkpoint
    cat out
    cat err
    sleep 10
    echo "end checkpoint run"
fi

