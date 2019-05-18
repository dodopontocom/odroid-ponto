#!/bin/bash
#
BASEDIR=$(dirname $0)
txt=${BASEDIR}/texts/start.txt

ping.pong() {
  message="* P o n G 🏓*"
  btn='["🏓 P o n G 🏓"]'								  		
  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
}
