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

	echo "=========> BINGO=$BINGO | READMAX=$READMAX"
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

	WINNER=
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

		[ $HITS -eq $VALS ] && WINNERLINE=$I && WINNER=true	# but keep counting SUM
	} done <"$BINGOFILE"

	case "$WINNER" in
		true)
			for LAST in $BINGO; do :; done
			echo "# ==> SUM: $SUM LAST: $LAST MAX: $MAX BOARD: $BOARD BLA: $BLA"
			echo "# nonhits: $NONHITLIST"
			echo "# hits: $HITLIST | winnerline: $WINNERLINE"
	#		cat "$BINGOFILE"
			echo "# = $(( SUM * LAST ))"

			false
		;;
	esac
}

array_set()
{
	local x="$1"
	local y="$2"
	local value="$3"

	eval ARRAY_${x}_${y}='$value'
}

array_get()
{
	local x="$1"
	local y="$2"

	eval FIELD="\"\${ARRAY_${x}_${y}:-0}\""
}

show_wonboards()
{
	local i=0

	echo "+---------------------"

	while [ $i -lt $BOARD_MAX ]; do {
		i=$(( i + 1 ))
		array_get board $i
		echo "board: $i => $FIELD wins"
	} done

	echo "+---------------------"
}

BOARD_MAX=0
BLA=0
while true; do {
	OLDLINE="$BINGO"
	get_bingoround			# BINGO="1 2 3"
	NEWLINE="$BINGO"
	[ "$OLDLINE" = "$NEWLINE" ] && echo "R1: $REM1 R2: $REM2" && echo $(( REM1 * REM2 )) && exit

	BOARD=0
	while build_bingofile; do { 	# end of bingolist? new bingoround with more values
		BOARD=$(( BOARD + 1 ))
		test $BOARD -gt $BOARD_MAX && {
			BOARD_MAX=$BOARD
			touch /tmp/board-$BOARD
		}

		board_summarize || {
			# which board is the last which has *ever* won (at least once)
			test -s /tmp/board-$BOARD || {
				# 0 bytes! do all other have +0 bytes?
				B=0
				COUNT_WINNERS=0
				while test $B -le $BOARD_MAX; do {
					B=$(( B + 1 ))
					test $B -eq $BOARD && continue	# ignore myself
					test -s /tmp/board-$B && COUNT_WINNERS=$(( COUNT_WINNERS + 1 ))
				} done

				test $COUNT_WINNERS -eq $(( BOARD_MAX -1 )) && {
					ls -l /tmp/board-*
					rm -f /tmp/board-*
					exit
				}
			}

			printf '%s' '#' >>/tmp/board-$BOARD

#			array_get board $BOARD
#			array_set board $BOARD $(( FIELD + 1 ))
#			show_wonboards

			BLA=$(( BLA + 1 ))
			# squid = 8 arms + me => 9
		#	test $(( SUM * LAST )) -eq 1924 && {
		#			ls -l /tmp/board-*
		#			rm -f /tmp/board-*
		#		exit
		#	}
		#	test $BLA -eq 9 && exit
		}
	} done
} done
