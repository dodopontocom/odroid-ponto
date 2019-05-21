#!/bin/bash
#
source ${BASEDIR}/functions/iscreated.sh
source ${BASEDIR}/functions/random.sh
#1 hour -> 1x60x60 seconds
#8 hours > 8x60x60 seconds
eight_hours_in_seconds=28800
four_hours_in_seconds=$(echo $((eight_hours_in_seconds/2)))
eight_hours_in_seconds_consider_lunch=32400

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
		message="Entrada de hoje foi registrada às ${verify}"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ ! -z $verify_saida ]] && [[ -z $verify_entrada2 ]]; then
		message="Registrando horário da Segunda entrada -> "
		work_day_start_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

		echo "$day,$weekday,$work_day_start_sec,$reply_user,$flag2" >> $log/$file
	elif [[ ! -z $verify_entrada2 ]]; then
		message=" Segunda entrada de hoje foi registrada às ${verify_entrada2}"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		message="Registrando horário de entrada -> "
		work_day_start_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		estimate="Hora aproximada para saída (considerando 8 horas de trabalho com 1 hora de almoço) -> "
		estimate+=$(date --date="now + $eight_hours_in_seconds_consider_lunch seconds" +'%H:%M')
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown
		
		echo "$day,$weekday,$work_day_start_sec,$reply_user,$flag" >> $log/$file

		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${estimate})" --parse_mode markdown

	fi
}
baterponto.almoco() {
	local go_lunch_sec work_day_start_sec reply_user return_lunch return_reply log file message flag weekday day verify one_hour_from_now
	weekday=$(date +%a)
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=almoco
	log=${BASEDIR}/logs/${message_from_id}
	
	if [[ ! -f $log/$file ]]; then
		message="Entrada ainda não registrada. Registre a Entrada primeiro"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]]; then
			message="Saída para almoco foi registrada às ${verify}"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		else
			message="Registrando horário de almoço -> "
			go_lunch_sec="$(date --date="now" +%s)"
			reply_user=$(date --date="now" +'%H:%M')
			one_hour_from_now=$(date --date="now + 3600 seconds" +'%s')
			return_lunch=$(echo $(((one_hour_from_now)-go_lunch_sec)))

			return_reply="Considerando 1 hora de almoço, você pode retornar às -> "
			return_reply+=$(echo $(date --date="00:00 today + $return_lunch seconds" +'%H:%M'))

			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${return_reply})" --parse_mode markdown

			echo "$day,$weekday,$go_lunch_sec,$reply_user,$flag" >> $log/$file
		fi
	fi
}
baterponto.volta() {
	local back_lunch_sec work_day_start_sec reply_user estimate log file message flag weekday day verify go_lunch_sec time_in_lunch first_time_sum estimate_after_lunch
	weekday=$(date +%a)
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=volta
	log=${BASEDIR}/logs/${message_from_id}
	
	if [[ ! -f $log/$file ]]; then
		message="Entrada ainda não registrada.\n"
		message+="Registre a Entrada primeiro."
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]]; then
			message="Volta do almoço foi registrada às ${verify}"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		else
			message="Registrando a volta do almoço -> "
			back_lunch_sec="$(date --date="now" +%s)"
			reply_user=$(date --date="now" +'%H:%M')
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

			echo "$day,$weekday,$back_lunch_sec,$reply_user,$flag" >> $log/$file
			go_lunch_sec=$(cat $log/$file | grep $day | grep ,almoco | cut -d',' -f3)
			time_in_lunch=$(echo $(((back_lunch_sec-go_lunch_sec))))
			work_day_start_sec=$(cat $log/$file | grep $day | grep ,entrada | cut -d',' -f3)
			first_time_sum=$(echo $(((go_lunch_sec-work_day_start_sec))))
			
			estimate_after_lunch="Horário atualizado estimado de saída -> "
			estimate_after_lunch+=$(date --date="now + $(echo $(((eight_hours_in_seconds+time_in_lunch)))) seconds" +'%H:%M')

			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${estimate_after_lunch})" --parse_mode markdown

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
		message="Entrada ainda não registrada.\n"
		message+="Registre a Entrada primeiro."
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ ! -z $verify_segunda_entrada ]] && [[ -z $verify_segunda_saida ]]; then
		message="Registrando a Segunda saída -> "
		leave_day_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

		echo "$day,$weekday,$leave_day_sec,$reply_user,$flag2" >> $log/$file
	elif [[ ! -z $verify_segunda_saida ]]; then
		message="Segunda saída foi registrada às ${verify_segunda_saida}"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]]; then
			message="Saída foi registrada às ${verify}"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		else
			message="Registrando a saída -> "
			leave_day_sec="$(date --date="now" +%s)"
			reply_user=$(date --date="now" +'%H:%M')
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

			echo "$day,$weekday,$leave_day_sec,$reply_user,$flag" >> $log/$file
		fi
	fi
	send_summary=$(cat $log/$file | grep $day | grep ,$flag)
	send_summary2=$(cat $log/$file | grep $day | grep ,$flag2)
	if [[ ! -z $send_summary ]] || [[ ! -z $send_summary2 ]]; then
		baterponto.calc $log/$file
		message="$(cat $log/$file)"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	fi
}

baterponto.calc() {
	local message file fsize time_spent_at_work go_lunch_sec work_day_start_sec back_lunch_sec leave_day_sec first_time_sum day_closure
	file=$1
	fsize=$(cat $file | wc -l)
	case ${fsize} in
		'4' ) 	go_lunch_sec=$(cat $file | grep almoco | cut -d',' -f3)
				work_day_start_sec=$(cat $file | grep ,entrada | cut -d',' -f3)
				back_lunch_sec=$(cat $file | grep ,volta | cut -d',' -f3)
				leave_day_sec=$(cat $file | grep ,saida | cut -d',' -f3)

				first_time_sum=$(echo $(((go_lunch_sec-work_day_start_sec))))
				day_closure=$(echo $(((leave_day_sec-back_lunch_sec)+first_time_sum)))
				time_spent_at_work=$(echo $(date -d "00:00 today + $day_closure seconds" +'%H:%M'))

				message="Tempo gasto hoje no trabalho: "
				message+=$time_spent_at_work
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
		'6' )	go_lunch_sec=$(cat $file | grep ,almoco | cut -d',' -f3)
				work_day_start_sec=$(cat $file | grep ,entrada | cut -d',' -f3)
				back_lunch_sec=$(cat $file | grep ,volta | cut -d',' -f3)
				leave_day_sec=$(cat $file | grep ,saida | cut -d',' -f3)

				first_time_sum=$(echo $(((go_lunch_sec-work_day_start_sec))))
				echo $first_time_sum
				day_closure1=$(echo $(((leave_day_sec-back_lunch_sec)+first_time_sum)))
				second_entry=$(cat $file | grep ,2entrada | cut -d',' -f3)
				echo $second_entry
				second_saida=$(cat $file | grep ,2saida | cut -d',' -f3)
				echo $second_saida
				second_time_sum=$(echo $(((second_saida-second_entry))))
				echo $second_time_sum

				day_closure2=$(echo $(((second_saida-second_entry)+second_time_sum)))
				day_closure3=$(echo $((day_closure1+day_closure2)))
				echo $day_closure3
				time_spent_at_work=$(echo $(date -d "00:00 today + $day_closure3 seconds" +'%H:%M'))
				echo $time_spent_at_work

				message="Tempo gasto hoje no trabalho: "
				message+=$time_spent_at_work
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
		* )		message="Error: inesperado"
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
	esac
}

baterponto.lunchAlert() {
	#return alert to the user when 1 hour of lunch is expiring
	local complete_one_hour_in_sec file day fift_min_in_sec five_min_in_sec dt_now user_id message check_volta check_almoco
	five_min_in_sec=300
	fift_min_in_sec=900
	file=$1
	day=$(date +%Y%m%d)
	user_id=$(echo $file | rev | cut -d'/' -f2 | rev)
	complete_one_hour_in_sec=$(echo $(($(cat $file | grep $day | grep ,almoco | cut -d',' -f3)+3600)))
	check_volta=$(cat $file | grep $day | grep ,volta)

	dt_now=$(date --date="now" +'%s')
	if [[ $((dt_now-complete_one_hour_in_sec)) -lt $fift_min_in_sec ]] && [[ -z $check_volta ]]; then
		message="Alerta, faltam 15 minutos para completar 1 hora de almoço..."
		ShellBot.sendMessage --chat_id ${user_id} --text "$(echo -e ${message})" --parse_mode markdown
		touch ${file}.alert15
		 
	fi
	if [[ $((dt_now-complete_one_hour_in_sec)) -lt $five_min_in_sec ]] && [[ -z $check_volta ]]; then
		message="Alerta, faltam apenas 5 minutos para completar 1 hora de almoço..."
		ShellBot.sendMessage --chat_id ${user_id} --text "$(echo -e ${message})" --parse_mode markdown
		touch ${file}.alert5
	fi

}