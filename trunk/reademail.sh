#!/bin/bash

#
#A parameterkent megadott szot keresi az aktualis konyvtar fajljaiban
#
#su root -c "

#tobb parameter is lehet, de legalabb egy

line_summa_mask="^[> ][ONU]  .*[0-9][0-9]*  *[a-zA-Z]*"
line_unrea_mask="^[> ][NU]  .*[0-9][0-9]*  *[a-zA-Z]*"
line_name_mask="^[> ][NU]  .*[0-9][0-9]*  *[a-zA-Z][a-zA-Z]*[ ][ ]*"


line_summa=`mail -H|grep "$line_summa_mask" |wc -l`
line_unrea=`mail -H|grep "$line_unrea_mask" |wc -l`

if [ $line_unrea -gt 0 ]; then
    message=$line_unrea" olvasatlan leveled van. "

    akt=1
    sor=1
    while [ $akt -le $line_summa ]; do    

        nev=`mail -H|grep "^[> ][NU]  .*$akt  *[a-zA-Z]*" | cut -c7-25`
        targy=`mail -H|grep "^[> ][NU]  .*$akt  *[a-zA-Z]*" | cut -c57-`

    	if [ -n "$nev" ]; then
	    message=$message" "$sor". "$nev" írt "$targy" tárgyában. "
	    sor=`expr $sor + 1`
	fi
		    
        akt=`expr $akt + 1`
	
    done
            
    echo $message
    wavfile=~/tmp/$$readmail.wav
    echo $message|espeak -v hu --stdin -w $wavfile; lame $wavfile - 2>/dev/null|mpg123 - 2>/dev/null
    rm $wavfile
    
fi
	
