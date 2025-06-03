#!/bin/bash

print_node_info() {
	local node_number=$1
	local attributes="name levelMax levelCurr unlockReq pageNumber columnIndex slotKind slotIndex"

	echo "** NODE $node_number **"
	for attr in $attributes; do
		local var_name="FtreeNode_${node_number}_$attr"
		echo "$var_name=$(get_node_attribute $node_number $attr)"
	done
}
