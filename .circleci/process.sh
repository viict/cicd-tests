#!/bin/bash
pwd
SERVICES=`find ./ -name Makefile ! -path '*/node_modules/*'`

STAGE="test"
case $CIRCLE_BRANCH in
    development)
        STAGE=$CIRCLE_BRANCH
    ;;
    staging)
        STAGE=$CIRCLE_BRANCH
    ;;
    master)
        STAGE=$CIRCLE_BRANCH
    ;;
esac

JSON='{"stage": "'$STAGE'", "builds":{}, "deploy": false}'

for SERVICE in $SERVICES; do
    SERVICE_PATH=`echo $SERVICE | awk -F '/Makefile' '{ print $1 }' | awk -F '\./' '{ print $2 }'`
    echo "Service: $SERVICE_PATH on $SERVICE"
    FASTTRACK=`make --quiet -C $SERVICE_PATH fast_track`

    JSON=`jq --arg service ${SERVICE_PATH} --arg value ${FASTTRACK} '. | .builds[$service]=$value' <<< $JSON`
done

BUILDS=`echo $JSON | jq -r '.builds|to_entries|map(select( (.value) != "FALSE" ))|map("      - build:
          name: \"Build \(.key)\"
          service_name: \(.key)
          requires:
            - checkout")|.[]'`
TESTS=`echo $JSON | jq -r '.builds|to_entries|map(select( (.value) != "FALSE" ))|map("      - test:
          service_name: \(.key)
          stage: '$STAGE'")|.[]'`
TESTS_REQUIRED=`echo $JSON | jq -r '.builds|to_entries|map(select( (.value) != "FALSE" ))|map("            - \"Build \(.key)\"")|.[]'`

echo $JSON | jq

TEMPLATE=`cat ./.circleci/build_config.template.yml`
echo "$TEMPLATE" > ./.circleci/build_config.yml
echo "$TESTS" >> ./.circleci/build_config.yml
echo "
workflows:
  build-test:
    jobs:
      - checkout
" >> ./.circleci/build_config.yml
echo "$BUILDS" >> ./.circleci/build_config.yml
if [ "$TESTS_REQUIRED" != "" ]; then
    echo "      - test:
          requires:
" >> ./.circleci/build_config.yml
    echo "$TESTS_REQUIRED" >> ./.circleci/build_config.yml
fi
