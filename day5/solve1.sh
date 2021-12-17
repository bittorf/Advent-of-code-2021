#!/bin/sh

FILE='input2.txt'

array_put()
{
	local x="$1"
	local y="$2"
	local char="$3"

	echo "put: $x,$y = $char"
	eval ARRAY_${x}_${y}='$char'
}

array_get()
{
	local x="$1"
	local y="$2"

	# set a global var
	eval FIELD="\"\${ARRAY_${x}_${y}:-.}\""
}

isnumber(){ test 2>/dev/null ${1:-a} -eq "${1##*[!0-9-]*}";}

XMAX=0
YMAX=0
while read -r LINE; do {
	# topleft = 0,0
	# e.g. 0,9 -> 5,9
	set -- $LINE
	X1=${1%,*}
	Y1=${1#*,}

	X2=${3%,*}
	Y2=${3#*,}

	test $X1 -gt $XMAX && XMAX=$X1
	test $X2 -gt $XMAX && XMAX=$X2

	test $Y1 -gt $YMAX && YMAX=$Y1
	test $Y2 -gt $YMAX && YMAX=$Y2

#	echo "X1:$X1 Y1:$Y1 X2:$X2 Y2:$Y2 | X/YMAX: $XMAX/$YMAX"

	X=$X1
	Y=$Y1
	while true; do {
		test $X -eq $X2 && test $Y -eq $Y2 && break

		echo "X:$X Y:$Y => X2:$X2 Y2:$Y2"

		array_get $X $Y
		if isnumber "$FIELD"; then
			array_put $X $Y $(( FIELD + 1 ))
		else
			array_put $X $Y 1
		fi

		if   test $X -lt $X2; then
			X=$(( X + 1 ))
		elif test $X -gt $X2; then
			X=$(( X - 1 ))
		fi

		if   test $Y -lt $Y2; then
			Y=$(( Y + 1 ))
		elif test $Y -gt $Y2; then
			Y=$(( Y - 1 ))
		fi
	} done

	break
} done <"$FILE"

XMAX=9
YMAX=9

Y=0
while [ $Y -lt $YMAX ]; do {
	X=0
	while [ $X -lt $XMAX ]; do {
		array_get $X $Y
		printf '%s' "$FIELD"
		X=$(( X + 1 ))
	} done

	echo '|'
	Y=$(( Y + 1 ))
} done
