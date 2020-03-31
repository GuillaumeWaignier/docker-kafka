# docker-kafka

[![Build status](https://travis-ci.org/GuillaumeWaignier/docker-kafka.svg?branch=master)](https://travis-ci.org/GuillaumeWaignier/docker-kafka)

Generic docker image for all Kafka stack (kafka Broker, zookeeper, schema-registry, kafka-connect, ...).


## Configuration

All configurations are done with environment varibles prefixed with **KAFKA_**.
Environment varibles are case sensitive.
All underscore is replaced by a dot.

* Example

**KAFKA_stateDir_foo=bar** will produced **stateDir.foo=bar** in the configuration file.



## Running process

The running process is choose with the **command** functionnality of Docker.



## Use case


* Zookeeper

```bash
docker run -e KAFKA_KAFKA_clientPort=2181 -e KAFKA_dataDir=/tmp/zookeeper -p 2181:2181 ianitrix/kafka:5.4.1 zookeeper-server-start
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


## Docker compose

```yaml
version: "3.7"
services:
  zookeeper:
    image: "ianitrix/kafka:${CONFLUENT_VERSION}"
    hostname: zookeeper
    command: zookeeper-server-start
    networks:
      - confluent
    environment:
      - KAFKA_SERVER_ID=1
      - KAFKA_clientPort=2181
      - KAFKA_dataDir=/tmp/zookeeper
      - KAFKA_tickTime=2000
      - KAFKA_4lw_commands_whitelist=stat, ruok, conf, isro
      - KAFKA_OPTS=-Xms128m -Xmx128m
    healthcheck:
      test: test `echo "ruok" | nc localhost 2181 | grep "imok"`
      interval: 2s
      timeout: 2s
      retries: 3
      start_period: 2s

  kafka:
    image: "ianitrix/kafka:${CONFLUENT_VERSION}"
    hostname: kafka
    command: kafka-server-start
    ports:
      - 9092:9092
    networks:
      - confluent
    depends_on:
      - zookeeper
    environment:
      - KAFKA_broker_id=101
      - KAFKA_zookeeper_connect=zookeeper:2181
      - KAFKA_listener_security_protocol_map=PLAINTEXT:PLAINTEXT
      - KAFKA_advertised_listeners=PLAINTEXT://kafka:9092
      - KAFKA_listeners=PLAINTEXT://:9092
      - KAFKA_inter_broker_listener_name=PLAINTEXT
      - KAFKA_auto_create_topics_enable=true
      - KAFKA_delete_topic_enable=true
      - KAFKA_offsets_topic_replication_factor=1
      - KAFKA_OPTS=-Xms256m -Xmx256m
    restart: on-failure
    healthcheck:
      test: nc -z localhost 9092
      interval: 2s
      timeout: 2s
      retries: 3
      start_period: 2s

  schema-registry:
    image: "ianitrix/kafka:${CONFLUENT_VERSION}"
    hostname: schema-registry
    command: schema-registry-start
    depends_on:
      - kafka
    ports:
      - 8081:8081
    networks:
      - confluent
    environment:
      - SCHEMA_REGISTRY_OPTS=-Xms256m -Xmx256m
      - KAFKA_listeners=http://0.0.0.0:8081
      - KAFKA_host_name=schema-registry
      - KAFKA_kafkastore_connection_url=zookeeper:2181
      - KAFKA_kafkastore_bootstrap_servers=PLAINTEXT://kafka:9092
      - KAFKA_kafkastore_security_protocol=PLAINTEXT
      - KAFKA_kafkastore_topic_replication_factor=1
      - KAFKA_default_replication_factor=1
    restart: on-failure
    healthcheck:
      test: test `curl -s -o /dev/null -w "%{http_code}" http://localhost:8081` = 200
      interval: 2s
      timeout: 2s
      retries: 3
      start_period: 2s

  kafka-connect:
    image: "ianitrix/kafka:${CONFLUENT_VERSION}"
    command: connect-distributed
    hostname: kafka-connect
    depends_on:
      - kafka
    ports:
      - 8083:8083
    networks:
      - confluent
    healthcheck:
      test: test `curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/connectors` = 200
      interval: 2s
      timeout: 2s
      retries: 10
      start_period: 2s
    environment:
      - KAFKA_OPTS=-Xms512m -Xmx512m
      - KAFKA_bootstrap_servers=kafka:9092
      - KAFKA_rest_port=8083
      - KAFKA_group_id=connect
      - KAFKA_config_storage_topic=_connect-config
      - KAFKA_offset_storage_topic=_connect-offsets
      - KAFKA_status_storage_topic=_connect-status
      - KAFKA_replication_factor=1
      - KAFKA_config_storage_replication_factor=1
      - KAFKA_offset_storage_replication_factor=1
      - KAFKA_status_storage_replication_factor=1
      - KAFKA_key_converter=org.apache.kafka.connect.json.JsonConverter
      - KAFKA_value_converter=org.apache.kafka.connect.json.JsonConverter
      - KAFKA_key_converter_schemas_enable=false
      - KAFKA_value_converter_schemas_enable=false
      - KAFKA_internal_key_converter=org.apache.kafka.connect.json.JsonConverter
      - KAFKA_internal_value_converter=org.apache.kafka.connect.json.JsonConverter
      - KAFKA_rest_advertised_host_name=kafka-connect
      - KAFKA_plugin_path=/confluent-${CONFLUENT_VERSION}/share/java
      - KAFKA_log4j_root_loglevel=INFO
      - KAFKA_log4j_loggers=org.reflections=ERROR
    restart: on-failure


  kafkahq:
    image: tchiotludo/kafkahq:0.12.0
    networks:
      - confluent
    ports:
      - "8080:8080"
    environment:
      KAFKAHQ_CONFIGURATION: |
        kafkahq:
          connections:
            docker-kafka-server:
              properties:
                bootstrap.servers: "kafka:9092"
              schema-registry:
                url: "http://schema-registry:8081"
              connect:
                - name: default
                  url: "http://kafka-connect:8083"

networks:
  confluent:
    name: confluent

```
