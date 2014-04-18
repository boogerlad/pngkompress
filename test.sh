#!/bin/bash

line=`pngout -l $1`
for word in $line
do
	echo $word
done
 test="/c3 /f5 /d32 /n110"
 regex="/c3.*/d([0-9]+)"
 if [[ $test =~ /c3.*/d([0-9]+) ]]; then
      echo ${BASH_REMATCH[1]}
 fi