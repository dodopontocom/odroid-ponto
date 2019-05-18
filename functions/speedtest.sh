#!/bin/bash
#
source ${BASEDIR}/functions/random.sh

speedtest.check() {
  local message random_file_name
  message="Aguarde alguns instantes, estou verificando a velocidade da minha internet..."
  random_file_name=$(random.helper)
  
  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})"
  
  docker run --rm -i python:alpine sh -c "pip install speedtest-cli ; speedtest-cli --bytes --simple" > /tmp/${random_file_name}.txt
  message=$(tail -3 /tmp/${random_file_name}.txt)
  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})"
}
