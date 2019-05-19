#!/bin/bash
#

source ${BASEDIR}/functions/iscreated.sh
source ${BASEDIR}/functions/random.sh

#1 hour -> 1x60x60 seconds
#8 hours > 8x60x60 seconds
eight_hours_in_seconds=28800
four_hours_in_seconds=$(echo $((eight_hours_in_seconds/2)))

baterponto.entrada() {
	local work_day_start_sec reply_user estimate log file message flag flag2 weekday day verify verify_saida
	weekday=$(date +%a)
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=entrada
	flag2=2entrada
	log=${BASEDIR}/logs/${message_from_id}
	iscreated.helper -d $log
	iscreated.helper -f $log/$file
	verify=$(cat $log/$file | grep $day | grep ,$flag | cut -d',' -f4)
	verify_saida=$(cat $log/$file | grep $day | grep ,saida | cut -d',' -f4)
	verify_entrada2=$(cat $log/$file | grep $day | grep ,$flag2 | cut -d',' -f4)

	if [[ ! -z $verify ]] && [[ -z $verify_saida ]]; then
		message="Entrada de hoje foi registrada as ${verify}"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ ! -z $verify_saida ]] && [[ -z $verify_entrada2 ]]; then
		message="Registrando horário da Segunda entrada -> "
		work_day_start_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

		echo "$day,$weekday,$work_day_start_sec,$reply_user,$flag2" >> $log/$file
	elif [[ ! -z $verify_entrada2 ]]; then
		message=" Segunda entrada de hoje foi registrada as ${verify_entrada2}"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		message="Registrando horário de entrada -> "
		work_day_start_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

		echo "$day,$weekday,$work_day_start_sec,$reply_user,$flag" >> $log/$file
	fi
}
baterponto.almoco() {
	local go_lunch_sec work_day_start_sec reply_user estimate log file message flag weekday day verify
	weekday=$(date +%a)
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=almoco
	log=${BASEDIR}/logs/${message_from_id}
	
	if [[ ! -f $log/$file ]]; then
		message="Entrada ainda nao registrada. Registre a Entrada primeiro"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]]; then
			message="Saida para almoco foi registrada as ${verify}"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		else
			message="Registrando horário de almoco -> "
			go_lunch_sec="$(date --date="now" +%s)"
			reply_user=$(date --date="now" +'%H:%M')
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

			echo "$day,$weekday,$go_lunch_sec,$reply_user,$flag" >> $log/$file
		fi
	fi
}
baterponto.volta() {
	local back_lunch_sec work_day_start_sec reply_user estimate log file message flag weekday day verify
	weekday=$(date +%a)
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=volta
	log=${BASEDIR}/logs/${message_from_id}
	
	if [[ ! -f $log/$file ]]; then
		message="Entrada ainda nao registrada. Registre a Entrada primeiro"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]]; then
			message="Volta do almoco foi registrada as ${verify}"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		else
			message="Registrando a volta do almoco -> "
			back_lunch_sec="$(date --date="now" +%s)"
			reply_user=$(date --date="now" +'%H:%M')
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

			echo "$day,$weekday,$back_lunch_sec,$reply_user,$flag" >> $log/$file
		fi
	fi
}
baterponto.saida() {
	local leave_day_sec work_day_start_sec reply_user estimate log file message flag flag2 weekday day verify verify_segunda_entrada verify_segunda_saida send_summary 
	weekday=$(date +%a)
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=saida
	flag2=2saida
	log=${BASEDIR}/logs/${message_from_id}
	verify_segunda_entrada=$(cat $log/$file | grep $day | grep ,2entrada | cut -d',' -f4)
	verify_segunda_saida=$(cat $log/$file | grep $day | grep ,2saida | cut -d',' -f4)

	if [[ ! -f $log/$file ]] && [[ -z $verify_segunda_entrada ]]; then
		message="Entrada ainda nao registrada. Registre a Entrada primeiro"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ ! -z $verify_segunda_entrada ]] && [[ -z $verify_segunda_saida ]]; then
		message="Registrando a Segunda saida -> "
		leave_day_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

		echo "$day,$weekday,$leave_day_sec,$reply_user,$flag2" >> $log/$file
	elif [[ ! -z $verify_segunda_saida ]]; then
		message="Segunda saida foi registrada as ${verify_segunda_saida}"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]]; then
			message="Saida foi registrada as ${verify}"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		else
			message="Registrando a saida -> "
			leave_day_sec="$(date --date="now" +%s)"
			reply_user=$(date --date="now" +'%H:%M')
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

			echo "$day,$weekday,$leave_day_sec,$reply_user,$flag" >> $log/$file
		fi
	fi
	send_summary=$(cat $log/$file | grep $day | grep ,$flag)
	send_summary2=$(cat $log/$file | grep $day | grep ,$flag2)
	if [[ ! -z $send_summary ]] || [[ ! -z $send_summary2 ]]; then
		#call sum function
		ponto.calc $log/$file
		message="$(cat $log/$file)"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	fi
}

ponto.calc() {
	local file fsize time_spent_at_work
	file=$1
	fsize=$(cat $file | wc -l)
	case ${fsize} in
		'4' ) 	go_lunch_sec=$(cat $file | grep almoco | cut -d',' -f3)
				work_day_start_sec=$(cat $file | grep entrada | cut -d',' -f3)
				back_lunch_sec=$(cat $file | grep volta | cut -d',' -f3)
				leave_day_sec=$(cat $file | grep saida | cut -d',' -f3)

				first_time_sum=$(echo $(((go_lunch_sec-work_day_start_sec))))
				day_closure=$(echo $(((leave_day_sec-back_lunch_sec)+first_time_sum)))
				time_spent_at_work=$(echo $(date -d "00:00 today + $day_closure seconds" +'%H:%M'))

				message="Tempo gasto hoje no trabalho: "
				message+=$time_spent_at_work
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
		'6' )	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
		* )		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
	esac
	eight_hours_in_seconds_consider_lunch=32400
	estimate_leave_hour=$(date -d "now + \
	  $eight_hours_in_seconds_consider_lunch seconds" +'%H:%M')
	work_day_start_sec="$(date --date="now" +%s)"
	#go_lunch_sec="$(date --date="now + 14400 seconds" +%s)"
	go_lunch_sec="$(date --date="now" +%s)"
	#back_lunch_sec="$(date --date="now + 18000 seconds" +%s)"
	back_lunch_sec="$(date --date="now" +%s)"
	time_in_lunch=$(echo $(((back_lunch_sec-go_lunch_sec))))
	first_time_sum=$(echo $(((go_lunch_sec-work_day_start_sec))))
	estimate_after_lunch=$(date -d "now + \
	  $(echo $(((eight_hours_in_seconds+time_in_lunch)))) seconds" +'%H:%M')
	#leave_day_sec="$(date --date="now + 61200 seconds" +%s)"
	leave_day_sec="$(date --date="now" +%s)"
	day_closure=$(echo $(((leave_day_sec-back_lunch_sec)-first_time_sum)))
	time_spent_at_work=$(echo $(date -d "00:00 today + $day_closure seconds" +'%H:%M'))

	echo $estimate_leave_hour
	echo $estimate_after_lunch
	echo $day_closure
	echo $time_spent_at_work
}

baterponto.apply() {
  local message opt array random_file_name
  opt=$1
  array=(${opt})
  array[0]="/baterponto"
  opt=${array[@]:1}
  case ${opt} in
		'start')
            message="Bom trabalho"
        		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
		'lunch')
        		message="Bom almoço"
        		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
		'back')
        		message="Bom trabalho"
        		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
		'bye')
        		message="Bom retorno"
        		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
		'')
            		message="opa"
        		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
        
      			;;
  	esac
}
