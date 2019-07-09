#!/bin/bash
#

source ${BASEDIR}/functions/iscreated.sh
source ${BASEDIR}/functions/random.sh
source ${BASEDIR}/functions/convert-weekday.sh
source ${BASEDIR}/functions/date_arithmetic.sh

#1 hour -> 1x60x60 seconds
#8 hours > 8x60x60 seconds
eight_hours_in_seconds=28800
four_hours_in_seconds=$(echo $((eight_hours_in_seconds/2)))
eight_hours_in_seconds_consider_lunch=32400

baterponto.entrada() {
	local work_day_start_sec reply_user estimate log file message flag flag2 weekday day verify verify_saida
	weekday=$(convert.weekdayPtbr $(date +%u))
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=entrada
	flag2=2entrada
	log=${BASEDIR}/logs/${message_from_id}
	iscreated.helper -d $log
	iscreated.helper -f $log/$file
	verify=$(cat $log/$file | grep $day | grep ,$flag | cut -d',' -f4)
	verify_saida=$(cat $log/$file | grep $day | grep ,saida | cut -d',' -f4)
	verify_saida2=$(cat $log/$file | grep $day | grep ,2saida | cut -d',' -f4)
	verify_entrada2=$(cat $log/$file | grep $day | grep ,$flag2 | cut -d',' -f4)

	if [[ ! -z $verify ]] && [[ -z $verify_saida ]]; then
		message="Entrada de hoje foi registrada às *${verify}*"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ ! -z $verify_saida ]] && [[ -z $verify_entrada2 ]]; then
		message="Registrando horário da Segunda entrada -> "
		work_day_start_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown

		echo "$day,$weekday,$work_day_start_sec,$reply_user,$flag2" >> $log/$file
	elif [[ ! -z $verify_entrada2 ]]; then
		message="Segunda entrada de hoje foi registrada às *${verify_entrada2}*"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		if [[ ! -z $verify_saida2 ]];then
			message="Por enquanto eu aceito no máximo 2 entradas, ou seja, uma entrada extra, e uma saída extra!"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		fi
	else
		message="Registrando horário de entrada -> "
		work_day_start_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		estimate="Hora aproximada para saída (considerando 8 horas de trabalho com 1 hora de almoço) -> "
		estimate+="*$(date --date="now + $eight_hours_in_seconds_consider_lunch seconds" +'%H:%M')*"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown
		
		echo "$day,$weekday,$work_day_start_sec,$reply_user,$flag" >> $log/$file

		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${estimate})" --parse_mode markdown

	fi
}
baterponto.almoco() {
	local check_saida go_lunch_sec work_day_start_sec reply_user return_lunch return_reply log file message flag weekday day verify one_hour_from_now
	weekday=$(convert.weekdayPtbr $(date +%u))
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=almoco
	log=${BASEDIR}/logs/${message_from_id}
	check_saida=$(cat $log/$file | grep $day | grep ,saida)
	check_entrada2=$(cat $log/$file | grep $day | grep ,2entrada)
	check_saida2=$(cat $log/$file | grep $day | grep ,2saida)
	
	if [[ ! -f $log/$file ]]; then
		message="Entrada ainda não registrada. Registre a Entrada primeiro"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ ! -z $check_saida ]] && [[ -z $check_entrada2 ]]; then
	 	message="Ops, saída já foi registrada às -> *$(echo $check_saida | cut -d',' -f4)*\n"
	 	message+="Você deve registrar a entrada novamente"
	 	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]]; then
			message="Saída para almoco foi registrada às *${verify}*"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		elif [[ ! -z $check_saida2 ]]; then
			message="Saída 2 já foi registrada às *$(echo ${check_saida2} | cut -d',' -f4)*"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		else
			message="Registrando horário de almoço -> "
			go_lunch_sec="$(date --date="now" +%s)"
			reply_user=$(date --date="now" +'%H:%M')
			
			return_reply="Considerando 1 hora de almoço, você pode retornar às -> "
			return_reply+="*$(echo $(date --date="now + 3600 seconds" +'%H:%M'))*"

			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} ${reply_user})" --parse_mode markdown
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${return_reply})" --parse_mode markdown

			echo "$day,$weekday,$go_lunch_sec,$reply_user,$flag" >> $log/$file
		fi
	fi
}
baterponto.volta() {
	local check_almoco back_lunch_sec work_day_start_sec reply_user estimate log file message flag weekday day verify go_lunch_sec time_in_lunch first_time_sum estimate_after_lunch
	weekday=$(convert.weekdayPtbr $(date +%u))
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=volta
	log=${BASEDIR}/logs/${message_from_id}
	check_almoco=$(cat $log/$file | grep $day | grep ,almoco)
	
	if [[ ! -f $log/$file ]]; then
		message="Entrada ainda não registrada.\n"
		message+="Registre a Entrada primeiro."
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ -z $check_almoco ]]; then
		message="Ops, você ainda não registrou a saída para o almoço.\n"
	 	message+="Registre a saída para almoço."
	 	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]]; then
			message="Volta do almoço foi registrada às *${verify}*"
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
			estimate_after_lunch+=$(date --date="now + $(echo $((eight_hours_in_seconds - (first_time_sum + time_in_lunch)))) seconds" +'%H:%M')

			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${estimate_after_lunch})" --parse_mode markdown

		fi
	fi
}
baterponto.saida() {
	local leave_day_sec work_day_start_sec reply_user estimate log file message flag flag2 weekday day verify verify_segunda_entrada verify_segunda_saida send_summary 
	weekday=$(convert.weekdayPtbr $(date +%u))
	day=$(date +%Y%m%d)
	file=${day}.csv
	flag=saida
	flag2=2saida
	log=${BASEDIR}/logs/${message_from_id}
	verify_segunda_entrada=$(cat $log/$file | grep $day | grep ,2entrada | cut -d',' -f4)
	verify_segunda_saida=$(cat $log/$file | grep $day | grep ,2saida | cut -d',' -f4)
	verify_volta=$(cat $log/$file | grep $day | grep ,volta | cut -d',' -f4)
	verify_almoco=$(cat $log/$file | grep $day | grep ,almoco | cut -d',' -f4)

	if [[ ! -f $log/$file ]] && [[ -z $verify_segunda_entrada ]]; then
		message="Entrada ainda não registrada.\n"
		message+="Registre a Entrada primeiro."
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ ! -z $verify_segunda_entrada ]] && [[ -z $verify_segunda_saida ]]; then
		message="Registrando a Segunda saída -> "
		leave_day_sec="$(date --date="now" +%s)"
		reply_user=$(date --date="now" +'%H:%M')
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} *${reply_user}*)" --parse_mode markdown

		echo "$day,$weekday,$leave_day_sec,$reply_user,$flag2" >> $log/$file
	elif [[ ! -z $verify_segunda_saida ]]; then
		message="Segunda saída foi registrada às *${verify_segunda_saida}*"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	elif [[ -z $verify_volta ]] && [[ ! -z $verify_almoco ]]; then
		message="Aqui consta que você ainda não retornou do almoço\n"
		message+="*Registre a volta do almoço primeiro*"
		ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	else
		verify=$(cat $log/$file | grep $day | grep $flag | cut -d',' -f4)
		if [[ ! -z $verify ]] && [[ -z $verify_segunda_entrada ]]; then
			message="Saída foi registrada às *${verify}*"
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		else
			message="Registrando a saída -> "
			leave_day_sec="$(date --date="now" +%s)"
			reply_user=$(date --date="now" +'%H:%M')
			ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message} *${reply_user}*)" --parse_mode markdown

			echo "$day,$weekday,$leave_day_sec,$reply_user,$flag" >> $log/$file
		fi
	fi

	send_summary=$(cat $log/$file | grep $day | grep ,$flag)
	send_summary2=$(cat $log/$file | grep $day | grep ,$flag2)
	
	if [[ ! -z $send_summary ]] || [[ ! -z $send_summary2 ]]; then
		baterponto.calc "$log/$file"
		#message="Resumo do dia\n"
		#message+=$(cat $log/$file | awk -F',' '{print $5 " às " "*"$4"*""\\n"}')
		#ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
		
	fi
}

baterponto.calc() {
	local message file fsize time_spent_at_work go_lunch_sec work_day_start_sec back_lunch_sec leave_day_sec first_time_sum day_closure
	file=$1
	fsize=$(cat $file | wc -l)
	case ${fsize} in
		'2' )	work_day_start_sec=$(cat $file | grep ,entrada | cut -d',' -f3)
				leave_day_sec=$(cat $file | grep ,saida | cut -d',' -f3)
				first_time_sum=$(echo $(((leave_day_sec-work_day_start_sec))))
				time_spent_at_work=$(echo $(date -d "00:00 today + $first_time_sum seconds" +'%H:%M'))
				
				message="Tempo gasto hoje no trabalho -> "
				message+="*$time_spent_at_work*"
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
				baterponto.daySendResumo "$file" ",,,,$time_spent_at_work"
			;;
		'4' ) 	work_day_start_sec=$(cat $file | grep ,entrada | cut -d',' -f3)
				go_lunch_sec=$(cat $file | grep ,almoco | cut -d',' -f3)
				back_lunch_sec=$(cat $file | grep ,volta | cut -d',' -f3)
				leave_day_sec=$(cat $file | grep ,saida | cut -d',' -f3)

				first_time_sum=$(echo $(((go_lunch_sec-work_day_start_sec))))
				day_closure=$(echo $(((leave_day_sec-back_lunch_sec)+first_time_sum)))
				time_spent_at_work=$(echo $(date -d "00:00 today + $day_closure seconds" +'%H:%M'))

				message="Tempo gasto hoje no trabalho -> "
				message+="*$time_spent_at_work*"
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
				baterponto.daySendResumo "$file" ",,$time_spent_at_work"
			;;
		'6' )	go_lunch_sec=$(cat $file | grep ,almoco | cut -d',' -f3)
				work_day_start_sec=$(cat $file | grep ,entrada | cut -d',' -f3)
				back_lunch_sec=$(cat $file | grep ,volta | cut -d',' -f3)
				leave_day_sec=$(cat $file | grep ,saida | cut -d',' -f3)

				first_time_sum=$(echo $(((go_lunch_sec-work_day_start_sec))))
				day_closure1=$(echo $(((leave_day_sec-back_lunch_sec)+first_time_sum)))
				second_entry=$(cat $file | grep ,2entrada | cut -d',' -f3)
				second_saida=$(cat $file | grep ,2saida | cut -d',' -f3)
				second_time_sum=$(echo $(((second_saida-second_entry))))

				day_closure2=$(echo $(((second_saida-second_entry)+second_time_sum)))
				day_closure3=$(echo $((day_closure1+day_closure2)))
				time_spent_at_work=$(echo $(date -d "00:00 today + $day_closure3 seconds" +'%H:%M'))
				
				message="Tempo gasto hoje no trabalho: "
				message+="*$time_spent_at_work*"
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
				baterponto.daySendResumo "$file" "$time_spent_at_work"
			;;
		* )		message="*Error: Inesperado!*\n"
				message+="Não foi possível calcular o tempo gasto hoje no trabalho."
				ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
			;;
	esac
}

#echo $(((1558653250+3600)-dt_now))
#echo $((($(cat 20190523.csv | grep ,almoco | cut -d',' -f3)+3600)-1558630000))
baterponto.lunchAlert() {
	#return alert to the user when 1 hour of lunch is expiring
	local complete_one_hour_in_sec file day fift_min_in_sec five_min_in_sec dt_now user_id message check_volta check_almoco
	five_min_in_sec=300
	fift_min_in_sec=900
	file=$1
	day=$(date +%Y%m%d)
	user_id=$(echo $file | rev | cut -d'/' -f2 | rev)
	complete_one_hour_in_sec=$(cat $file | grep $day | grep ,almoco | cut -d',' -f3)
	check_volta=$(cat $file | grep $day | grep ,volta)

	dt_now=$(date --date="now" +'%s')
	if [[ ! -f ${file}.alert15 ]] && [[ ! -z $complete_one_hour_in_sec ]] && [[ $((($(cat $file | grep $day | grep ,almoco | cut -d',' -f3)+3600)-dt_now)) -lt $fift_min_in_sec ]] && [[ -z $check_volta ]]; then
		message="Alerta, faltam *15* minutos para completar 1 hora de almoço..."
		ShellBot.sendMessage --chat_id ${user_id} --text "$(echo -e ${message})" --parse_mode markdown
		touch ${file}.alert15
		 
	fi
	if [[ ! -f ${file}.alert5 ]] && [[ ! -z $complete_one_hour_in_sec ]] && [[ $((($(cat $file | grep $day | grep ,almoco | cut -d',' -f3)+3600)-dt_now)) -lt $five_min_in_sec ]] && [[ -z $check_volta ]]; then
		message="Alerta, faltam apenas *5* minutos para completar 1 hora de almoço..."
		ShellBot.sendMessage --chat_id ${user_id} --text "$(echo -e ${message})" --parse_mode markdown
		touch ${file}.alert5
	fi

}
#below function: in case user does not make properly day closure it will assume 8 hours for the day
baterponto.fixDay() {
	local log file message weekday day verify fixday
	weekday=$(convert.weekdayPtbr $(date +%u))
	day=$(date +%Y%m%d)
	file=${day}.csv
	log=${BASEDIR}/logs/${message_from_id}
	verify=$(tail -1 $log/$file | grep $day | cut -d',' -f4)
	if [[ $verify == "entrada" ]] || [[ $verify == "volta" ]]; then
		nao bateu certo a saida
		fixday=$(($(tail -1 $log/$file | grep $day | cut -d',' -f3)+eight_hours_in_seconds))
		fixday=
	fi
	if [[ -z $verify ]]; then
		#falta do dia
	fi
}

baterponto.daySendResumo() {
	local header file lines hours dest_file total message day check_almoco check_saida2 line_final
	file=$1
	total=$2
    dest_file=$file.resumo.csv
	day=$(date +%Y%m%d)
	header="DATA, DIA SEMANA, ENTRADA, SAIDA ALMOCO, VOLTA ALMOCO, SAIDA, ENTRADA 2, SAIDA 2, TOTAL"
	echo $header > $dest_file
	
	check_almoco=$(cat $file | grep $day | grep ,almoco)
	check_saida2=$(cat $file | grep $day | grep ,2saida)


	if [[ ! -z $check_almoco ]] && [[ -z $check_saida2 ]]; then
		c=2
		while read line; do
			lines=$(head -1 $file | awk -F',' '{print $1","$2}')
			lines+=$(head -$c $file | awk -F',' '{print ","$4}')
			c=$((c+1))
		done < $file
		
		line_final=$lines,$total
		echo $line_final >> $dest_file

	elif [[ ! -z $check_almoco ]] && [[ ! -z $check_saida2 ]]; then
		c=2
		while read line; do
			lines=$(head -1 $file | awk -F',' '{print $1","$2}')
			lines+=$(head -$c $file | awk -F',' '{print ","$4}')
			c=$((c+1))
		done < $file
		
		total=${total//,/}
		fixed_saida=$(echo $lines | awk -F',' '{print $1","$2","$3","$4","$5","$6","$7","$8}')

		line_final=$fixed_saida,$total
		echo $line_final >> $dest_file

	elif [[ -z $check_almoco ]] && [[ ! -z $check_saida2 ]]; then
		c=2
		while read line; do
			lines=$(head -1 $file | awk -F',' '{print $1","$2}')
			lines+=$(head -$c $file | awk -F',' '{print ","$4}')
			c=$((c+1))
		done < $file

		total=${total//,/}
		fixed_saida=$(echo $lines | awk -F',' '{print $1","$2","$3",,,"$4","$5","$6","$7}')
		
		line_final=$fixed_saida$total
		echo $line_final >> $dest_file

	else	
		c=2
		while read line; do
			lines=$(head -1 $file | awk -F',' '{print $1","$2}')
			lines+=$(head -$c $file | awk -F',' '{print ","$4}')
			c=$((c+1))
		done < $file
		
		total=${total//,/}
		fixed_saida=$(echo $lines | awk -F',' '{print $1","$2","$3",,,"$4}')
		
		line_final=$fixed_saida,,,$total
		echo $line_final >> $dest_file
		
	fi
	message="Estou enviando um resumo das suas horas..."
	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
	
	baterponto.sendResumoAcumulativo "$line_final" "$dest_file"
	
	message="O arquivo \`'.csv'\` é compatível com Ms Excel"
	ShellBot.sendMessage --chat_id ${message_chat_id[$id]} --text "$(echo -e ${message})" --parse_mode markdown
}

baterponto.sendResumoAcumulativo() {
	local day line file yesterday yesterday_file weekday
	weekday=$(convert.weekdayPtbr $(date +%u))
	line=$1
	file=$2
	day=$(date +%Y%m%d)
	
	yesterday=$(today_plus_days -1 | sed 's/-//g')
	yesterday_file=$(echo $file | sed "s/$day"/$yesterday/)

	if [[ $(cat $yesterday_file) ]]; then
		echo "$(tail -1 $yesterday_file)" >> $file
		ShellBot.sendDocument --chat_id ${message_chat_id[$id]} --document @$file
	else
		echo "$yesterday,---,FOLGA,FOLGA,FOLGA,FOLGA,FOLGA,FOLGA,FOLGA" >> $file
		ShellBot.sendDocument --chat_id ${message_chat_id[$id]} --document @$file
	fi
}
