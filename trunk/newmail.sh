#!/bin/bash

#
#A kmail uj uzenetet toltott le
#errol ertesit ez a script
#
outfile=~/tmp/$$newmail.out
firstlinefile=~/tmp/$$newmail.first

touch $outfile

line_summa_mask="^[> ][ONU]  .*[0-9][0-9]*  *[a-zA-Z]*"
status_mask="^X-Status: "
new_mask=$status_mask"NC"

mess_no=0
maildirectory=~/.kde/share/apps/kmail/mail/inbox/cur
echo $maildirectory
for file in `ls $maildirectory`; do
echo $file
	echo "From noname" > $firstlinefile
	cat $firstlinefile $maildirectory/$file >>$outfile

done



line_summa_mask="^[> ][ONUR]  .*[0-9][0-9]*  *[a-zA-Z\"]*"
line_unrea_mask="^[> ][ONUR]  .*[0-9][0-9]*  *[a-zA-Z\"]*"
line_name_mask="^[> ][ONUR]  .*[0-9][0-9]*  *[a-zA-Z\"][a-zA-Z\"]*"


line_summa=`mail -H -f $outfile|grep "$line_summa_mask" |wc -l`
line_unrea=`mail -H -f $outfile|grep "$line_unrea_mask" |wc -l`

mail -H -f $outfile


if [ $line_unrea -gt 0 ]; then
    message=$line_unrea" olvasatlan leveled van. "

    akt=1
    sor=1
    while [ $akt -le $line_summa ]; do    

        nev=`mail -H -f $outfile|grep "^[> ][ONUR]  .*$akt  *[a-zA-Z]*" | cut -c7-25`
        targy=`mail -H -f $outfile|grep "^[> ][ONUR]  .*$akt  *[a-zA-Z]*" | cut -c57-`

    	if [ -n "$nev" ]; then
	    message=$message" "$sor". "$nev" írt "$targy" tárgyában. "
	    sor=`expr $sor + 1`
	fi
		    
        akt=`expr $akt + 1`
	
    done

    echo $message
#    wavfile=~/tmp/$$readmail.wav
#    echo $message|espeak -v hu --stdin -w $wavfile; lame $wavfile - 2>/dev/null|mpg123 - 2>/dev/null
#    rm $wavfile

fi
	
#rm $outfile
rm $firstlinefile