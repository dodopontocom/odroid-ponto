#!/bin/bash

#IDS=($(ls -1 ${BASEDIR}/logs))
#IDS=(11504381 135810713 184152399 21025096 232486786 362003074 449542698 736298753 815573690 831690845 882808182 989422706)

avisos.on() {
  local message log
  
  log=${BASEDIR}/logs/${message_from_id}
  
  
  if [[ -f ${log}/avisos.alert ]]; then
    message="Lembretes já ativados, caso queira desligar /avisoOff"
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
  else
    mkdir ${log}/avisos.alert
    message="Lembretes On"
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
  fi
}

avisos.off() {
  local message log
  
  log=${BASEDIR}/logs/${message_from_id}
  if [[ ! -f ${log}/avisos.alert ]]; then
    message="Lembretes não estão ativados, caso queira ligar /avisos"
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
  else
    rm -vf ${log}/avisos.alert
    message="Lembretes Off"
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
  fi
}

avisos.send() {
  local message
  
  message="Olá , tudo bem?\n"
  message+="Passando por aqui para perguntar se você lembrou de bater o ponto hoje!? 🤔\n"
  message+="Caso não queira mais avisos /avisoOff"

  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
}
