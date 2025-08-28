
function old_fill_ftree_queues(node_info)
	ftree_q = init_ftree_queue()
	levels = zeros(Int,16)

	# ############################################################# #
	#
	# unlock each column from 1 to 7
	#
	# ############################################################# #
	for n_col in 1:7
		println("\n** filling column $n_col")
		cc = select_nodes_eq_column(node_info,n_col)
		if length(cc) > 1
			##
			## 2 or more nodes per column
			##
			cycle_len = length(cc)
			n_add = 0
			cycle_count = 0
			last_node = 0
			while ! check_column_requirement(cc,levels)
				i_cycle = (cycle_count % cycle_len) +1
				cycle_count += 1
				up_node = cc[i_cycle]
				up_node_n = up_node.n_node

				ierr = add_to_queue_std!(ftree_q,levels,
					node_info,up_node_n)

				if ierr == 2
					# column requirement not satisfied
					# should try next without adding
					println("* ierr=2 caught on node $up_node_n")
					continue
				elseif ierr != 0
					error("add_to_queue_std! failed with error $ierr")
				else
					n_add += 1
					last_node = up_node_n
				end
			end
			## at this point double node in 2 consecutive
			## spots in queue are possible
			## this issue will be solved later
			## directly on queue
			println("* upgraded $n_add nodes in column $n_col")

			if (n_add % 2) != 0
				println("* 1 parity padding required")
				println("* not giving priority to current column")
				alt = select_nodes_le_column(node_info,n_col)
				# exclude last queued node
				filter!(z->(z.n_node!=last_node),alt)
				pad_node = argmin_level_in_node_subset(alt,
					levels)

				if pad_node == 0
					println("* parity padding not found anywhere")
					# no more room, no choice
					println("* forced to do padding with zero on column $n_col")
					push!(ftree_q[n_col],0)
				else
					println("* parity padding with node $pad_node")
					up_node = node_info[pad_node]
					up_node_n = up_node.n_node

					ierr = add_to_queue_std!(ftree_q,
						levels,node_info,up_node_n,
						solo_pad_col=n_col)

					if ierr != 0
						error("add_to_queue_std! failed with error $ierr during parity padding")
					end
					n_add += 1
				end
			else
				println("* no parity padding required")
			end
			##
			##
			##
		elseif length(cc) == 1
			##
			## only 1 node per column
			##
			pool = select_nodes_le_column(node_info,n_col-1)

			solo_node = cc[1]
			solo_n = solo_node.n_node
			n_req = solo_node.unlock_lvl

			for i_up in 1:n_req
				ierr = add_to_queue_std!(ftree_q,levels,
					node_info,solo_n)

				if ierr != 0
					error("add_to_queue_std! failed with error $ierr during solo column processing")
				end

				pad_node = argmin_level_in_node_subset(pool,
					levels)
				println("* padding solo node $solo_n with $pad_node")

				if pad_node == 0
					push!(ftree_q[n_col],0)
				else
					ierr = add_to_queue_std!(ftree_q,
						levels,node_info,pad_node,
						solo_pad_col=n_col)

					if ierr != 0
						error("add_to_queue_std! failed with error $ierr during solo column padding")
					end
				end
			end
			##
			##
			##
		else
			error("cannot fill an empty column")
		end
	end

	# ############################################################# #
	#
	# handle column 8
	#
	# ############################################################# #
	println("\n** filling column 8")
	cc = select_nodes_eq_column(node_info,8)
	pool = select_nodes_le_column(node_info,7)
	min_node = argmin_level_in_node_subset(pool,levels)

	if length(cc) <= 1
		## Last column is a solo
		## will not handle this case
		## never happens
		error("* solo column 8 not handled because should never happen")
	end
	# NOT REACHED IF SOLO COLUMN 8 DETECTED

	if min_node == 0
		println("* no more room in columns 1 to 7")
		println("* only column 8 has room")
		println("* skip to final fill stage")
	else
		v_lvl = [ z.max_lvl for z in cc ]
		push!(v_lvl,levels[min_node])
		# smallest max level of column 8
		# vs smallest level of columns 1 to 7
		ref_lvl = minimum(v_lvl)
		# the smallest of those values is reachable on whole column 8
		println("* select $ref_lvl in ",v_lvl)

		# distribute ref_lvl to both nodes of column 8
		n_lvl_up_min = ref_lvl * length(cc)

		# check room in column 8
		total_node_col8 = sum([ z.max_lvl for z in cc ])

		println("* going to queue $n_lvl_up_min nodes for column 8")
		println("* total room in column 8 is $total_node_col8")
		if n_lvl_up_min > total_node_col8
			error("* not enough room in column 8")
		end
		##
		## if length(cc) > 1 : guaranteed
		## 2 or more nodes per column
		##
		## n_lvl_up_min <= total_node_col8 : guaranteed
		##
		n_add = 0
		last_q = 0
		cycle_len = length(cc)
		while n_add < n_lvl_up_min
			i_cycle = (n_add % cycle_len) +1
			up_node = cc[i_cycle]
			up_node_n = up_node.n_node

			ierr = add_to_queue_std!(ftree_q,levels,
				node_info,up_node_n)

			## there is no unlock constraint here
			## all is guaranteed to be feasible
			## there is no point in catching ierr=2
			## no need to skip any non feasible
			if ierr != 0
				error("add_to_queue_std! failed with error $ierr")
			end
			n_add += 1
			last_q = up_node_n
		end
		println("* upgraded $n_add nodes in column 8")

		if (n_add % 2) != 0
			println("* 1 parity padding required")
			println("* not giving priority to current column")
			# using whole set as pool but remove last queued
			alt = filter(z->(z.n_node!=last_q),node_info)
			pad_node = argmin_level_in_node_subset(alt,levels)

			if pad_node == 0
				println("* parity padding not found anywhere")
				# no more room, no choice
				println("* forced to do padding with zero on column $n_col")
				push!(ftree_q[8],0)
			else
				up_node = node_info[pad_node]
				up_node_n = up_node.n_node

				ierr = add_to_queue_std!(ftree_q,levels,
					node_info,up_node_n,solo_pad_col=8)

				if ierr != 0
					error("add_to_queue_std! failed with error $ierr during parity padding")
				end
				println("* parity padding with $up_node_n")
				n_add += 1
			end
		else
			println("* no parity padding required")
		end
		##
		##
		##
	end

	# ############################################################# #
	#
	# intermediate check
	#
	# ############################################################# #
	q_sizes = [ length(q) for q in ftree_q ]
	n_node_q = sum(q_sizes)
	println("\n\n*** $n_node_q nodes in queues at the end of unlock stage")

	if (n_node_q % 2) != 0
		error("* parity check failed after unlock stage")
	else
		println("* parity check passed after unlock stage")
	end

	#
	# WARNING : queue contains 0 that do no count as node
	#
	q_n_zeros = sum([ length(filter(x->(x==0),q)) for q in ftree_q ])
	println("* found $q_n_zeros zeros in queues")
	q_n_nonzeros = n_node_q - q_n_zeros

	total_nodes = sum([ z.max_lvl for z in node_info ])
	total_done = sum(levels)

	if total_done != q_n_nonzeros
		error("* non zeros in queues ($q_n_nonzeros) does not matches number of nodes done ($total_done) after unlock stage")

	else
		println("* non zeros in queue check passed after unlock stage")
	end

	println("** $total_done / $total_nodes non zero nodes queued")
	n_remain = total_nodes - total_done
	println("** finish the $n_remain remaining nodes")

	# ############################################################# #
	#
	# fill till the end + parity padding
	#
	# ############################################################# #
	println("\n** filling all remaining")
	if n_remain <= 0
		println("** nothing to do")
	elseif n_remain == 1
		for i_try in 1:16
			ierr = add_to_queue_std!(ftree_q,levels,
				node_info,i_try,solo_pad_col=9)
			if ierr == 0
				println("* last node is $i_try")
			end
		end
		# only 1 node is ok for the last command
		###################################
		# THIS WILL BREAK PARITY ON QUEUE #
		###################################
		# only queue 9 can be odd
	else
		# n_remain >= 2
		n_add = 0
		i_count = 0
		last_q = 0

		while ! detect_last_solo_node(node_info,levels)
			i_cycle = i_count % 16
			n_try = i_cycle +1

			ierr = add_to_queue_std!(ftree_q,levels,
				node_info,n_try,solo_pad_col=9)
			if ierr == 0
				n_add += 1
				last_q = n_try
				# if the next doable node is the same...
				# then all nodes in between are full
				# so last solo node detection makes sense
			end
			i_count += 1
		end

		solo_n = last_solo_node_n(node_info,levels)
		println("* last solo node is $solo_n")
		if solo_n != last_q
			# add one before parity check
			println("* add a solo node before parity check")
			ierr = add_to_queue_std!(ftree_q,levels,
				node_info,solo_n,solo_pad_col=9)
			if ierr != 0
				error("* add_to_queue_std! failed : last solo node must have room")
			end
			n_add += 1

		end

		# need to check parity before adding more
		if n_add % 2 != 0
			println("* need parity padding before rushing to the end of last solo node")

			push!(ftree_q[9],0)
			# padding with 0 does no count
		end

		###
		### Final rush : solo node and 0 padding
		###
		println("\n** final rush on last solo node $solo_n")
		while n_add < n_remain
			ierr = add_to_queue_std!(ftree_q,levels,
				node_info,solo_n,solo_pad_col=9)
			if ierr != 0
				error("* add_to_queue_std! failed : last solo node must have room during final fill")
			end
			n_add += 1

			push!(ftree_q[9],0)
			# padding with 0 does no count
		end
	end

	# ############################################################# #
	#
	# final check
	#
	# ############################################################# #
	q_sizes = [ length(q) for q in ftree_q ]
	n_node_q = sum(q_sizes)
	println("*** $n_node_q nodes in queues at the end of fill stage")

	q_n_zeros = sum([ length(filter(x->(x==0),q)) for q in ftree_q ])
	println("* found $q_n_zeros zeros in queues")
	q_n_nonzeros = n_node_q - q_n_zeros

	total_nodes = sum([ z.max_lvl for z in node_info ])
	total_done = sum(levels)

	if total_done != q_n_nonzeros
		error("* non zeros in queues ($q_n_nonzeros) does not matches number of nodes done ($total_done) after fill stage")

	else
		println("* non zeros in queue check passed after unlock stage")
	end

	println("** $total_done / $total_nodes non zero nodes queued")
	n_remain = total_nodes - total_done
	if n_remain != 0
		error("* there are $n_remain remaining nodes at the end")
	else
		println("* $n_remain remaining nodes at the end")
	end

	println("** check queue values for each node 1...16")
	for n in 1:16
		q_n = sum([ length(filter(x->(x==n),q)) for q in ftree_q ])
		c_n = node_info[n].max_lvl
		if q_n == c_n
			println("* node $n check : $q_n / $c_n")
		else
			error("* node $n mismatch : $q_n / $c_n")
		end
	end
	println("** all nodes in queue match all max levels")

	return ftree_q, levels
end
