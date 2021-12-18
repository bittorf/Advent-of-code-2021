#!/bin/sh

FILE='input.txt'

#  aaaa
# b    c
# b    c
#  dddd
# e    f
# e    f
#  gggg

I=0
while read -r LINE; do {
	HEAD="${LINE%|*}"
	TAIL="${LINE#*|}"

	for WORD in $TAIL; do {
		case "${#WORD}" in
			2) I=$(( I + 1 )) ;; 	# 1
			4) I=$(( I + 1 )) ;;	# 4
			3) I=$(( I + 1 )) ;;	# 7
			7) I=$(( I + 1 )) ;;	# 8
		esac
	} done
} done <"$FILE"

echo $I
