#!/bin/bash

#zw5 may not be beneficial

path=`winepath -w $1`
wine truepng -f0,5 -i0 -g0 -a1 -md remove all -zc9 -zm9 -zs0-3 -force -y "$path"
wine pngwolfz --in="$path" --out="$path" --exclude-singles --exclude-heuristic --zlib-level=9 --zlib-memlevel=9 --max-stagnate-time=0 --max-evaluations=1000 --even-if-bigger

if [[ `pngout -l $1` =~ /c3.*/d([0-9]+) ]]
then
	bitdepth=${BASH_REMATCH[1]}
	basename=`basename $1` #0
	mkdir /tmp/$basename
	# cp $1 /tmp/$basename/$basename
	pngout -c6 -s4 -y -force "$1" "/tmp/$basename/expand-$basename" #1
	pngout -c3 -d$bitdepth -n1 -y "/tmp/$basename/expand-$basename" "/tmp/$basename/n1-$basename" #2
	pngout -c3 -d$bitdepth -n2 -y "/tmp/$basename/expand-$basename" "/tmp/$basename/n2-$basename" #3
	pngout -c3 -d$bitdepth -n3 -y "/tmp/$basename/expand-$basename" "/tmp/$basename/n3-$basename" #4
	pngout -c3 -d$bitdepth -n4 -y "/tmp/$basename/expand-$basename" "/tmp/$basename/n4-$basename" #5

	pngout -c3 -d$bitdepth -n1 -y "/tmp/$basename/expand-$basename" "/tmp/$basename/combine-$basename"
	pngout -c3 -d$bitdepth -n2 -y "/tmp/$basename/combine-$basename"
	pngout -c3 -d$bitdepth -n3 -y "/tmp/$basename/combine-$basename"
	pngout -c3 -d$bitdepth -n4 -y "/tmp/$basename/combine-$basename" #6

	pngout -f6 -kp -ks -y -force "$1" "/tmp/$basename/comp-$basename" #7
	smallest=`ls -Sr1 /tmp/$basename/ | head -n 1`
	# echo $smallest
	# echo "real"
	# ls -Sr1l /tmp/$basename/
	mv "/tmp/$basename/$smallest" "$1"
	rm -rf /tmp/$basename
fi
advdef -z -4 -i 30 "$1"

./DeflOpt -k -b -s "$1"

./defluff <$1 >$1.tmp

mv "$1.tmp" "$1"

./DeflOpt -k -b -s "$1"

./defluff <$1 >$1.tmp

mv "$1.tmp" "$1"