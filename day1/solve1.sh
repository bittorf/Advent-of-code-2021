#!/bin/sh

I=0
while read -r VALUE; do {
	test $VALUE -gt ${VALUE_OLD:-$VALUE} && I=$(( I + 1 ))
	VALUE_OLD="$VALUE"
} done <'input.txt'

echo $I
