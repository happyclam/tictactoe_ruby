#!/bin/bash

DIR=$(cd $(dirname $0); pwd)
echo $DIR
for ((i=1;i<=1000;i++))
do
    echo "Serial ${i}"  >> autolearn1.txt
    ruby $DIR/learning.rb >> autolearn1.txt
#    echo "Serial ${i}"
#    ruby $DIR/learning.rb
done
 
exit 0
