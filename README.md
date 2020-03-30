# docker-kafka

[![Build status](https://travis-ci.org/GuillaumeWaignier/docker-kafka.svg?branch=master)](https://travis-ci.org/GuillaumeWaignier/docker-kafka)

Generic docker image for all Kafka stack (kafka Broker, zookeeper, schema-registry, kafka-connect, ...).


## Configuration

All configurations are done with environment varibles prefixed with **KAFKA_**.
Environment varibles are case sensitive.
All underscore is replaced by a dot.

* Example

**KAFKA_stateDir_foo=bar** will produced **stateDir.bar** in the configuration file.



## Running process

The running process is choose with the **command** functionnality of Docker.



## Use case


* Zookeeper

```bash
docker run -e KAFKA_KAFKA_clientPort=2181 -e KAFKA_dataDir=/tmp/zookeeper -e KAFKA_tickTime=2000  -p 2181:2181 ianitrix/kafka:5.4.1 zookeeper-server-start
```

See the [Zookeeper documentation](https://docs.confluent.io/current/zookeeper/deployment.html) for a full list of all possible configuration variables.



* Broker

```bash
docker run -e KAFKA_zookeeper_connect=zookeeper:2181 -p 9092:9092 ianitrix/kafka:5.4.1 kafka-server-start
```


See the broker part of the [Apache documentation](https://kafka.apache.org/documentation/) for a full list of all possible configuration variables.


* Schema Registry

```bash
docker run -e KAFKA_listeners=http://0.0.0.0:8081 -p 8081:8081 ianitrix/kafka:5.4.1 schema-registry-start
```


See the [schema registry documentation](https://docs.confluent.io/current/schema-registry/installation/config.html) for a full list of all possible configuration variables.


* Kafka Connect

```bash
docker run -e KAFKA_bootstrap_servers=kafka:9092  -p 8083:8083 ianitrix/kafka:5.4.1 connect-distributed
```


See the [kafka connect documentation](https://docs.confluent.io/current/connect/userguide.html#connect-configuring-workers) for a full list of all possible configuration variables.

