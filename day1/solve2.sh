#!/bin/sh

FILE='input.txt'
WISH=1	# startline wish

window_sum_at_line()
{
	L=0	# linenumber real
	P=0	# count of values = position
	SUM=0
	PARSE=

	while read -r VALUE; do {
		L=$(( L + 1 ))
		test $L -eq $WISH && PARSE=true

		case "$PARSE" in
			true)
				SUM=$(( SUM + VALUE ))
				P=$(( P + 1 ))
				test $P -eq 3 && return 0
			;;
		esac
	} done <"$FILE"

	false
}

SUM_OLD=
I=0
while window_sum_at_line $WISH; do {
	test $SUM -gt ${SUM_OLD:-$SUM} && I=$(( I + 1 ))
	SUM_OLD=$SUM
	WISH=$(( WISH + 1 ))
} done

echo $I
