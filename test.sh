#!/bin/bash

DIR=$(cd $(dirname $0); pwd)
echo $DIR
for ((j=0;j<=99;j++))
do
    for ((i=1;i<=1000;i++))
    do
        s=`expr $j \* 100`
        s=`expr $s + $i`
        t=$(printf "%03d" $j)
        echo "Serial ${s}"  >> autolearn${t}.txt
        ruby $DIR/learning.rb >> autolearn${t}.txt
    done
done
 
exit 0
