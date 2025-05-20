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
	compare -metric NCC $img1 $img2 null 2> /tmp/ncc.txt
	local comp_out=$(cat /tmp/ncc.txt)
	echo "$comp_out"
}

