# this one can remain non executable
# use it with source visual-lib.sh

### ### ### ### ### ###
### BASIC FUNCTIONS ###
### ### ### ### ### ###

screenshot() {
	import -window root /tmp/shot.png
	echo "* screenshot at /tmp/shot.png"
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
	echo "* ROI is rectangle $geom"

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
