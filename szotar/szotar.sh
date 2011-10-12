#!/bin/sh

# ez a szkript egy szotar.txt fajlbol olvassa ki a szavakat 
# es mondatja ki a hanggeneratorral.
# Minden szo-jelentes uj sorba kerul
# Eloszor a kulcs  szo, vagy kifejezes szerepel. Ezt koveti = jellel
# elvalasztva az ertek vagy jelentes.
# A legvegen mindenkeppen kell egy sorzaro karakter
#
# Meghivasa:
#
# szotar.sh <dictionary_file> [key_language] [value_language]
#
# dictionary_file	-A szotar fajl neve
# key_language		-A kulcs szo nyelve. pld en, hu, it...
# value_language	-A jelentes nyelve
#
# Ha nem adunk meg egy nyelvet sem, akkor az alapertelmezett kulcs nyelv az angol
# es a jelentes nyel a magyar
# Ha csak 1 nyelvet adunk meg, akkor az a kulcs nyelv lesz, es figyelmen kivul 
# hagyja a jelentest


#ha van parameter
if [ $# -gt 0 ] && [ $# -lt 4 ]; then

    #ha letezik a parameterben megadott fajl
    if [ -r $1 ]; then

	dictionary=$1
	possible_languages=en:it:hu
	second=1

	#nincs nyelv meghatarozva
	if [ $# -eq 1 ]; then
	    key_language="en"
	    value_language="hu"
	fi

	#csak a kulcs nyelv van megadva
        if [ $# -eq 2 ]; then
	    key_language=$2
	    value_language=$2
	    second=0
	fi 
	
	#kulcs-ertek nyelv van megadva
        if [ $# -eq 3 ]; then
	    key_language=$2
	    value_language=$3	
	fi 
	
	#vizsgalja a nyelv tartalmat
	#meg nem

        clear;

	sor=`cat $1|wc -l`;

        #kivalogatja az aktualis sorszamu sort
        actual=`expr 1 + 0`

	while [ $actual -le $sor ]; do
    	    #echo -e "\033[20;10H""                                                                                                                           "
    	    echo "\033[20;10H""                                                                                                                           "
    	    
            pattern="^ *$actual	..*=..*"
	    eleje="^ *$actual	"

    	    hossz=`cat -n ./$dictionary| grep "$pattern" |grep -o "$eleje"|wc -c`
    
            key_text=`cat -n ./$dictionary| grep "$pattern" |cut  -c$hossz- | cut -s -f1 -d=`
	    value_text=`cat -n ./$dictionary| grep "$pattern" |cut -s -f2 -d=` 


    	    #echo -e "\033[31m\033[1m\033[20;10H" $angol "\033[0m"    
    	    echo "\033[31m\033[1m\033[20;10H" $key_text "\033[0m"        	    

            #`echo $angol | text2wave -o - -|lame - - 2>/dev/null|mpg123 - 2>/dev/null`
            `echo $key_text |espeak --stdin -w ~/tmp/tmp.wav -v $key_language;lame ~/tmp/tmp.wav - 2>/dev/null|mpg123 - 2>/dev/null`            

	    sleep 2    

	    #ha mind ket nyelv meg van adva
	    if [ $second -eq 1 ]; then

		#echo -e "\033[20;40H" $value_text        
    		echo "\033[20;40H" $value_text    
    
		#`echo $magyar |espeak --stdin -w ~/tmp/tmp.wav -v hu;lame ~/tmp/tmp.wav - 2>/dev/null|mpg123 - 2>/dev/null`
        	`echo $value_text |espeak --stdin -w ~/tmp/tmp.wav -v $value_language;lame ~/tmp/tmp.wav - 2>/dev/null|mpg123 - 2>/dev/null`            

		#    cat -n ./szotar.txt| grep "$pattern" |cut  -c$hossz- | cut -s -f1 -d= | text2wave -o - -|lame - - 2>/dev/null|mpg123 - 2>/dev/null        
		#    cat -n ./szotar.txt| grep "$pattern" |cut -s -f2 -d= |espeak --stdin -w ~/tmp/tmp.wav -v hu;lame ~/tmp/tmp.wav - 2>/dev/null|mpg123 - 2>/dev/null
	    fi
    
	    actual=`expr $actual + 1`
        done
	
    else
	echo "The dictionary file doesn't exist: "$1
    fi
    
else
    echo Usage: $0 "<dictionary_file> [key_language] [value_language]"
fi     