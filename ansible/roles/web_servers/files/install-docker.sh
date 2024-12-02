#!/bin/bash

if command -v docker >/dev/null 2>&1; then
    echo "docker exists"
else
    echo "docker does not exist"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
fi


if command -v docker-compose >/dev/null 2>&1; then
    echo "docker-compose exists"
else
    echo "docker-compose does not exist"
    curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-linux-x86_64 -o docker-compose
    sudo chmod +x docker-compose
    sudo mv docker-compose /usr/local/bin/docker-compose
fi

