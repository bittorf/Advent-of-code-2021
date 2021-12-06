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

	case "$PREFER" in
		most)  O1=1; O2=0 ;;
		least) O1=0; O2=1 ;;
	esac

	BITS0=0
	BITS1=0

	while read -r LINE; do {
		string_get_pos "$LINE" $POS

		case "$CHAR" in
			0) BITS0=$(( BITS0 + 1 )) ;;
			1) BITS1=$(( BITS1 + 1 )) ;;
		esac
	} done <"$FILE"

	if test $BITS1 -gt $BITS0; then
		echo $O1
	else
		echo $O2
	fi
}

read -r LINE <"$FILE"

GAMMA=; I=0; while I=$(( I + 1 )); do
	GAMMA="${GAMMA}$( count_pos $I least )"
	case $I in ${#LINE}) break ;; esac
done
bin2dec $GAMMA && GAMMA=$RESULT

EPSILON=; I=0; while I=$(( I + 1 )); do
	EPSILON="${EPSILON}$( count_pos $I most )"
	case $I in ${#LINE}) break ;; esac
done
bin2dec $EPSILON && EPSILON=$RESULT

echo $(( GAMMA * EPSILON ))
