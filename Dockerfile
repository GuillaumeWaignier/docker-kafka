FROM openjdk:11


ARG CONFLUENT_MAJOR_VERSION=5
ARG CONFLUENT_MINOR_VERSION=5
ARG CONFLUENT_FIX_VERSION=1
ARG KAFKA_SCALA_VERSION=2.12

ENV DOCKER_IMAGE_TAG_VERSION=${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION}.${CONFLUENT_FIX_VERSION}
ENV DOCKER_IMAGE_NAME=kafka
ENV PATH=/confluent-${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION}.${CONFLUENT_FIX_VERSION}/bin:$PATH

ADD config /config

RUN apt-get update -y \
    && apt-get install netcat -y \
    && wget -O confluent.zip https://packages.confluent.io/archive/${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION}/confluent-community-${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION}.${CONFLUENT_FIX_VERSION}-${KAFKA_SCALA_VERSION}.zip \
    && unzip /confluent.zip -d / \
    && rm /confluent.zip \
    && chmod +x /config/start.sh

WORKDIR /config

EXPOSE 9092
VOLUME [ "/data"]

ENTRYPOINT ["/config/start.sh"]
CMD ["kafka-server-start"]
