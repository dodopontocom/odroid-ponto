#!/bin/bash
#

iscreated.helper() {
	local type var
	type=$1
	var=$2
	
	case ${type} in
			'-d')
				if [[ ! -d $var ]]; then
					mkdir -p $var
				fi
			;;
			'-f')
				var_split=( $(echo ${var} | tr '.' ' ') ) 
				if [[ -z ${var_split[1]} ]]; then
					var=$2.txt
				fi
				if [[ ! -f $var ]]; then
					touch $var
				fi
			;;
	esac
}
