#!/bin/bash

SERVICE_NAME=$1
SERVICE_VERSION=$2

SWARM_SERVICE_NAME=$(docker service ls --format '{{.Name}} {{.Image}}' | grep -i ${SERVICE_NAME}:${SERVICE_VERSION} | awk '{print $1}');

echo "Checking status of ${SERVICE_NAME} with service name in swarm is ${SWARM_SERVICE_NAME}"

if [[ $SWARM_SERVICE_NAME == '' ]]; then
    echo "Monitor failed, ${SERVICE_NAME} could not be deployed because swarm service name couldn't be found."
    exit 1
fi;

SERVICE_MODE=$(docker service inspect --pretty ${SWARM_SERVICE_NAME} | grep -i "Service Mode" | awk '{print $3}');

if [[ ${SERVICE_MODE} == "Global" ]]; then
    SERVICE_INSTANCE_COUNT=$(docker node ls | grep Active -c)
    echo "Service mode is global with ${SERVICE_INSTANCE_COUNT} nodes"
else
    SERVICE_INSTANCE_COUNT=$(docker service inspect --pretty ${SWARM_SERVICE_NAME} | grep -i "Replicas" | awk '{print $2}')
    echo "Service mode is replicated with ${SERVICE_INSTANCE_COUNT} replicas"
fi

PROCESS_TIME=$((SECONDS+60))
SLEEP_TIME=5
SUCCESS=false

while [ $SECONDS -lt ${PROCESS_TIME} ]; do
    RUNNING_SERVICE_INSTANCE_COUNT=$(docker service ps ${SWARM_SERVICE_NAME} --format '{{.CurrentState}} {{.Image}}' | grep Running.*${SERVICE_NAME}:${SERVICE_VERSION} -c)
    
    echo "${RUNNING_SERVICE_INSTANCE_COUNT} instance is deployed."
    
    if [[ ${RUNNING_SERVICE_INSTANCE_COUNT} == ${SERVICE_INSTANCE_COUNT} ]]; then
        echo "Deployment completed."
        SUCCESS=true
        break
    else
        echo "deployment for ${SERVICE_NAME} not yet complete.Waiting ${SLEEP_TIME} seconds."
        sleep ${SLEEP_TIME}
    fi

    DURATION=$SECONDS
    printf 'Time spent: %02d:%02d\n' $(($DURATION / 60)) $(($DURATION % 60))
done

if ${SUCCESS}; then
    echo "Monitor finished, ${SERVICE_NAME} has been deployed."
    exit 0
else
    echo "Monitor failed, ${SERVICE_NAME} could not be deployed."
    exit 1
fi
