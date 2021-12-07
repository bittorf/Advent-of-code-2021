#!/bin/sh

FILE='input.txt'
BINGOFILE='bingo.txt'

read -r LINE <"$FILE"	# random ints, comma separated
oldIFS="$IFS"; IFS=, set -- $LINE
LIST=; for VALUE in $*; do LIST="$LIST $VALUE"; done
IFS="$oldIFS"

READMAX=4
WINNER=
BOARD=0
STARTLINE=3

is_bingovalue()
{
	local value="$1"
	local bingoval

	for bingoval in $BINGO; do {
		test "$value" -eq $bingoval && return 0
	} done

	false
}

get_bingoround()
{
	READMAX=$(( READMAX + 1 ))
	export BINGO=

	I=0
	for VALUE in $LIST; do {
		I=$(( I + 1 ))
		BINGO="$BINGO $VALUE"
		test $I -ge $READMAX && break
	} done

	echo "BINGO=$BINGO | READMAX=$READMAX"
}

build_bingofile()
{
	LINECOUNT=0
	FOUND=

	# write horizontal:
	while read -r LINE; do {
		LINECOUNT=$(( LINECOUNT + 1 ))
		test $LINECOUNT -lt $STARTLINE && continue
		STARTLINE=$(( STARTLINE + 1 ))

		case "$LINE" in
			'') break ;;
			 *) FOUND="$LINE" && echo "$LINE" ;;
		esac
	} done <"$FILE" >"$BINGOFILE"


	export MAX=0
	while read -r LINE; do MAX=$(( MAX + 1 )); done <"$BINGOFILE"

	# write vertical to horizontal:
	# read several times linewise and print e.g. each 1st, 2nd, 3rd ...Nth element

	J=0
	for OBJ in $FOUND; do {		# e.g. repeat 5 times (5 columns)
		VLIST=
		J=$(( J + 1 ))

		I=0
		while read -r LINE; do {
			I=$(( I + 1 ))
			test $I -gt $MAX && break

			K=0
			for WORD in $LINE; do {
				K=$(( K + 1 ))
				test $K -eq $J && VLIST="$VLIST $WORD" && break
			} done
		} done <"$BINGOFILE"

		echo "$VLIST" >>"$BINGOFILE"	# file gets longer
	} done

	test -n "$FOUND" || {
		STARTLINE=3
		false
	}
}

board_summarize()
{
	SUM=0

	I=0
	HITLIST=
	NONHITLIST=
	while read -r LINE; do {
		I=$(( I + 1 ))
		HITS=0
		VALS=0

		for VALUE in $LINE; do {
			VALS=$(( VALS + 1 ))
			if is_bingovalue "$VALUE"; then
				HITS=$(( HITS + 1 ))
				HITLIST="$HITLIST $VALUE"
			else
				NONHITLIST="$NONHITLIST $VALUE"
				test $I -le $MAX && SUM=$(( SUM + VALUE ))
			fi
		} done

		[ $HITS -eq $VALS ] && WINNER=true	# but keep counting SUM
	} done <"$BINGOFILE"

	case "$WINNER" in
		true)
			for LAST in $BINGO; do :; done
			echo "SUM: $SUM LAST: $LAST MAX: $MAX"
			echo "nonhits: $NONHITLIST"
			echo "hits: $HITLIST"
			echo $(( SUM * LAST )) && return 1
		;;
	esac
}

while true; do {
	get_bingoround			# BINGO="1 2 3"

	while build_bingofile; do { 	# end of bingolist? new bingoround with more values
		BOARD=$(( BOARD + 1 ))
#		echo "=== board: $BOARD sline: $STARTLINE"
#		cat "$BINGOFILE"
#		echo "==="

		board_summarize || {
			echo "=== board: $BOARD sline: $STARTLINE"
			cat "$BINGOFILE"
			echo "==="
			exit
		}
	} done
} done
