#!/bin/bash
#
source ${BASEDIR}/functions/random.sh

voice.convert() {
  local message array random_file_name
  message=$1
  array=(${message})
  array[0]="/linux"
  message=${array[@]:1}
  random_file_name=$(random.helper)

  if [[ ! -z ${message} ]]; then
    #docker run -i --rm -e "MESSAGE=$message" -v ${PWD}:/data -w /data ozzyjohnson/tts bash -c 'export; echo "${MESSAGE}" > text.txt; cat text.txt; espeak -f text.txt --stdout > /data/voice.ogg'
    #docker run -i --rm -e "MESSAGE=$message" -v ${PWD}:/data -w /data ozzyjohnson/tts bash -c 'espeak "${MESSAGE}" --stdout > voice.ogg'
    espeak -vpt "${message}}" --stdout > /tmp/${random_file_name}.ogg
    ShellBot.sendVoice --chat_id ${message_chat_id[$id]} --voice @/tmp/${random_file_name}.ogg
  else
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Please, envie um texto para ser sintetizado" --parse_mode markdown
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text '`/voice <texto qualquer>`' --parse_mode markdown
  fi
}
