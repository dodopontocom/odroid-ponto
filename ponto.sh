#!/bin/bash
#
sleep 10

# Importando API
BASEDIR=$(dirname $0)
source ${BASEDIR}/ShellBot.sh
source ${BASEDIR}/functions/start.sh
source ${BASEDIR}/functions/baterponto.sh

######################################################################################
#source <(cat ${BASEDIR}/functions/*.sh)
#for f in ${BASEDIR}/functions/*.sh; do source $f; done
######################################################################################

logs=${BASEDIR}/logs

# Token do bot
bot_token=$(cat ${BASEDIR}/.token)

# Inicializando o bot
ShellBot.init --token "$bot_token" --monitor --flush

btn_opcoes='
["Entrada ⌛"],
["Almoço 🍔", "Volta Almoço ☕"],
["Saída 🙏"],
["Ajuda", "Configuracoes", "Editar"]
'

ch_keyboard1="$(ShellBot.ReplyKeyboardMarkup --button 'btn_opcoes' --one_time_keyboard true)"



#######################################################################################
#❌
#✅
############### keyboard para o comando trip #######################################
botao2=''
ShellBot.InlineKeyboardButton --button 'botao2' --line 1 --text 'Listar Todos' --callback_data 'btn_trip_list'
ShellBot.InlineKeyboardButton --button 'botao2' --line 2 --text 'Listar ✅' --callback_data 'btn_trip_done'
ShellBot.InlineKeyboardButton --button 'botao2' --line 2 --text 'Listar ❌' --callback_data 'btn_trip_pending'
ShellBot.InlineKeyboardButton --button 'botao2' --line 4 --text 'Listar Passagens ✅' --callback_data 'btn_trip_passagensV'
ShellBot.InlineKeyboardButton --button 'botao2' --line 4 --text 'Listar Passagens ❌' --callback_data 'btn_trip_passagensX'
ShellBot.InlineKeyboardButton --button 'botao2' --line 5 --text 'Listar Trem ✅' --callback_data 'btn_trip_tremV'
ShellBot.InlineKeyboardButton --button 'botao2' --line 5 --text 'Listar Trem ❌' --callback_data 'btn_trip_tremX'
ShellBot.InlineKeyboardButton --button 'botao2' --line 6 --text 'Listar Compras ✅' --callback_data 'btn_trip_comprarV'
ShellBot.InlineKeyboardButton --button 'botao2' --line 6 --text 'Listar Compras ❌' --callback_data 'btn_trip_comprarX'
ShellBot.InlineKeyboardButton --button 'botao2' --line 7 --text 'Listar Outros ✅' --callback_data 'btn_trip_outrosV'
ShellBot.InlineKeyboardButton --button 'botao2' --line 7 --text 'Listar Outros ❌' --callback_data 'btn_trip_outrosX'
#ShellBot.regHandleFunction --function list.all --callback_data btn_trip_list
#ShellBot.regHandleFunction --function list.done --callback_data btn_trip_done
#ShellBot.regHandleFunction --function list.pending --callback_data btn_trip_pending
#ShellBot.regHandleFunction --function list.search --callback_data btn_trip_passagensV
#ShellBot.regHandleFunction --function list.search --callback_data btn_trip_passagensX
#ShellBot.regHandleFunction --function list.search --callback_data btn_trip_tremV
#ShellBot.regHandleFunction --function list.search --callback_data btn_trip_tremX
#ShellBot.regHandleFunction --function list.search --callback_data btn_trip_comprarV
#ShellBot.regHandleFunction --function list.search --callback_data btn_trip_comprarX
#ShellBot.regHandleFunction --function list.search --callback_data btn_trip_outrosV
#ShellBot.regHandleFunction --function list.search --callback_data btn_trip_outrosX
keyboard_trip_checklist="$(ShellBot.InlineKeyboardMarkup -b 'botao2')"
#######################################################################################

while :
do
	
	ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 30
	
	for id in $(ShellBot.ListUpdates)
	do
	(
		ShellBot.watchHandle --callback_data ${callback_query_data[$id]}
		
		if [[ ${message_entities_type[$id]} == bot_command ]]; then
			if [[ "$(echo ${message_text[$id]%%@*} | grep "^\/start" )" ]]; then
				start.sendGreetings
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
				*) ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text '*Marcar Ponto*' \
									--reply_markup "$ch_keyboard1" \
									--parse_mode markdown
					;;

			esac
		fi
	) & 
	done
done
#FIM
