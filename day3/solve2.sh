#!/bin/sh

FILE='input.txt'

string_get_pos()
{
  local string="$1"             # e.g. ABCDEF
  local pos="$2"                # e.g. 3
  local rest first i=0
  local length="${#string}"     # e.g. 6

  while i=$(( i + 1 )); do
    rest="${string#?}"          # e.g.  BCDEF
    first=${string%"$rest"}     # e.g. A
    string="$rest"

    case "$i" in
      $pos) export CHAR="$first" && return 0 ;;
      $length) return 1 ;;
    esac
  done
}

pow() {
  local i=0
  local x=$1
  local y=$2

  export POW=1
  case "$y" in 0) return ;; esac

  while i=$(( i + 1 )); do
    POW=$(( POW * x ))
    case "$i" in $y) break ;; esac
  done
}

bin2dec()
{
  local binary="$1"	# e.g. 0101010101110
  local i=-1
  local last front
  export RESULT=0

  while i=$(( i + 1 )); do
    last=${binary#"${binary%?}"}
    front=${binary%?}
    binary=$front
    case "$last" in
      '') break ;;
       1) pow 2 $i && RESULT=$(( RESULT + POW )) ;;
    esac
  done
}

count_pos()
{
	POS="$1"
	PREFER="$2"	# count "most" or "least" common bit
	local file="${3:-$FILE}"
	local line
	export COUNT=
	export J=

	case "$PREFER" in
		most)  O1=1; O2=0 ; O3=1 ;;
		least) O1=0; O2=1 ; O3=0 ;;
	esac

	BITS0=0
	BITS1=0

	J=0
	while read -r line; do {
		J=$(( J + 1 ))
		string_get_pos "$line" $POS

		case "$CHAR" in
			0) BITS0=$(( BITS0 + 1 )) ;;
			1) BITS1=$(( BITS1 + 1 )) ;;
		esac
	} done <"$file"

	if   test $BITS1 -gt $BITS0; then
		COUNT=$O1
	elif test $BITS1 -eq $BITS0; then
		COUNT=$O3
	else
		COUNT=$O2
	fi
}

filter_file()
{
	local file=$1
	local pos=$2
	local bit=$3
	local line

	while read -r line; do {
		string_get_pos "$line" "$pos"
		case "$CHAR" in
			$bit) echo "$line" ;;
		esac
	} done <"$file" >"$file.tmp"

	mv "$file.tmp" "$file"
}

read -r LINE <"$FILE"
FILE_FILTERED="$FILE.filtered"

# oxygen:
cp "$FILE" "$FILE_FILTERED"
I=0
ALLBITS=

while I=$(( I + 1 )); do {
	count_pos $I most "$FILE_FILTERED"
	THISBIT="$COUNT"

	filter_file "$FILE_FILTERED" $I $THISBIT
	count_pos $I most "$FILE_FILTERED"
	THISBIT="$COUNT"

	ALLBITS="${ALLBITS}$THISBIT"

	test $J -eq 1 && read -r ALLBITS <"$FILE_FILTERED" && break
	test $I -eq ${#LINE} && break
} done

echo "ALLBITS: $ALLBITS"
bin2dec $ALLBITS
A=$RESULT
echo "A: $A"

# CO2-scrubber:
cp "$FILE" "$FILE_FILTERED"
I=0
ALLBITS=

while I=$(( I + 1 )); do {
	count_pos $I least "$FILE_FILTERED"
	THISBIT="$COUNT"

	filter_file "$FILE_FILTERED" $I $THISBIT
	count_pos $I least "$FILE_FILTERED"
	THISBIT="$COUNT"

	ALLBITS="${ALLBITS}$THISBIT"

	test $J -eq 1 && read -r ALLBITS <"$FILE_FILTERED" && break
	test $I -eq ${#LINE} && break
} done

echo "ALLBITS: $ALLBITS"
bin2dec $ALLBITS
B=$RESULT
echo "B: $B"

echo $(( A * B ))

