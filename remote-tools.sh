#
# Tools for remote management
#

enable_remote_ssh() {
	export DISPLAY=:0.0
	export XAUTHORITY=$HOME/.Xauthority
}

detached_launcher() {
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
		local cmd=$1
		local out_f=$2
		local pid_f=$3
	else
		echo "not enough arguments provided"
		echo "detached_launcher <command> <stdout_file> <pid_file>"
		echo "all arguments are non optional"
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

	enable_remote_ssh
	nohup $cmd > $out_f 2>&1 &
	local pp=$!
	disown
	echo "$pp" > $pid_f
}

detached_cmd_line_launcher() {
	if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] && [ -n "$4" ]; then
		local cmd=$1

		## WARNING : argument 2 may contain spaces
		local args="$2"

		local out_f=$3
		local pid_f=$4
	else
		echo "not enough arguments provided"
		echo "detached_cmd_line_launcher <command> <\"arguments\"> <stdout_file> <pid_file>"

		echo "all arguments are non optional"
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

	echo "arguments=\"$args\""
	echo "stdout_file=$out_f"
	echo "pid_file=$pid_f"

	enable_remote_ssh
	nohup $cmd "$args" > $out_f 2>&1 &
	local pp=$!
	disown
	echo "$pp" > $pid_f
}

remote_screenshot() {
	enable_remote_ssh
	import -window root /tmp/remote-shot.png
}

clear_locks() {
	remove_task ${PAUSE_LOCK##*/}
	remove_task ${STOP_LOCK##*/}
}

killall_bots() {
	local search_bot_pid=$(ps -a | grep -v grep | grep multi-cycle-run | cut -d ' ' -f 1)

	while [ -n "$search_bot_pid" ]; do
		echo "* found instance of multi-cycle-run.sh : $search_bot_pid"
		kill $search_bot_pid
		search_bot_pid=$(ps -a | grep -v grep | grep multi-cycle-run | cut -d ' ' -f 1)

	done
	clear_locks
	echo "*** killed all multi-cycle-run.sh ***"
}

get_server_cycle() {
	local start_server=$1
	local server_cycle
	if [ "$start_server" == "s1" ]; then
		server_cycle="s1 s31 s27 s1 s31 s27 s14"
	elif [ "$start_server" == "s27" ]; then
		server_cycle="s27 s1 s31 s27 s1 s31 s14"
	else
		server_cycle="s31 s27 s1 s31 s27 s1 s14"
	fi
	echo $server_cycle
}

remote_auto_firestone_start() {
	## always make sure that DISPLAY and XAUTHORITY are set
	enable_remote_ssh

	## helps detecting detached process
	export DETACHED_BOT=true

	## ensures that there is no running firefox with brute force
	killall firefox
	echo "*** blind killed all firefox ***"

	## kill all instances of multi-cycle-run.sh
	killall_bots

	./firestone-starter.sh
	echo "*** firestone started ***"

	local server_cycle=$(get_server_cycle $1)

	detached_cmd_line_launcher ./multi-cycle-run.sh "$server_cycle" ./tmp/cycle-run.out ./tmp/cycle-run.pid

	echo "*** bot started ***"
}

local_auto_firestone_start() {
	## helps detecting local process
	export DETACHED_BOT=false

	## ensures that there is no running firefox with brute force
	killall firefox
	echo "*** blind killed all firefox ***"

	## kill all instances of multi-cycle-run.sh
	killall_bots

	./firestone-starter.sh
	echo "*** firestone started ***"

	local server_cycle=$(get_server_cycle $1)

	echo "*** starting bot ***"
	if [ -f "./tmp/cycle-run.pid" ]; then
		rm "./tmp/cycle-run.pid"
	fi
	./multi-cycle-run.sh "$server_cycle"
}

local_only_bot_start() {
	## helps detecting local process
	export DETACHED_BOT=false

	## kill all instances of multi-cycle-run.sh
	killall_bots

	local server_cycle=$(get_server_cycle $1)

	echo "*** starting bot ***"
	if [ -f "./tmp/cycle-run.pid" ]; then
		rm "./tmp/cycle-run.pid"
	fi
	./multi-cycle-run.sh "$server_cycle"
}

killthis_bot() {
	kill $(cat ./tmp/cycle-run.pid)
	clear_locks
}

killthis_window() {
	kill $(cat ./tmp/firefox.pid)
}

# a real global variable
PAUSE_LOCK="./tmp/pause.todo"
# Right now, use ${PAUSE_LOCK##*/} to remove path
#

pause_firestone_bot() {
	schedule_task ${PAUSE_LOCK##*/}
}

continue_firestone_bot() {
	remove_task ${PAUSE_LOCK##*/}
}

# another global variable
STOP_LOCK="./tmp/stop.todo"

# non cancelable
stop_firestone_bot() {
	schedule_task ${PAUSE_LOCK##*/}
	schedule_task ${STOP_LOCK##*/}
}
