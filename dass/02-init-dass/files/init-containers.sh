#!/bin/sh

TIMEZONE=$(cat /etc/timezone)

docker_images_watchtower=$(docker images -q containrrr/watchtower)
docker_images_dass=$(docker images -q domassistant/dass)
docker_images_dasssetup=$(docker images -q domassistant/dass-setup-in-progress)

if [ -n "$docker_images_dasssetup" ]; then
  logger -t "dass-init" "dass Setup Progress image exist, Cool...."
else
  logger -t "dass-init" "dass Setup Progress image is missing, creating them...."
  docker run -d \
    --name dass-setup-in-progress \
    --network=host \
    --log-opt max-size=1m \
    domassistant/dass-setup-in-progress
fi

if [ -n "$docker_images_watchtower" ]; then
  logger -t "dass-init" "Watchtower container exist, Cool...."
else
  logger -t "dass-init" "Watchtower container missing, creating them...."
  docker run -d \
    --name watchtower \
    --log-opt max-size=10m \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup --include-restarting
fi

if [ -n "$docker_images_dass" ]; then
  logger -t "dass-init" "dass container exist, Cool...."
else
  logger -t "dass-init" "dass image is missing, pulling them...."
  docker pull domassistant/dass:v4
  logger -t "dass-init" "dass image is pulled, deleting setup container"
  docker stop dass-setup-in-progress && docker rm dass-setup-in-progress
  logger -t "dass-init" "dass container is missing, creating them...."
  docker run -d \
    --cgroupns host \
    --restart=always \
    --privileged \
    --network=host \
    --log-opt max-size=10m \
    --name dass \
    --cap-add SYS_RAWIO \
    -e NODE_ENV=production \
    -e SERVER_PORT=80 \
    -e SQLITE_FILE_PATH=/var/lib/domassistant/dass-production.db \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/domassistant:/var/lib/domassistant \
    -v /dev:/dev \
    -v /run/udev:/run/udev:ro \
    -v /sys/class/gpio:/sys/class/gpio \
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/timezone:/etc/timezone:ro \
    domassistant/dom-assistant:latest
fi

logger -t "dass-init" "Prune unused images...."
docker image prune -f
