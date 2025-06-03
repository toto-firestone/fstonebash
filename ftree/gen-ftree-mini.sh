#!/bin/bash

Ftree_profile=$1
chk_sum=0
chk_cols=0
for n_slot in $Ftree_profile; do
	chk_sum=$((chk_sum+n_slot))
	chk_cols=$((chk_cols+1))
done
if [ "$chk_sum" -ne "16" ] || [ "$chk_cols" -ne "8" ]; then
	echo "** Invalid Ftree profile"
	exit
fi

echo "# Ftree profile : $Ftree_profile ($chk_sum nodes / $chk_cols columns)"
echo 'FtreeGlob_name="Ftree "'
echo "FtreeGlob_time=2"
echo "FtreeGlob_currPage=1"
echo

print_node_empty_info() {
	local node_number=$1
	local attributes="name levelMax levelCurr unlockReq"

	for attr in $attributes; do
		local var_name="FtreeNode_${node_number}_$attr"
		echo "$var_name="
	done
}


chk_cols=0
chk_node=0
for n_slot in $Ftree_profile; do
	i_col=$chk_cols
	chk_cols=$((chk_cols+1))
	if [ "$chk_cols" -le "4" ]; then
		i_page=1
	else
		i_page=2
	fi

	i_slot=0
	while [ "$i_slot" -lt "$n_slot" ]; do
		chk_node=$((chk_node+1))
		print_node_empty_info $chk_node
		echo "FtreeNode_${chk_node}_pageNumber=$i_page"
		echo "FtreeNode_${chk_node}_columnIndex=$i_col"
		echo "FtreeNode_${chk_node}_slotKind=$n_slot"
		echo "FtreeNode_${chk_node}_slotIndex=$i_slot"
		echo

		i_slot=$((i_slot+1))
	done
done
