#!/bin/bash

path=`winepath -w $1`
wine truepng -f0,5 -i0 -g0 -a1 -md remove all -zc9 -zm3-9 -zs0-3 -force -y "$path"
wine pngwolfz --in="$path" --out="$path" --exclude-singles --exclude-heuristic --zlib-level=9 --max-stagnate-time=0 --max-evaluations=100 --even-if-bigger

if [[ `pngout -l $1` =~ /c3.*/d([0-9]+) ]]
then
	bitdepth=${BASH_REMATCH[1]}
	basename=`basename $1`
	pngout -c6 -s4 -y "$1" "/tmp/$basename"
	pngout -c3 -d$bitdepth -n1 -y "/tmp/$basename"
	pngout -c3 -d$bitdepth -n2 -y "/tmp/$basename"
	pngout -c3 -d$bitdepth -n3 -y "/tmp/$basename"
	pngout -c3 -d$bitdepth -n4 -y "/tmp/$basename"
	pngout -f6 -kp -ks -y "$1" "/tmp/$basename"
	mv "/tmp/$basename" "$1"
fi
advdef -z -4 -i 30 "$1"