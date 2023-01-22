#!/bin/bash

#
# bejelentkezeskor udvozol es bemondja a datumot es az idot
#
#LC_TIME rendszervaltozo tarolja, hogy milyen nyelvu legyen a datum kijelzes
#lehet: hu_HU.ISO-8859-2
#	en_US.ISO-8859-1
wavfile=~/tmp/welcome$$.wav

mes_wel_dawn_hu="Légy üdvözölve ilyen hajnali órában."
mes_wel_morning_hu="Kellemes reggelt."
mes_wel_afternoon_hu="Kellemes délutánt."
mes_wel_evening_hu="Kellemes estét."

mes_wel_dawn_en="Good morning."
mes_wel_morning_en="Good morning."
mes_wel_afternoon_en="Good afternoon."
mes_wel_evening_en="Good evening."

mes_wel=""

hourminute=`date +%R`
hour=`echo $hourminute|cut -f1 -d:`
minute=`echo $hourminute|cut -f2 -d:`
weekday=`date +%A`

#szukseges fajlok neve
espeak="espeak"
lame="lame"
mpg123="mpg123"

#szukseges fajlok eleresi utvonala
ESPEAK=`which $espeak`
LAME=`which $lame`
MPG123=`which $mpg123`

#Ez a fuggveny kezeli azt az esetet ha hianyzik egy program file
function error_noprogram ( ){
    echo
    echo Sajnos a muvelet nem vegrehajthato, mert a $1 fajl nem elerheto.
    echo Talan nics installalva    
    exit
}

#ellenorzom, hogy letezik-e az espeak program
if [ ! -x $ESPEAK ] || [ -z $ESPEAK ] ; then

    error_noprogram $espeak

fi

#ellenorzom, hogy letezik-e a lame program
if [ ! -x $LAME ] || [ -z $LAME ] ; then

    error_noprogram $lame

fi

#ellenorzom, hogy letezik-e az mpg123 program
if [ ! -x $MPG123 ] || [ -z $MPG123 ] ; then

    error_noprogram $mpg123

fi


#ha magyarul jelzi ki az idot
if [ `echo $LC_TIME|grep 'hu_HU'|wc -l` -eq 1 ]; then

    #Megallapitom a napszakot
    if [ $hour -lt 5 ]; then
        mes_wel=$mes_wel_dawn_hu;
    else    
        if [ $hour -lt 12 ]; then
            mes_wel=$mes_wel_morning_hu;
        else 
            if [ $hour -lt 19 ]; then
        	mes_wel=$mes_wel_afternoon_hu;
            else
                mes_wel=$mes_wel_evening_hu;
            fi
        fi
    fi
    
    #osszeallitom a szoveget
    mes_wel=$mes_wel" Ma "$weekday" van. Az idő "$hour" óra és "$minute" perc."

    #kimondatom
    echo $mes_wel|$espeak -v hu --stdin -w $wavfile ; $lame $wavfile - 2>/dev/null|$mpg123 - 2>/dev/null
    
    rm $wavfile
    
#mas nyelven jelzi ki az idot
else

    #Megallapitom a napszakot
    if [ $hour -lt 5 ]; then
        mes_wel=$mes_wel_dawn_en;
    else    
        if [ $hour -lt 12 ]; then
            mes_wel=$mes_wel_morning_en;
        else 
            if [ $hour -lt 19 ]; then
        	mes_wel=$mes_wel_afternoon_en;
            else
                mes_wel=$mes_wel_evening_en;
            fi
        fi
    fi
    
    #osszeallitom a szoveget
    mes_wel=$mes_wel" Today is "$weekday". The time is "$hour" hours and "$minute" minutes."

    #kimondatom
    echo $mes_wel|$espeak -v en-r --stdin -w $wavfile; $lame $wavfile - 2>/dev/null|$mpg123 - 2>/dev/null
    #echo $mes_wel|text2wave -o - -| lame - - 2>/dev/null|mpg123 - 2>/dev/null
fi
    
