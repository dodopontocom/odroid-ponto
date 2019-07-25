#!/bin/bash

#IDS=($(ls -1 ${BASEDIR}/logs))
#IDS=(11504381 135810713 184152399 21025096 232486786 362003074 449542698 736298753 815573690 831690845 882808182 989422706)

avisos.on() {
  local message log
  
  log=${BASEDIR}/logs/${message_from_id}
  message="avisos on"
  
  mkdir ${log}/avisos.alert
  
  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
}

avisos.off() {
  local message log
  
  log=${BASEDIR}/logs/${message_from_id}
  message="avisos off"
  
  rm -fv ${log}/avisos.alert
  
  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
}

avisos.send() {
  local message
  
  message="Olá , tudo bem?\n"
  message+="Passando por aqui para perguntar se você lembrou de bater o ponto hoje!? 🤔\n"
  message+="Caso não queira mais avisos /avisosOff"

  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
}
