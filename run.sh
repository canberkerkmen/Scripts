if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi;
export BEFORE_DATETIME=$(date -v -$1 +"%Y-%m-%dT%H:%M:%S.%NZ")
echo "BEFORE_DATETIME ${BEFORE_DATETIME}"
docker images -q | while read IMAGE_ID; do
    export IMAGE_CTIME=$(docker inspect --format='{{.Created}}' --type=image ${IMAGE_ID})
    if [[ "${BEFORE_DATETIME}" > "${IMAGE_CTIME}" ]]; then
        echo "Removing ${IMAGE_ID}, ${BEFORE_DATETIME} is earlier then ${IMAGE_CTIME}"
        docker rmi -f ${IMAGE_ID};
    fi;
done