# this one can remain non executable
# use it with source function-lib.sh


radish_message() {
	echo "THIS IS RADISH AUTOMATION TOOL \\o/"
	echo "$1"
	echo "DISCLAIMER : always keep in mind what a happy radish is"
	read -p "press return key..."
}

radish_message_noprompt() {
	echo "THIS IS RADISH AUTOMATION TOOL \\o/"
	echo "$1"
	echo "DISCLAIMER : always keep in mind what a happy radish is"
}
