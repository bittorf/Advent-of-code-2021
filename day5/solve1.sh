#!/bin/sh

FILE='input.txt'

array_put()
{
	local x="$1"
	local y="$2"
	local char="$3"

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

	# only horizontal or vertical lines:
	OK=false
	test $X1 -eq $X2 && OK=true
	test $Y1 -eq $Y2 && OK=true
	test $OK = false && continue

	X=$X1
	Y=$Y1
	while true; do {
		array_get $X $Y
		if isnumber "$FIELD"; then
			array_put $X $Y $(( FIELD + 1 ))
		else
			array_put $X $Y 1
		fi

		test $X -eq $X2 && test $Y -eq $Y2 && break

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
} done <"$FILE"

OVERLAP=0
Y=0
while [ $Y -le $YMAX ]; do {
	X=0
	while [ $X -le $XMAX ]; do {
		array_get $X $Y
		printf '%s' "$FIELD"

		case "$FIELD" in
			'.'|'1') ;;
			*) OVERLAP=$(( OVERLAP + 1 )) ;;
		esac

		X=$(( X + 1 ))
	} done

	echo '|'
	Y=$(( Y + 1 ))
} done

echo "X/Y-MAX: $XMAX/$YMAX - overlap: $OVERLAP"
