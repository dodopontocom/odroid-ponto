#!/bin/bash
#
#sleep 10

# Importando API
BASEDIR=$(dirname $0)
source ${BASEDIR}/ShellBot.sh
source ${BASEDIR}/functions/start.sh
source ${BASEDIR}/functions/baterponto.sh
source ${BASEDIR}/functions/send_notification.sh

######################################################################################
#source <(cat ${BASEDIR}/functions/*.sh)
#for f in ${BASEDIR}/functions/*.sh; do source $f; done
######################################################################################

logs=${BASEDIR}/logs

# Token do bot
bot_token=$(cat ${BASEDIR}/.token)

VERSION=$(cd ${BASEDIR} ; git branch | grep -E "\*" ; cd -)
BT_VERSION=${VERSION:2}

# Inicializando o bot
ShellBot.init --token "$bot_token" --monitor --flush

ShellBot.ReplyKeyboardRemove

btn_config='
["Alertas ->", "30min", "*15min", "5min"],
["Resumos ->", "Dia", "Semana", "Mês"],
["Período Diário ->", "*8Hs", "7Hs", "6Hs"],
["Ajuda ⁉️", "Conf ⚙", "Editar 💾"]
'

config_keyboard1="$(ShellBot.ReplyKeyboardMarkup --button 'btn_config' --one_time_keyboard true)"

btn_opcoes='
["Entrada ⌛"],
["Almoço 🍔", "Volta Almoço ☕"],
["Saída 🙏"],
["Ajuda ⁉️", "Editar 💾"]
'
#["Ajuda ⁉️", "Conf ⚙", "Editar 💾"]

ch_keyboard1="$(ShellBot.ReplyKeyboardMarkup --button 'btn_opcoes' --one_time_keyboard true)"

#######################################################################################
#❌
#✅
############### keyboard para o comando trip #######################################

while :
do
	
	ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30

	################# check if any user needs to be alerted about lunch time
	for file in $(find $logs -name "$(date +%Y%m%d).csv"); do
		if [[ ! -f ${file}.alert15 ]]; then
			baterponto.lunchAlert $file
		fi
		if [[ ! -f ${file}.alert5 ]]; then
			baterponto.lunchAlert $file
		fi
	done
	########################################################################
	
	for id in $(ShellBot.ListUpdates)
	do
	(
		ShellBot.watchHandle --callback_data ${callback_query_data[$id]}
		
		if [[ ${message_entities_type[$id]} == bot_command ]]; then
			if [[ "$(echo ${message_text[$id]%%@*} | grep "^\/start" )" ]]; then
				
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "\`(versão beta: $(echo $BT_VERSION))\`" \
									--parse_mode markdown
				
				start.sendGreetings
				
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Comece me enviando um \`Oi\`" \
									--parse_mode markdown
			fi
			if [[ "$(echo ${message_text[$id]%%@*} | grep "^\/avisos" )" ]]; then
				
				avisos.on
			fi
			if [[ "$(echo ${message_text[$id]%%@*} | grep "^\/avisoOff" )" ]]; then
				
				avisos.off
			fi
		else
			case ${message_text[$id]} in
				"Entrada ⌛") baterponto.entrada
					;;
				"Almoço 🍔") baterponto.almoco
					;;
				"Volta Almoço ☕") baterponto.volta
					;;
				"Saída 🙏") baterponto.saida
					;;
				"Ajuda ⁉️")	 start.sendGreetings
							ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Comece me enviando um \`Oi\`" \
												--parse_mode markdown
					;;
				"Conf ⚙")
							ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "*Edite as Configurações*" \
									--reply_markup "$config_keyboard1" --parse_mode markdown
							ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Em Construção 🚷" --parse_mode markdown
					;;
				"Editar 💾") ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "Em Construção 🚷" --parse_mode markdown
					;;
				*)  
					ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "*Marcar Ponto*" \
									--reply_markup "$ch_keyboard1" --parse_mode markdown
					;;

			esac
		fi
	) & 
	done
done
#FIM
