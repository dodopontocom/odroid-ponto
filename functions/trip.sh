#!/bin/bash
#
#❌
#✅
#✖

trip.checklist() {
	local opt array
	opt=$1
  	array=(${opt})
  	array[0]="/trip"
  	opt=${array[@]:1}
  	case ${opt} in
		'list')
        		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Checklist da Nossa Viagem:" --reply_markup "$keyboard_trip_checklist"
		
			;;
		'edit')
        		list.edit
			#ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Checklist da Nossa Viagem:" --reply_markup "$keyboard_trip_checklist"
		
			;;
		'')
	        	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Checklist da Nossa Viagem:" --reply_markup "$keyboard_trip_checklist"
        
      			;;
  	esac
}
	
_message="Listando..."
_checklist=${BASEDIR}/texts/trip_checklist.csv

list.edit() {
	echo "to do function"
}

list.all() {
	while read line; do
		ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "$(echo -e ${_message})"
 	 	ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e $line)" --parse_mode markdown
	done < ${_checklist}
}
list.pending() {
	while read line; do
		if [[ $(echo $line | grep -E '❌') ]]; then
			ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "$(echo -e ${_message})"
	  		ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e $line)" --parse_mode markdown
		fi
	done < ${_checklist}
}
list.done() {
	while read line; do
		if [[ $(echo $line | grep -E '✅') ]]; then
			ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "$(echo -e ${_message})"
	  		ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e $line)" --parse_mode markdown
		fi
	done < ${_checklist}
}
list.search() {
	local regex
	
	if [[ "${callback_query_data}" == "btn_trip_outrosX" ]]; then
		regex='❌'
	elif [[ "${callback_query_data}" == "btn_trip_outrosV" ]]; then
		regex='✅'
	fi

	if [[ "${callback_query_data}" =~ btn_trip_outros. ]] ; then
		while read line; do
			if [[ $(echo $line | grep -E -v '^Comprar' | grep -E -v '^Passagens' | grep -E -v '^Trem'| grep -E "${regex}") ]]; then
				ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "$(echo -e ${_message})"
		  		ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e $line)" --parse_mode markdown
			fi
		done < ${_checklist}
	fi
	
	if [[ "${callback_query_data}" == "btn_trip_comprarX" ]]; then
		regex='❌'
	elif [[ "${callback_query_data}" == "btn_trip_comprarV" ]]; then
		regex='✅'
	fi

	if [[ "${callback_query_data}" =~ btn_trip_comprar. ]] ; then
		while read line; do
			if [[ $(echo $line | grep -E '^Comprar' | grep -E "${regex}") ]]; then
				ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "$(echo -e ${_message})"
		  		ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e $line)" --parse_mode markdown
			fi
		done < ${_checklist}
	fi
	
	if [[ "${callback_query_data}" == "btn_trip_passagensX" ]]; then
		regex='❌'
	elif [[ "${callback_query_data}" == "btn_trip_passagensV" ]]; then
		regex='✅'
	fi

	if [[ "${callback_query_data}" =~ btn_trip_passagens. ]] ; then
		while read line; do
			if [[ $(echo $line | grep -E '^Passagens' | grep -E "${regex}") ]]; then
				ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "$(echo -e ${_message})"
		  		ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e $line)" --parse_mode markdown
			fi
		done < ${_checklist}
	fi
	
	if [[ "${callback_query_data}" == "btn_trip_tremX" ]]; then
		regex='❌'
	elif [[ "${callback_query_data}" == "btn_trip_tremV" ]]; then
		regex='✅'
	fi
	
	if [[ "${callback_query_data}" =~ btn_trip_trem. ]] ; then
		while read line; do
			if [[ $(echo $line | grep -E '^Trem' | grep -E "${regex}") ]]; then
				ShellBot.answerCallbackQuery --callback_query_id ${callback_query_id[$id]} --text "$(echo -e ${_message})"
			  	ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} --text "$(echo -e $line)" --parse_mode markdown
			fi
		done < ${_checklist}
	fi
	
}
