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

BUILDS=`echo $JSON | jq -r '.jobs|to_entries|map(select( (.value) != "FALSE" ))|map("      - build:
          name: \"Build \(.key)\"
          service_name: \(.key)
          requires:
            - checkout")|.[]'`
TESTS_REQUIRED=`echo $JSON | jq -r '.jobs|to_entries|map(select( (.value) != "FALSE" ))|map("            - \"Build \(.key)\"")|.[]'`

echo $JSON | jq

TEMPLATE=`cat ./.circleci/build_config.template.yml`

echo "$TEMPLATE" > ./.circleci/build_config.yml
echo "$BUILDS" >> ./.circleci/build_config.yml
echo "      - test:
          requires:
" >> ./.circleci/build_config.yml
echo "$TESTS_REQUIRED" >> ./.circleci/build_config.yml

# - "Build api"
# - "Build api/inner"
# - "Build frontend"
# - build:
#     name: "Build api"
#     service_name: api
#     requires:
#     - checkout
# - build:
#     name: "Build api/inner"
#     service_name: api/inner
#     requires:
#     - checkout
# - build:
#     name: "Build frontend"
#     service_name: frontend
#     requires:
#     - checkout