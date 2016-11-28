# velocity
Bash command line utility for web-sockets message validation

Usage: ./velocity.sh -u [url] -m [mode]

	-u    --url 		Websocket url
	-m    --mode 		listen/send/compare
	-t    --to  		Username to which the messages have to be send
	-d    --dump 		Filename to dump the messages with full path
	-c    --chat 		Chat message to be send to the user
	-l    --length 		Length of each random message to be generated
	-n    --number 		Number of random messages to generate.
	-s    --sleep 		Time to sleep between each message
	-f1   --file1 		First file whose entries will be matched against file2
	-f2   --file2 		Second file whose entries will be matched against entries in file1
	-h    --help 		Display this message and exit
