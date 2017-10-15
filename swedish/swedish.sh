#!/bin/bash


function thereWasWrongAnswer {

    for i in `seq 1 $lines` ; do

	#van olyan sor amire meg sosem kerult sor
        if [ "${outcase[$i]]}" -eq 0 ] ; then

	    echo 1
	    return
	    
	fi

        if [ "${outresult[$i]]}" -eq 0 ] ; then

	    echo 1
	    return
	    
	fi

    done

    echo 0

}

function noSelectedRow {
    noSelectedRows=0
    for i in `seq 1 $lines` ; do

        if [ "${outcase[$i]]}" -eq 0 ] ; then
	    let noSelectedRows+=1
	fi
    done
	echo $noSelectedRows
}

function noAnsweredWell {
    noAnsweredWells=0
    for i in `seq 1 $lines` ; do
        if [ "${outresult[$i]]}" -eq 0 ] ; then
	    let noAnsweredWells+=1
	fi
    done
	echo $noAnsweredWells
}

function godness {
    let gn=(100*$1/$2)
    echo $gn\%
}

QUESTION_XPOS=10
QUESTION_YPOS=10
ANSWER_XPOS=10
ANSWER_YPOS=11
RESULT_XPOS=10
RESULT_YPOS=12
RIGHTANSWER_XPOS=10
RIGHTANSWER_YPOS=16
STAT_XPOS=10
STAT_YPOS=20

H="H"

GREEN="\033[40m\033[1;32m"
RED="\033[40m\033[1;31m"
BLUE="\e[34m"
YELLOW="\e[33m"
DEFAULT="\033[00m"

WORDFILE="./basic.txt"

QUESTION_LANG="sv"
SWEDISH_LAN="sv"
HUNGARIAN_LAN="sv"

#
#1st parameter-question column
#
if [ "$1" == "1" ]; then
    showcolumn=2
    answercolumn=3
    QUESTION_LANG="sv"
elif [ "$1" == "2" ]; then
    showcolumn=3
    answercolumn=2
    QUESTION_LANG="hu"
else
    showcolumn=3
    answercolumn=2
    QUESTION_LANG="hu"
fi


# if there is no 3rd parameter
if [ -z "$3" ]; then

    # then the wordfile is the default file:swedishsentences.txt

    # and the 2nd parameter is the word-group-identifier-pattern
    if [ -z "$2" ]; then
        groupgrep="^.+:"
    else
        groupgrep="^"$2".*:"
    fi

# if there is 3rd parameter
else
    groupgrep="^"$3".*:"
    WORDFILE="./"$2
fi



lines=`cat $WORDFILE| grep -P $groupgrep|wc -l`

#clear the screen
reset

for i in `seq 1 $lines` ; do
    let outresult[$i]=0
    let outcase[$i]=0
done

rightanswers=0
questions=0
notquestioned=$lines


while true; do

    actuallinenumber=$((RANDOM%$lines+1))

#echo -n -e "\033[$STAT_YPOS;$STAT_XPOS$H"
#echo -n $actuallinenumber

    #Ha elozoleg sikeres volt de 
    if [ "${outresult[$actuallinenumber]}" -eq 1 ] ; then
	#meg van nem kerdezett szo vagy van sikertelen valasz
	twwa=$(thereWasWrongAnswer)
	if [ "$twwa" -eq 1 ] ; then
	    #akkor keresek egy masik szot
	    continue
	fi
    fi

    actualline=`cat $WORDFILE|grep -P $groupgrep |sed $actuallinenumber'!d' `

    questionword=`echo $actualline | cut -d':' -f$showcolumn`

    #
    # Show the question word
    #
    echo -n -e "\033[$QUESTION_YPOS;$QUESTION_XPOS$H"
    echo -n -e $RED
    echo $questionword
    echo -n -e $DEFAULT
    #Say the question word
    echo $questionword | espeak -v $QUESTION_LANG

    #
    # Read the answer
    #
    echo -n -e "\033[$ANSWER_YPOS;$ANSWER_XPOS$H"
    read answer

    #
    #Show the result
    #
    echo -n -e "\033[$RIGHTANSWER_YPOS;$RIGHTANSWER_XPOS$H"

    rightanswerCategory=`echo $actualline | cut -d':' -f1`
    rightAnswer=`echo $actualline | cut -d':' -f$answercolumn`

    formPartRightAnswer=$rightAnswer

    echo -n -e "\033[$RESULT_YPOS;$RESULT_XPOS$H"
    if [ "$formPartRightAnswer" == "$answer" ] ; then
	echo -n -e $GREEN
	echo OK
	let outresult[$actuallinenumber]=1
	let rightanswers+=1
    else
        echo -n -e $RED
	echo Wrong
	let outresult[$actuallinenumber]=0
    fi
    let outcase[$actuallinenumber]+=1
    let questions+=1

    #
    #Show the right answer (all line)
    #
    SPACE_BETWEEN_FORMS='    '
    echo -n -e "\033[$RIGHTANSWER_YPOS;$RIGHTANSWER_XPOS$H"
    echo -n -e $RED
    echo -n $rightanswerCategory
    echo -n "${SPACE_BETWEEN_FORMS}"
    echo -n -e $GREEN
    echo -n $rightAnswer
    echo -n "${SPACE_BETWEEN_FORMS}"

    #statisztika
    echo -n -e "\033[$STAT_YPOS;$STAT_XPOS$H"
    echo -n -e $YELLOW
    echo -n $rightanswers/
    echo -n $questions/
    echo -n $(noAnsweredWell)
    echo -n " "\($(godness  $rightanswers $questions)\)



    echo -n -e $DEFAULT
    echo -n -e "\n"
    #Say the all line
    echo $actualline | cut -d':' -f2 --output-delimiter=$' ' | espeak -v $SWEDISH_LAN
 
    #waits for a keypress
    read  -n1 -r  key

    #clear the lines
    echo -n -e "\033[$QUESTION_YPOS;$QUESTION_XPOS$H"
    echo -n -e "\033[K" 
    
    echo -n -e "\033[$ANSWER_YPOS;0$H"
    echo -n -e "\033[K" 

    echo -n -e "\033[$RESULT_YPOS;$RESULT_XPOS$H"
    echo -n -e "\033[K" 

    echo -n -e "\033[$RIGHTANSWER_YPOS;$RIGHTANSWER_XPOS$H"
    echo -n -e "\033[K" 

    echo -n -e "\033[$STAT_YPOS;$STAT_XPOS$H"
    echo -n -e "\033[K" 
done

