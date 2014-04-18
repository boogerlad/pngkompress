#!/bin/bash

#if folder then count threads and then split workload
wine truepng -f0,5 -i0 -g0 -a1 -md remove all -zc9 -zm3-9 -zs0-3 -force -y $1
./pngwolf --in="$1" --out="$1" --exclude-singles --exclude-heuristic --zlib-level=9 --max-stagnate-time=0 --max-evaluations=1 --even-if-bigger

if [[ `pngout -l $1` =~ /c3.*/d([0-9]+) ]]
then
	bitdepth=${BASH_REMATCH[1]}
	basename=`basename $1`
	pngout -c6 -s4 -q -y $1 /tmp/$basename
	pngout -c3 -d$bitdepth -n1 -q -y /tmp/$basename
	pngout -c3 -d$bitdepth -n2 -q -y /tmp/$basename
	pngout -c3 -d$bitdepth -n3 -q -y /tmp/$basename
	pngout -c3 -d$bitdepth -n4 -q -y /tmp/$basename
	pngout -f6 -kp -ks -q -y $1 /tmp/$basename
	mv /tmp/$basename $1
fi
advdef -z -4 -i 30 -q "$1"