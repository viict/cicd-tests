#!/bin/bash
pwd
SERVICES=`find ./ -name Makefile ! -path '*/node_modules/*'`
JSON='{"stage": "pr", "builds":{}, "deploy": false}'

for SERVICE in $SERVICES; do
    SERVICE_PATH=`echo $SERVICE | awk -F '/Makefile' '{ print $1 }' | awk -F '\./' '{ print $2 }'`
    echo "Service: $SERVICE_PATH on $SERVICE"
    FASTTRACK=`make --quiet -C $SERVICE_PATH fast_track`

    JSON=`jq --arg service ${SERVICE_PATH} --arg value ${FASTTRACK} '. | .jobs[$service]=$value' <<< $JSON`
done

echo $JSON
