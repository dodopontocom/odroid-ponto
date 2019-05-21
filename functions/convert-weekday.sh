#!/bin/bash
#
#e.g. : convert.weekdayPtbr $(date +%u)
convert.weekdayPtbr() {

  local day
  day=$1
  case ${day} in
      '1' ) echo "Segunda_feira"
        ;;
      '2' ) echo "Terça_feira"
        ;;
      '3' ) echo "Quarta_feira"
        ;;
      '4' ) echo "Quinta_feira"
        ;;
      '5' ) echo "Sexta_feira"
        ;;
      '6' ) echo "Sábado"
        ;;
      '7' ) echo "Domingo"
        ;;
      * ) echo "Error"
        ;;
  esac

}
