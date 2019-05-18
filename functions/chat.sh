#!/bin/bash
#
source ${BASEDIR}/functions/random.sh

chat.hi() {
	local words random_number
	words=${BASEDIR}/texts/words.txt

	random_number=$(random.helper ${words})
	message=$(sed -n "${random_number}p" < ${words})
  	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
}
