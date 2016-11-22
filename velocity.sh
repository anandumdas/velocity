#!/bin/bash

#Printing Usage instruction string
USAGE="Usage: $0 -u [url] -m [mode]

  -u  --url 		Websocket url
  -m  --mode 		listen/send
  -d  --dump 		Filename to dump the messages with full path
  -s  --sleep 		Time to sleep between each message
  -h  --help 		Display this help and exit"

if [[ $# -eq 0 || $1 == "-h" ]]; then
	echo "$USAGE"
	exit 1
fi




##reading the parameters and storing to respective variables
while [ $# -gt 1 ]
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
    DUMPFILE="$2"
    shift # past argument
    ;;
    -q|--quit)
    DEFAULT=YES
    ;;
     -r|--ready)
    READY=YES
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

##Need a check here to force all compulsary arguments





##Dumps the messages to user defined file
if [[ "$MODE" == "listen" ]];then
	wsdump.py $URL | tee -a $DUMPFILE
fi

# if [[ $DEFAULT -eq YES || $READY -eq YES ]];then
# 	echo $DEFAULT
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
