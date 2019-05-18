#!/bin/bash
#

linux.cmd() {
  local cmd array
  cmd=$1
  array=(${cmd})
  array[0]="/linux"
  cmd=${array[@]:1}
  
  if [[ ! -z ${cmd} ]]; then
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(${cmd})"
	else
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Usage: ${array[0]} <command>"
	fi
}