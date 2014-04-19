#!/bin/bash

path=`winepath -w $1`
wine truepng -f0,5 -i0 -g0 -a1 -md remove all -zc9 -zm3-9 -zs0-3 -force -y "$path"
wine pngwolfz --in="$path" --out="$path" --exclude-singles --exclude-heuristic --zlib-level=9 --max-stagnate-time=0 --max-evaluations=1 --even-if-bigger

if [[ `pngout -l $1` =~ /c3.*/d([0-9]+) ]]
then
	bitdepth=${BASH_REMATCH[1]}
	pngout -f6 -kp -ks -y -force "$1" "$1.tmp.png"
	pngout -c6 -s4 -y -force "$1"
	pngout -c3 -d$bitdepth -n1 -y "$1"
	pngout -c3 -d$bitdepth -n2 -y "$1"
	pngout -c3 -d$bitdepth -n3 -y "$1"
	pngout -c3 -d$bitdepth -n4 -y "$1"
	if [[ `stat -c%s $1.tmp.png` < `stat -c%s $1` ]]
	then
		mv "$1.tmp.png" "$1"
	else
		rm "$1.tmp.png"
	fi
fi
advdef -z -4 -i 30 "$1"

./DeflOpt -k -b "$1"

./defluff <$1 >$1.tmp

mv "$1.tmp" "$1"

./DeflOpt -k -b "$1"

./defluff <$1 >$1.tmp

mv "$1.tmp" "$1"