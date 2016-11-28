#!/bin/bash

#Printing Usage instruction string
USAGE="Usage: $0 -u [url] -m [mode]

  -u    --url 		Websocket url
  -m    --mode 		listen/send/compare
  -t    --ro            Username to which the messages have to be send
  -d    --dump 		Filename to dump the messages with full path
  -c    --chat          Chat message to be send to the user
  -l    --length        Length of each random message to be generated
  -n    --number        Number of random messages to generate.
  -s    --sleep 	Time to sleep between each message
  -f1   --file1         First file whose entries will be matched against file2
  -f2   --file2         Second file whose entries will be matched against entries in file1
  -h    --help 		Display this message and exit"

if [[ $# -eq 0 || $1 == "-h" ]]; then
	echo "$USAGE"
	exit 1
fi




##reading the parameters and storing to respective variables
while [ $# -gt 0 ]
do
key="$1"
case $key in
    -u|--url)
    URL="$2"
    shift # past argument
    ;;
    -m|--mode)
    MODE="$2"
    shift # past argument
    ;;
    -d|--dump)
    DUMPFILE="$2"
    shift # past argument
    ;;
    -s|--sleep)
    SLEEP="$2"
    shift # past argument
    ;;
    -t|--to)
    TO="$2"
    shift
    ;;
     -c|--chat)
    CHAT="$2"
    shift
    ;;
    -l|--length)
    LENGTH="$2"
    shift # past argument
    ;;
    -n|--number)
    NUMBER="$2"
    shift # past argument
    ;;
    -f1|--file1)
    FILE1="$2"
    shift # past argument
    ;;
    -f2|--file2)
    FILE2="$2"
    shift # past argument
    ;;
    -v|--verbosity)
    VERBOSITY="YES"
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

##Check to force all compulsary arguments
# if [[ $URL == "" || $MODE == "" ]]; then
#     echo "Please specify the necessary arguments: url and mode of operation"
#     exit
# fi




# if [[ $QUIT == "YES" || $READY == "YES" ]];then
# 	echo "yes"
# fi




##Random string generator
isRandomStringInstalled() {
    if hash pwgen 2>/dev/null; then
        :
    else
        echo "Installing pwgen"
        sudo apt-get install -y pwgen > /dev/null
        if [[ $? -eq 0 ]]; then
          	echo "pwgen install completed"
        else
        	echo "Installation failed! Quitting..."
        	exit
        fi  
    fi
}


isJqInstalled() {
    if hash jq 2>/dev/null; then
        :
    else
        echo "Installing jq"
        sudo apt-get install -y jq > /dev/null
        if [[ $? -eq 0 ]]; then
            echo "jq install completed"
        else
            echo "Installation failed! Quitting..."
            exit
        fi  
    fi
}

dumpToFile(){    
    echo "wsdump exited"
    grep '{"type":' .velocity.txt | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | sed 's/^\(> < \|> > < \|> > > < \)//' >> $DUMPFILE
    rm -rf .velocity.txt
}

comparator(){
    missmatchedNumber=0
    lineNumber=0
    cat $1 | jq -r '.data.text' >> ".$1"
    cat $2 | jq -r '.data.text' >> ".$2"
    if [[ $(wc -l "$1" | awk '{print $1}') == $(wc -l "$2" | awk '{print $1}') ]]; then
        :
        else
            echo "Mismatch in number of lines detected, calculation may be incorrect"
    fi
    date >> Missmatched-entries.txt
    echo "=====Unmatched messages======" | tee -a Missmatched-entries.txt
    while true
    do
    read -u3 line1 || break
    read -u4 line2 || break
    ((lineNumber++))
    # echo $line1 | jq -r '.data.text'
    # echo $line2 | jq -r '.data.text'
    if grep -Fxq "$(echo $line1 | jq -r '.data.text')" ".$2"
    # if grep -Fx "$(echo $line1)" "$2"
        then
        :
    else
        ((missmatchedNumber++))
        echo "$lineNumber.$(echo $line1 | jq -r '.data.text')" | tee -a Missmatched-entries.txt
    fi
    # echo  "$line1" | jq -r '.data.text'
    # echo "$line2" | jq -r '.data.text'
    done 3<"$1" 4<"$2"
    echo "Number of unmatched entries: $missmatchedNumber"
    echo "Missmatched messages are written to the file 'Missmatched-entries.txt'"
    echo "=====END======" >> Missmatched-entries.txt
    echo "" >> Missmatched-entries.txt
    rm .$1
    rm .$2
}

# junkTextGenerator(){
#     pwgen $1 $2 | while read line; do echo '{"to": "'$3'", "msg": "'$line'"}' ; sleep 0.1; done
# }




##Main program starts here

if [[ $MODE == "listen" && $DUMPFILE == "" ]]; then
    wsdump.py $URL
    elif [[ $MODE == "listen" && $DUMPFILE ]];then
        trap dumpToFile SIGINT
        wsdump.py $URL | tee -a .velocity.txt
    elif [[ $TO && $MODE == "send" && $CHAT ]]; then
        RESPONSE=$(echo '{"to": "'$TO'", "msg": "'$CHAT'"}' | wsdump.py $URL)
        if [[ $RESPONSE == "Handshake status 403" ]]; then
            echo "Token invalid"
        elif [[ $RESPONSE == "Press Ctrl+C to quit > >" ]]; then
            echo "Message sent. If $TO is online, he will receive it."
        else
            echo "Some error occured. $TO may or may not have received the message."
        fi
    elif [[ $MODE == "send" && $LENGTH && $TO && $NUMBER && $SLEEP == "" && $DUMPFILE == "" ]]; then
        # junkTextGenerator($NUMBER,$LENGTH,$TO);
        pwgen $NUMBER $LENGTH | while read line; do echo '{"to": "'$TO'", "msg": "'$line'"}' ; sleep 0.1; done | wsdump.py $URL
    elif [[ $MODE == "send" && $LENGTH && $TO && $NUMBER && $SLEEP && $DUMPFILE == "" ]]; then
        pwgen $NUMBER $LENGTH | while read line; do echo '{"to": "'$TO'", "msg": "'$line'"}' ; sleep $SLEEP; done | wsdump.py $URL
    elif [[ $MODE == "send" && $LENGTH && $TO && $NUMBER && $SLEEP == "" && $DUMPFILE ]]; then
        pwgen $NUMBER $LENGTH | while read line; do echo '{"to": "'$TO'", "msg": "'$line'"}' ; sleep 0.1; done | wsdump.py $URL | tee -a .velocity.txt
        dumpToFile
    elif [[ $MODE == "send" && $LENGTH && $TO && $NUMBER && $SLEEP && $DUMPFILE ]]; then
        pwgen $NUMBER $LENGTH | while read line; do echo '{"to": "'$TO'", "msg": "'$line'"}' ; sleep $SLEEP; done | wsdump.py $URL | tee -a .velocity.txt
        dumpToFile
    elif [[ $MODE == "compare" && $FILE1 && $FILE2 ]]; then
        comparator $FILE1 $FILE2
    else
        :
fi

