#!/bin/sh

FILE='input.txt'

DEPTH=0
HPOS=0
AIM=0

while read -r LINE; do {
	for VALUE in $LINE; do :; done

	case "$LINE" in
		forward*)
			HPOS=$(( HPOS + VALUE ))
			DEPTH=$(( DEPTH + ( AIM * VALUE ) ))
		;;
		   down*) AIM=$(( AIM + VALUE )) ;;
		     up*) AIM=$(( AIM - VALUE )) ;;
	esac
} done <"$FILE"

echo $(( HPOS * DEPTH ))
