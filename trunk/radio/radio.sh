#!/bin/bash

#
# A parameterkent megadott nevu internet radiot jatsza le vagy rogziti
# szinten parametertol fuggoen
#
VALT=~
WAV=$VALT'/tmp/radio.wav'
MP3=$VALT'/tmp/radio.mp3'
echo $WAV
MP3PLAYER='mpg123'
MPLAYER='mplayer'
LIST='radio.list'
LISTSEPARATOR=';'
COL_ID=1
COL_URL=2
COL_NAME=3
COL_NOTE=4

function help (){
    echo Usage $0 " <csatorna> [-p] [-r]";
    echo "csatorna: ";
    while read NEWLINE; do
    
	identifier=`echo $NEWLINE|cut -s -d$LISTSEPARATOR -f1`
	radio=`echo $NEWLINE|cut -s -d$LISTSEPARATOR -f3`
	note=`echo $NEWLINE|cut -s -d$LISTSEPARATOR -f4`
	if [ $identifier ] ; then
        	echo "          $identifier ($note)";
	fi
    
    done <$XLIST 
    echo "-p        lejatszasa [default]";
    echo "-r        rogzitese";
}


flags="";
channel="";
record=false;
noplay=false;
chname="";

#megkeresi az elso listat tartalmazo fajl helyet
XLIST=`which $LIST 2>/dev/null`
if ! [ $XLIST -a -r $XLIST ] ; then
    echo "Sajnos a(z) $LIST allomany, mely a radioadok listajat tartalmazza nem talalhato a keresesi utvonalaban..."
    exit;
fi    


until test $# -eq 0; do

    case $1 in
	-h ) help; exit ;;	
	-help ) help; exit ;;	
	'-?' ) help; exit ;;
	-r ) record=true; if ! [ $play ] ; then  play=false; fi; shift ;;
	-p ) play=true; shift ;;
	* )
	    #pontosan egy talalat van
	    if [ `grep -c "^$1$LISTSEPARATOR" $XLIST` -eq 1 ]; then
		actline=`grep "^$1$LISTSEPARATOR" $XLIST`;
		channel=`echo $actline|cut -s -d$LISTSEPARATOR -f2`
		chname=`echo $actline|cut -s -d$LISTSEPARATOR -f3`
	    else
		echo "Nem ertelmezheto parameter: $1"; help; exit ;
	    fi
	    shift
	    ;;
    esac
done


if ! $record ; then
    play=true;
fi

if ! [ $channel ] ; then
    echo "Nem adott meg csatornat";
    help
    exit;
fi

XMPLAYER=`which $MPLAYER 2>/dev/null`
XMP3PLAYER=`which $MP3PLAYER 2>/dev/null`

#Ha nemletezik a player
if ! [ $XMPLAYER -o -x $XMPLAYER ] ; then
    echo "Sajnos a(z) $MPLAYER lejatszo nem talalhato a keresesi utvonalaban..."
    exit;
fi    
if ! [ $XMP3PLAYER -o -x $XMP3PLAYER ] ; then
    echo "Sajnos a(z) $MP3PLAYER lejatszo nem talalhato a keresesi utvonalaban..."
    exit;
fi    

#Ha nem irhatoak a fajlok


#ha csak lejatszas
if $play  &&  ! $record  ; then
    echo "$chname halgatas..."
#    $XMPLAYER $channel -vc dummy -vo null 2>/dev/null 1>/dev/null
    $XMPLAYER $channel -ao alsa -vc dummy -vo null 
    exit;
fi

#ha csak rogzites
if ! $play && $record ; then
    echo "$chname rogzites MP3-ban csendben..."
    
    rm $WAV 2>/dev/null
    rm $MP3 2>/dev/null
    $XMPLAYER $channel -ao pcm:file=$WAV -vc dummy -vo null 2>/dev/null 1>/dev/null &

    #varakozik hogy letrejojjon a fajl    
    while ! [ -f $WAV ] ; do    
        sleep 1	
    done
    
    lame -h -b 128 $WAV $MP3 1>/dev/null
    exit;    

fi



#ha rogzitendo es halgatando
if [ $play -a $record ] ; then
    echo "$chname halgatas es rogzites..."
    rm $WAV 2>/dev/null
    rm $MP3 2>/dev/null
    $XMPLAYER $channel -ao pcm:file=$WAV -vc dummy -vo null 2>/dev/null 1>/dev/null &

    #varakozik hogy letrejojjon a fajl    
    while ! [ -f $WAV ] ; do    
        sleep 1	
    done

    sleep 5    
    lame -h -b 128 $WAV -|tee $MP3 |mpg123 -
    

fi

exit;
