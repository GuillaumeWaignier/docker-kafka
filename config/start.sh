#!/bin/sh

base_dir=$(dirname $0)

variable_prefix="KAFKA_"

IFS="
"



echo "#Generate config file"
for param in `env`
do
  case ${param} in
    ${variable_prefix}* )
      key=`echo ${param} | sed -e "s/^${variable_prefix}\([A-Z_0-9]*\)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | sed -e 's/_/./g' `
      value=`echo ${param} | sed -e "s/^${variable_prefix}[A-Z_0-9]*=\(.*\)/\1/g" `
      echo ${key}=${value} >> /config/server.properties
    ;;
  esac
done

# Execute
kafka-server-start /config/server.properties
