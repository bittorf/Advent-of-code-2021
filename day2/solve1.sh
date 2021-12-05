#!/bin/sh

FILE='input.txt'

HPOS=0
DEPTH=0

while read -r LINE; do {
	for VALUE in $LINE; do :; done

	case "$LINE" in
		forward*) HPOS=$(( HPOS + VALUE )) ;;
		   down*) DEPTH=$(( DEPTH + VALUE )) ;;
		     up*) DEPTH=$(( DEPTH - VALUE )) ;;
	esac
} done <"$FILE"

echo $(( HPOS * DEPTH ))
