#!/bin/sh

FILE='input2.txt'

read -r LINE <"$FILE"	# random ints, comma separated
oldIFS="$IFS"; IFS=, set -- $LINE
LIST=; for VALUE in $*; do LIST="$LIST $VALUE"; done
IFS="$oldIFS"

DAYS=0

while [ $DAYS -le 256 ]; do {
	DAYS=$(( DAYS + 1 ))

	NEW_LIST=
	for FISH in $LIST; do {
		case "$FISH" in
			0) NEW_LIST="$NEW_LIST 6 8" ;;
			*) NEW_LIST="$NEW_LIST $(( FISH - 1 ))" ;;
		esac
	} done

	LIST="$NEW_LIST"
	echo "DAYS: $DAYS ALL: $(( (${#LIST} / 2) ))"
} done
