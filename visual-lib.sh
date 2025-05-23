# this one can remain non executable
# use it with source visual-lib.sh

### ### ### ### ### ###
### BASIC FUNCTIONS ###
### ### ### ### ### ###

screenshot() {
	import -window root /tmp/shot.png
	#echo "* screenshot at /tmp/shot.png"
}

make_ROI() {
	screenshot
	local x_min=$1
	local y_min=$2
	local x_max=$3
	local y_max=$4
	local roi_file=$5
	local w_roi=$((x_max-x_min))
	local h_roi=$((y_max-y_min))
	local geom="${w_roi}x${h_roi}+${x_min}+${y_min}"
	#echo "* ROI is rectangle $geom"

	convert /tmp/shot.png -crop $geom $roi_file
}

ncc_similarity() {
	local img1=$1
	local img2=$2
	if [ ! -f "$img1" ] || [ ! -f "$img2" ]; then
		echo "0"
		return
	fi
	compare -metric NCC $img1 $img2 null: 2> /tmp/ncc.txt
	local comp_out=$(cat /tmp/ncc.txt)
	echo "$comp_out"
}


### ### ### ### ### ####
### GLOBAL VARIABLES ###
### ### ### ### ### ####

# Should not be here, but right now it's OK

x_irongard_ul=501
y_irongard_ul=176
x_irongard_br=881
y_irongard_br=215

x_url_ul=258
y_url_ul=73
x_url_br=1123
y_url_br=103

start_ref_pic="./tmp/start-ref.png"
x_startref_ul=72
y_startref_ul=699
x_startref_br=109
y_startref_br=732


#### ### ### ### ####
### VISUAL CHECKS ###
#### ### ### ### ####

test_freeze() {
	focus_and_back_to_root_screen
	make_ROI $x_irongard_ul $y_irongard_ul $x_irongard_br $y_irongard_br /tmp/test_freeze_root.png

	go_to_town
	make_ROI $x_irongard_ul $y_irongard_ul $x_irongard_br $y_irongard_br /tmp/test_freeze_town.png

	local ncc=$(ncc_similarity /tmp/test_freeze_root.png /tmp/test_freeze_town.png)

	focus_and_back_to_root_screen

	local compare=$(echo "$ncc > 0.5" | bc -l)
	log_msg "* test freeze $1 : ncc=$ncc freeze=$compare"
}


### ### ### ### ### ###
### ROBUST COMMANDS ###
### ### ### ### ### ###

safe_quit() {
	make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/before_quit.png

	local i_try=1
	echo "* quit - attempt $i_try"
	./firestone-quit.sh
	make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/after_quit.png
	local ncc=$(ncc_similarity /tmp/before_quit.png /tmp/after_quit.png)
	local compare=$(echo "$ncc > 0.5" | bc -l)
	log_msg "* quit attempt $i_try : ncc=$ncc fail=$compare"

	while [ "$compare" != "0" ]; do
		i_try=$((i_try+1))
		echo "* quit - attempt $i_try"
		./firestone-quit.sh
		make_ROI $x_url_ul $y_url_ul $x_url_br $y_url_br /tmp/after_quit.png

		ncc=$(ncc_similarity /tmp/before_quit.png /tmp/after_quit.png)
		compare=$(echo "$ncc > 0.5" | bc -l)
		log_msg "* quit attempt $i_try : ncc=$ncc fail=$compare"
	done
	echo "* quit successful"
}

init_start_ref_picture() {
	make_ROI $x_startref_ul $y_startref_ul $x_startref_br $y_startref_br $start_ref_pic
}

# does not make sense to retry forever
# just don't let the bot play on nothing
# wait for human intervention after a timeout
# or let it go if 3rd argument is provided
wait_game_start() {
	local n_try=$1
	local t_interval=$2
	if [ -z "$3" ]; then
		echo "** blocking wait **"
		log_msg "** blocking wait **"
	else
		echo "** non-blocking wait **"
		log_msg "** non-blocking wait **"
	fi

	local i_check=1
	local ncc=0
	local compare=0
	while [ "$i_check" -le "$n_try" ]; do
		sleep $t_interval
		echo "* check $i_check"
		make_ROI $x_startref_ul $y_startref_ul $x_startref_br $y_startref_br /tmp/start-check.png

		ncc=$(ncc_similarity /tmp/start-check.png $start_ref_pic)
		compare=$(echo "$ncc > 0.5" | bc -l)
		if [ "$compare" == "1" ]; then
			log_msg "* start check $i_check/$n_try : ncc=$ncc success=$compare"
			return
		else
			echo "* wait $t_interval more sec."
		fi
		i_check=$((i_check+1))
	done
	# NOT REACHED IF SUCCESS
	local dummy=""
	log_msg "* start failed ($i_check/$n_try) : ncc=$ncc success=$compare"
	echo
	if [ -z "$3" ]; then
		echo "*** There is a problem : human intervention required ***"
		read -p "stop with CTRL+C or continue with RETURN " dummy
		log_msg "* human intervention now"
	else
		echo "*** There is a problem : further action is required ***"
	fi
}
