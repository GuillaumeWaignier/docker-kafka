# docker-kafka

[![Build status](https://travis-ci.org/GuillaumeWaignier/kafka.svg?branch=master)](https://travis-ci.org/GuillaumeWaignier/kafka)

Docker image for Kafka.


## Usage (Docker)

```bash
docker run -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -p 9092:9092 ianitrix/kafka:latest
```

_Environment variables_

All kafka configuration is done with environment variables prefixed with **KAFKA_**

All dot is replaced by underscore and the variable name must be in upper case.

See the broker part of the [Apache documentation](https://kafka.apache.org/documentation/) for a full list of all possible configuration variables.
