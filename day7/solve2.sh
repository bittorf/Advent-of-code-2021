#!/bin/sh

FILE='input.txt'

read -r LINE <"$FILE"
oldIFS="$IFS"; IFS=, set -- $LINE
LIST=; for VALUE in $*; do LIST="$LIST $VALUE"; done
IFS="$oldIFS"

MIN=999
MAX=0
for VALUE in $LIST; do {
	test $VALUE -lt $MIN && MIN=$VALUE
	test $VALUE -gt $MAX && MAX=$VALUE
} done

FUEL_MIN=99999999
I=$MIN
while [ $I -le $MAX ]; do {
	FUEL=0
	for VALUE in $LIST; do {
		DIFF=$(( VALUE - I ))
		case "$DIFF" in -*) DIFF=$(( DIFF * -1 )) ;; esac

		J=1
		while [ $DIFF -gt 0 ]; do {
			FUEL=$(( FUEL + J ))
			DIFF=$(( DIFF - 1 ))
			J=$(( J + 1 ))
		} done
	} done

	echo $FUEL
	test $FUEL -lt $FUEL_MIN && FUEL_MIN=$FUEL && DURING=$I
	I=$(( I + 1 ))
} done

echo "during: $DURING = $FUEL_MIN"
