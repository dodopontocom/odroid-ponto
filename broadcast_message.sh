#!/bin/bash

BASEDIR=$(dirname $0)

token=$(tail -1 ${BASEDIR}/.token)
IDS=($(ls -1 ${BASEDIR}/logs))
message=${1:-teste}

for i in ${IDS[@]}; do
  curl -s -X POST -d chat_id=${i} -d text="$(echo -e ${message})" https://api.telegram.org/bot${token}/sendMessage
  if [[ $? -eq 0 ]]; then
    echo "mensagem enviada para ${i} com sucesso"
  fi
done
