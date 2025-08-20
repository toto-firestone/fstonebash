#
# Tools for remote management
#

detached_launcher() {
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
		local cmd=$1
		local out_f=$2
		local pid_f=$3
	else
		echo "not enough arguments provided"
		echo "detached_launcher <command> <stdout_file> <pid_file>"
		echo "all arguments non optional"
		return
	fi
	# NOT REACHED IF ARGUMENT NUMBER CHECK FAILS

	local cmd_chk=$(which "$cmd")
	if [ -z "$cmd_chk" ]; then
		echo "no chance that $cmd is executable - skip"
		return
	else
		echo "command=$cmd_chk"
	fi
	# NOT REACHED IF RUN COMMAND CHECK FAILS

	echo "stdout_file=$out_f"
	echo "pid_file=$pid_f"

	export DISPLAY=:0.0
	nohup $cmd > $out_f 2>&1 &
	local pp=$!
	disown
	echo "$pp" > $pid_f
}

