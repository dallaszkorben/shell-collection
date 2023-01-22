#!/bin/sh

sor=1
FILES=./*.JPG
for file in $FILES
do

#    foo=$(printf "%03d" $sor)
#    mv "./$file" "./Vap_$foo.jpg"

    echo "$file -> "
#    sor=`expr $sor + 1`
done
