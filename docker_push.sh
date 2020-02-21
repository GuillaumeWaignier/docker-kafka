#!/bin/bash
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker tag $TRAVIS_COMMIT ianitrix/kafka:${1}
docker push ianitrix/kafka:${1}
