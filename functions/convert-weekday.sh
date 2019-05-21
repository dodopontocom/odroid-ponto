#!/bin/bash
#
#e.g. : convert.weekdayPtbr $(date +%u)
convert.weekdayPtbr() {

  local day
  day=$1
  case ${day} in
      '1' ) echo "Segunda feira"
        ;;
      '2' ) echo "Terça feira"
        ;;
      '3' ) echo "Quarta feira"
        ;;
      '4' ) echo "Quinta feira"
        ;;
      '5' ) echo "Sexta feira"
        ;;
      '6' ) echo "Sábado"
        ;;
      '7' ) echo "Domingo"
        ;;
      * ) echo "Error"
        ;;
  esac

}
