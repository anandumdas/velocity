#!/bin/bash

#Printing Usage instruction string
USAGE="Usage: $0 -u [url] -m [mode]

  -u  --url 		Websocket url
  -m  --mode 		listen/send
  -t  --to              Username to which the messages have to be send
  -d  --dump 		Filename to dump the messages with full path
  -c  --chat        Chat message to be send to the user
  -s  --sleep 		Time to sleep between each message
  -h  --help 		Display this help and exit"

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
     -r|--ready)
    READY="YES"
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

dumpToFile(){    
    echo "wsdump exited"
    grep '{"type":' .velocity.txt | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | sed 's/^> < //' >> $DUMPFILE
    rm -rf .velocity.txt
}



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
    # elif [[ condition ]]; then
    #         #statements
    else
        :
fi

