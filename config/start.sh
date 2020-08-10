#!/bin/bash

base_dir=$(dirname $0)
file="/config/config.properties"

variable_prefix="KAFKA_"

IFS="
"


echo "#Generate config file ${file}"
for param in `env`
do
  case ${param} in
    ${variable_prefix}* )
      key=`echo ${param} | sed -e "s/^${variable_prefix}\([A-Za-z_0-9-]*\)=.*/\1/g" | sed -e 's/_/./g' `
      value=`echo ${param} | sed -e "s/^${variable_prefix}[A-Za-z_0-9-]*=\(.*\)/\1/g" `
      echo ${key}=${value} >> ${file}
    ;;
  esac
done


if test "${DEBUG}" = "true"
then
  echo "config file ${file} is"
  cat ${file}
fi

# Execute
echo "$@ ${file}"
$@ ${file}
