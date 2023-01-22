#!/bin/bash

#ez a szkript az ebroker.hu oldalrol kinyeri a parameterkent megadott
#reszveny erteket es a parameterkent megadott modon ismerteti azt

level=100
all=-1
silent=-1
stocksay=""
stockname=""
time=0;

function say (){
    `echo $@|espeak -a $level --stdin -w ~/tmp/tmp.wav -v hu;lame ~/tmp/tmp.wav - 2>/dev/null|mpg123 - 2>/dev/null`
}

function help (){
	echo "Használat: $0 [kapcsolók] [részvény_kiejtése] részvény_neve" 
	echo "Az ebroker.hu oldalrol kinyeri a megadott reszveny adatait és a paraméterek alapján megjeleníti, illetve kimondja azokat."
	echo "Kapcsolók:"
	echo "     -a        kiolvassa az aktuális árfolyamot és a változást is"
	echo "     -s        az értékeket csak kijelzi, mem mondja ki"
	echo "     -c <szám> kiolvasási_időköz(mp)"
	echo "     -t <név>  a részvény kiejtése"
	echo "     -l <szám> a kiolvasás hangereje: 0-200"
}


until test $# -eq 0; do

	case $1 in

		-h )	help; exit;;
		--help ) help; exit;;
		'-?' )	help; exit;;
		-a )	all=0; shift;;
		-s )	silent=0; shift;;
		-c )	shift
			if [ $1 -gt 0 ]; then
			    time=$1
			    shift
			else 
			    help
			    exit
			fi
			;;
		-l )	shift;  
			if [ $1 -gt 200 ] || [ $1 -lt 0 ]; then
			    help
			    exit
			else
			    level=$1
			    shift
			fi
			;;			
		-t )	shift;	stocksay=$1; shift;;

		* )	stockname=$1;	shift;;

	esac

done

if [ -z $stockname ]; then
	help
	exit;
fi

clear

    loop=0

    resz=`which resz.php`

    while [ $loop -eq 0 ]; do
        line=1;
	outtext="";
	outsay="";
	php $resz http://www.ebroker.hu/pls/ebrk/new_arfolyam_html_p.startup $stockname | while read NEWLINE; do

		#forgalmi érték
	    	if [ $line -eq 1 ]; then
			if [ $stocksay ]; then
	    			prefix="$stocksay részvény értéke: "
    				postfix=" Forint. "
			else
				prefix=""
				postfix=""
			fi
    			outsay=$prefix$NEWLINE$postfix
			outtext=$NEWLINE

			#A kiiratas es kimondatas nem kerulhet a cikluson kivulre mert erdekes modon az $outtext
			#es $outsay valtozok a "while read" cikluson belul lokalisak es nem kerunek kivulre ???

			echo $outtext;
			if [ $silent -eq -1 ]; then
				say $outsay;
			fi

		#elozo napi zaroar
	    	else if [ $line -eq 2 ]; then
			prefix=" tegnapi értéke: "
			postfix=" Forint"
		#valtozas es minden kell
	    	else if [ $line -eq 3 ] && [ $all -eq 0 ]; then
			if [ $stocksay ]; then
				prefix=" A változás: "
			else
				prefix=""
			fi
			postfix=". "	
			outsay=$prefix$NEWLINE$postfix
			outtext=$NEWLINE

			echo $outtext;
			if [ $silent -eq -1 ]; then
				say $outsay;
			fi
	    	fi
	    	fi
	    	fi
    	    	line=`expr $line + 1`
	done 

	if [ $time -eq 0 ]; then
	    loop=-1;
	else
	    sleep $time
	fi 
    done
