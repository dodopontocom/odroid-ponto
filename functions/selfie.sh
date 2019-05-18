#!/bin/bash
#
source ${BASEDIR}/functions/random.sh

selfie.shot() {
  local message random_file_name error_message
  random_file_name=$(random.helper)
  message="*tirando uma foto 🤳*"
  error_message="*ops... agora não posso*\n"
  error_message+="...estou transmitindo ao vivo!"
  
  ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
  fswebcam -r 1280x720 /tmp/${random_file_name}.jpg
  if [[ $? -eq 0 ]]; then
    ShellBot.sendPhoto --chat_id ${message_chat_id[$id]} --photo @/tmp/${random_file_name}.jpg
  else
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${error_message})" --parse_mode markdown
  fi
    
}
