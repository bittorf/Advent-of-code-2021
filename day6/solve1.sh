#!/bin/sh

FILE='input.txt'

read -r LINE <"$FILE"	# random ints, comma separated
oldIFS="$IFS"; IFS=, set -- $LINE
LIST=; for VALUE in $*; do LIST="$LIST $VALUE"; done
IFS="$oldIFS"

DAYS=0

while [ $DAYS -le 80 ]; do {
	DAYS=$(( DAYS + 1 ))

	NEW_LIST=
	for FISH in $LIST; do {
		case "$FISH" in
			0) NEW_LIST="$NEW_LIST 6 8" ;;
			*)
				FISH=$(( FISH - 1 ))
				NEW_LIST="$NEW_LIST $FISH"
			;;
		esac
	} done

	LIST="$NEW_LIST"

	I=0
	for _ in $LIST; do I=$(( I + 1 )); done
	echo "DAYS: $DAYS ALL: $I"
} done
