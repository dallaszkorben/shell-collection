#!/bin/bash

QUESTION_XPOS=10
QUESTION_YPOS=10
ANSWER_XPOS=10
ANSWER_YPOS=11
RIGHTANSWER_XPOS=10
RIGHTANSWER_YPOS=12
H="H"

GREEN="\033[40m\033[1;32m"
RED="\033[40m\033[1;31m"
DEFAULT="\033[00m"

WORDFILE="./swedishnouns.txt"

QUESTION_LANG="sv"
SWEDISH_LAN="sv"
HUNGARIAN_LAN="sv"


if [ "$1" == "1" ]; then
    showcolumn=3
    QUESTION_LANG="sv"
elif [ "$1" == "2" ]; then
    showcolumn=4
    QUESTION_LANG="sv"
elif [ "$1" == "3" ]; then
    showcolumn=5
    QUESTION_LANG="sv"
elif [ "$1" == "4" ]; then
    showcolumn=6
    QUESTION_LANG="sv"
else
    showcolumn=7
    QUESTION_LANG="hu"
fi

#lines=`cat $WORDFILE| wc -l`

if [ "$2" == "1" ]; then
    groupgrep="^1:"
elif [ "$2" == "2" ]; then
    groupgrep="^2:"
elif [ "$2" == "3" ]; then
    groupgrep="^3:"
elif [ "$2" == "4" ]; then
    groupgrep="^4:"
elif [ "$2" == "5" ]; then
    groupgrep="^5:"
elif [ "$2" == "6" ]; then
    groupgrep="^6:"
else
    groupgrep="^\d:"
fi

lines=`cat $WORDFILE| grep -P $groupgrep|wc -l`

#clear the screen
reset

while true; do

    actuallinenumber=$((RANDOM%$lines+1))
    actualline=`cat $WORDFILE|grep -P $groupgrep |sed $actuallinenumber'!d' `

    questionword=`echo $actualline | cut -d':' -f$showcolumn`

    #Show the question word
    echo -n -e "\033[$QUESTION_YPOS;$QUESTION_XPOS$H"
    echo -n -e $RED
    echo $questionword
    echo -n -e $DEFAULT
    #Say the question word
    echo $questionword | espeak -v $QUESTION_LANG

    echo -n -e "\033[$ANSWER_YPOS;$ANSWER_XPOS$H"
    read answer

    #Show the all line
    echo -n -e "\033[$RIGHTANSWER_YPOS;$RIGHTANSWER_XPOS$H"
    echo -n -e $GREEN
    echo $actualline | cut -d':' -f1,2,3,4,5,6,7 --output-delimiter=$'    ' 
    echo -n -e $DEFAULT
    echo -n -e "\n"
    #Say the all line
    echo $actualline | cut -d':' -f2,3 --output-delimiter=$' ' | espeak -v $SWEDISH_LAN
    echo $actualline | cut -d':' -f4 | espeak -v $SWEDISH_LAN
    echo $actualline | cut -d':' -f5 | espeak -v $SWEDISH_LAN
    echo $actualline | cut -d':' -f6 | espeak -v $SWEDISH_LAN

    #waits for a keypress
    read  -n1 -r  key

    #clear the lines
    echo -n -e "\033[$QUESTION_YPOS;$QUESTION_XPOS$H"
    echo -n -e "\033[K" 
    
    echo -n -e "\033[$ANSWER_YPOS;$ANSWER_XPOS$H"
    echo -n -e "\033[K" 

    echo -n -e "\033[$RIGHTANSWER_YPOS;$RIGHTANSWER_XPOS$H"
    echo -n -e "\033[K" 
done
