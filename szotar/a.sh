#!/bin/sh

#ez a szkript egy szotar.txt fajlbol olvassa ki a szavakat 
#es mondatja ki a hanggeneratorral.
#minden szo uj sorban van
#egy sorban eloszor az angol szo, vagy kifejezes van, = jellel
#elvalasztva koveti a magyar jelentese

#kiindulas=`cat -n ./szotar.txt`
#echo $kiindulas

#ha van parameter
if [ $# -gt 0 ]; then

    #ha letezik a parameterben megadott fajl
    if [ -r $1 ]; then

        clear;

	sor=`cat $1|wc -l`;

        #kivalogatja az aktualis sorszamu sort
        actual=`expr 1 + 0`

	while [ $actual -le $sor ]; do
    	    echo -e "\033[20;10H""                                                                                                                           "    

            pattern="^ *$actual	..*=..*"
	    eleje="^ *$actual	"

    	    hossz=`cat -n ./szotar.txt| grep "$pattern" |grep -o "$eleje"|wc -c`
    
            angol=`cat -n ./szotar.txt| grep "$pattern" |cut  -c$hossz- | cut -s -f1 -d=`
	    magyar=`cat -n ./szotar.txt| grep "$pattern" |cut -s -f2 -d=` 


    	    echo -e "\033[31m\033[1m\033[20;10H" $angol "\033[0m"    


            `echo $angol | text2wave -o - -|lame - - 2>/dev/null|mpg123 - 2>/dev/null`

	    sleep 2    
    
    	    echo -e "\033[20;40H" $magyar    
    
            `echo $magyar |espeak --stdin -w ~/tmp/tmp.wav -v hu;lame ~/tmp/tmp.wav - 2>/dev/null|mpg123 - 2>/dev/null`


#    cat -n ./szotar.txt| grep "$pattern" |cut  -c$hossz- | cut -s -f1 -d= | text2wave -o - -|lame - - 2>/dev/null|mpg123 - 2>/dev/null        
#    cat -n ./szotar.txt| grep "$pattern" |cut -s -f2 -d= |espeak --stdin -w ~/tmp/tmp.wav -v hu;lame ~/tmp/tmp.wav - 2>/dev/null|mpg123 - 2>/dev/null
    
	    actual=`expr $actual + 1`
        done
	
    else
	echo "The dictionary file doesn't exist: "$1
    fi
    
else
    echo Usage: $0 "<dictionary_file>"
fi     