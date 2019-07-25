#!/bin/bash

IDS=($(ls -1 ${BASEDIR}/logs))
IDS=(11504381 135810713 184152399 21025096 232486786 362003074 449542698 736298753 815573690 831690845 882808182 989422706)
TOKEN=$1

for i in ${IDS[@]}; do
  message="Olá , tudo bem?\n"
  message+="Passando por aqui para perguntar se você lembrou de bater o ponto hoje!? 🤔\n"
  message+="/start"
    curl -X POST \
    -d chat_id=$i \
    -d text="$(echo -e ${message})" \
    https://api.telegram.org/bot${TOKEN}/sendMessage
done
