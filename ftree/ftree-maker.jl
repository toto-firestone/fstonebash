#
# A complete tool for generating ftree description file and
# batch queue file ftreestart.todo
#
# It is intended to be used in remote ssh connection scenario
# We have no way to see the game screen
#
# The remote device can only run basic command line tools through ssh
# and get information on fandom wiki about tree shape and unlock pattern
#

struct FtreeNode
	n_node
	unlock_lvl
	max_lvl
	# there is no current level field because of non mutable behaviour
	n_page
	i_col
	n_slot
	i_slot
end
# all indexes i start at 1. will require translation to indexes starting at 0

tst_case_prof = [3, 2, 1, 1, 2, 2, 2, 3];
tst_case_id = 2;
tst_case_max = [20, 50, 40, 15, 15, 30, 30, 50, 15, 50, 15, 50, 50, 30, 30, 30];
tst_case_unlock = [(6,4,4), (5,5,5), (6,6,6), (4,4,4), (5,5,5), (6,5,0), (10,10,10)];

TEST_CASE_SYNTAX="""
tst_case_prof = [3, 2, 1, 1, 2, 2, 2, 3];
tst_case_id = 2;
tst_case_max = [20, 50, 40, 15, 15, 30, 30, 50, 15, 50, 15, 50, 50, 30, 30, 30];
tst_case_unlock = [(6,4,4), (5,5,5), (6,6,6), (4,4,4), (5,5,5), (6,5,0), (10,10,10)];

t = init_ftree(tst_case_prof,tst_case_id,tst_case_max,tst_case_unlock);
q,l = fill_ftree_queues(tst_info)
print_complete_node_info(tst_info,l)
"""

function check_profile(prof)
	check1 = (length(prof) == 8 && sum(prof) == 16)
	check2 = all(x->(x >= 1 && x <= 3),prof)
	return check1 && check2
end

function init_with_profile_and_id(prof,ftree_id)
	if ! check_profile(prof)
		error("bad ftree profile : $prof")
	end
	# NOT REACHED IF BAD PROFILE

	ftree_txt = ["# Ftree profile : $prof"]
	push!(ftree_txt,"FtreeGlob_name=\"Ftree $ftree_id\"")
	push!(ftree_txt,"FtreeGlob_time=2")
	push!(ftree_txt,"FtreeGlob_currPage=1")
	push!(ftree_txt,"#########")

	struct_info = fill((0,0,0,0),16)
	k = 0
	for i_p in 1:8
		if i_p <= 4
			n_page = 1
		else
			n_page = 2
		end
		i_col = i_p - 1
		n_slot = prof[i_p]

		for j_s in 1:n_slot
			k += 1
			i_slot = j_s -1
			struct_info[k] = (n_page,i_col,n_slot,i_slot)
		end
	end
	println("* processed $k nodes")

	return ftree_txt, struct_info
end

function init_with_max_and_unlocks(st_info,m_levels,u_levels)
	if length(m_levels) != 16
		error("max level array lenght is not 16")
	end
	if length(u_levels) != 7
		error("unlock level array lenght is not 7")
	end
	if length(u_levels[7]) != 3
		error("unlock level description must be 3-tuple")
	end

	# NOT REACHED IF INPUT SIZES MISMATCH

	z = FtreeNode(0,0,0,0,0,0,0)
	node_info = fill(z,16)

	for n_node in 1:16
		n_page,i_col,n_slot,i_slot = st_info[n_node]
		m_lvl = m_levels[n_node]

		n_col = i_col + 1
		k_slot = i_slot + 1
		if n_col <= 7
			u_3 = u_levels[n_col]
		else
			u_3 = (0,0,0)
		end
		u_lvl = u_3[k_slot]

		z = FtreeNode(n_node,u_lvl,m_lvl,n_page,i_col,n_slot,i_slot)
		node_info[n_node] = z
	end

	return node_info
end

function init_ftree(prof,ftree_id,m_levels,u_levels)
	ftree_txt, st_info = init_with_profile_and_id(prof,ftree_id)
	node_info = init_with_max_and_unlocks(st_info,m_levels,u_levels)

	save_col = 0
	for k in 1:16
		z = node_info[k]
		var_pref = "FtreeNode_$(z.n_node)_"
		push!(ftree_txt,var_pref*"name=\"node$(z.n_node)\"")
		push!(ftree_txt,var_pref*"levelMax=$(z.max_lvl)")
		push!(ftree_txt,var_pref*"levelCurr=0")
		push!(ftree_txt,var_pref*"unlockReq=$(z.unlock_lvl)")
		push!(ftree_txt,var_pref*"pageNumber=$(z.n_page)")
		push!(ftree_txt,var_pref*"columnIndex=$(z.i_col)")
		push!(ftree_txt,var_pref*"slotKind=$(z.n_slot)")
		push!(ftree_txt,var_pref*"slotIndex=$(z.i_slot)")
		if k == 16
			push!(ftree_txt,"#########")
		elseif node_info[k+1].i_col > save_col
			push!(ftree_txt,"#########")
			save_col += 1
		else
			push!(ftree_txt,"###")
		end
	end

	ftree_str = join(ftree_txt,"\n")*"\n"
	ftree_out = "out.ftree-maker.dat"
	open(ftree_out,"w") do ft_fd
		write(ft_fd,ftree_str)
	end
	println("** Ftree writen in $ftree_out **")

	return node_info
end

println("*** Input syntax example :")
println(TEST_CASE_SYNTAX)

function select_nodes_eq_column(node_info,n_col)
	i_col = n_col - 1
	s = filter(z->(z.i_col==i_col),node_info)
	return s
end

function select_nodes_le_column(node_info,n_col)
	i_col = n_col - 1
	s = filter(z->(z.i_col<=i_col),node_info)
	return s
end

function init_ftree_queue()
	ftree_q = Any[]
	for i in 1:9
		single_q = Int[]
		push!(ftree_q,single_q)
	end

	return ftree_q
end

function add_to_queue_unlock!(ftree_q,levels,node_info,n_node; solo_pad_col=0)
	## Error checks
	if n_node < 1 || n_node > 16
		# out of range
		return 1
	end

	curr_lvl = levels[n_node]
	curr_node = node_info[n_node]
	if curr_lvl >= curr_node.max_lvl
		# max level reached
		return 2
	end

	n_col = curr_node.i_col + 1
	if n_col < 1 || n_col > 7
		# unlock stage can only fill columns 1 to 7
		return 3
	end

	if solo_pad_col < 0 || solo_pad_col > 7
		# solo padding in unlock stage cannot be at column 8+
		return 4
	end

	# NOT REACHED IF ERROR FOUND
	if solo_pad_col == 0
		push!(ftree_q[n_col],n_node)
	else
		push!(ftree_q[solo_pad_col],n_node)
	end
	levels[n_node] += 1

	return 0
end

function add_to_queue_std!(ftree_q,levels,node_info,n_node; solo_pad_col=0)
	## Error checks
	if n_node < 1 || n_node > 16
		# out of range
		return 1
	end

	curr_lvl = levels[n_node]
	curr_node = node_info[n_node]
	if curr_lvl >= curr_node.max_lvl
		# max level reached
		return 2
	end

	n_col = curr_node.i_col + 1

	if solo_pad_col < 0 || solo_pad_col > 9
		# solo padding column out of range (0 is no padding)
		# value 9 is for ftree finish
		return 4
	end

	# NOT REACHED IF ERROR FOUND
	if solo_pad_col == 0
		push!(ftree_q[n_col],n_node)
	else
		push!(ftree_q[solo_pad_col],n_node)
	end
	levels[n_node] += 1

	return 0
end

### testing data initialization here
#tst_info = init_ftree(tst_case_prof,tst_case_id,tst_case_max,tst_case_unlock);
#tst_q = init_ftree_queue();
#tst_levels = zeros(Int,16);

function check_column_requirement(node_subset,levels)
	for nn in node_subset
		n_node = nn.n_node
		if levels[n_node] < nn.unlock_lvl
			return false
		end
	end

	return true
end

### tricky test case
trick_case_prof = [1, 3, 2, 1, 1, 3, 3, 2];
trick_case_id = 0;
trick_case_max = [5, 7, 6, 7, 6, 6, 30, 30, 50, 15, 50, 15, 50, 52, 30, 30];
trick_case_unlock = [(4,4,4), (6,4,4), (6,5,5), (25,6,6), (4,4,4), (6,5,5), (6,5,4)];

function filter_upgradeble_node_subset(node_pool,levels)
	r = FtreeNode[]
	for z in node_pool
		i_node = z.n_node
		lvl_limit = z.max_lvl
		lvl = levels[i_node]
		if lvl < lvl_limit
			push!(r,z)
		end
	end

	return r
end

function argmin_level_in_node_subset(node_pool,levels)
	node_pool_r = filter_upgradeble_node_subset(node_pool,levels)

	if isempty(node_pool_r)
		i_node_min = 0
	else
		i_node_min = node_pool_r[1].n_node
		lvl_min = levels[i_node_min]
		for z in node_pool_r
			i_node = z.n_node
			lvl = levels[i_node]
			if lvl < lvl_min
				i_node_min = i_node
				lvl_min = lvl
			end
		end
	end

	return i_node_min
end

function detect_last_solo_node(node_info,levels)
	max_levels = [ z.max_lvl for z in node_info ]
	rooms = max_levels - levels
	filter!(x -> x > 0,rooms)

	return length(rooms) == 1
end

function last_solo_node_n(node_info,levels)
	max_levels = [ z.max_lvl for z in node_info ]
	rooms = max_levels - levels

	return findfirst(x -> x > 0,rooms)
end

function fill_ftree_queues(node_info)
	ftree_q = init_ftree_queue()
	levels = zeros(Int,16)

	# unlock each column from 1 to 7
	for n_col in 1:7
		cc = select_nodes_eq_column(node_info,n_col)
		if length(cc) > 1
			##
			## 2 or more nodes per column
			##
			cycle_len = length(cc)
			n_add = 0
			while ! check_column_requirement(cc,levels)
				i_cycle = (n_add % cycle_len) +1
				up_node = cc[i_cycle]
				up_node_n = up_node.n_node

				ierr = add_to_queue_unlock!(ftree_q,levels,
					node_info,up_node_n)

				if ierr != 0
					error("add_to_queue_unlock! failed with error $ierr")
				end
				n_add += 1
			end
			println("* upgraded $n_add nodes in column $n_col")
			if (n_add % 2) != 0
				println("* 1 parity padding required")
				i_cycle = (n_add % cycle_len) +1
				up_node = cc[i_cycle]
				up_node_n = up_node.n_node

				ierr = add_to_queue_unlock!(ftree_q,levels,
					node_info,up_node_n)

				if ierr != 0
					error("add_to_queue_unlock! failed with error $ierr during parity padding")
				end
				n_add += 1
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
				ierr = add_to_queue_unlock!(ftree_q,levels,
					node_info,solo_n)

				if ierr != 0
					error("add_to_queue_unlock! failed with error $ierr during solo column processing")
				end

				pad_node = argmin_level_in_node_subset(pool,
					levels)
				println("* padding solo node $solo_n with $pad_node")

				solo_n_col = solo_node.i_col +1
				if pad_node == 0
					push!(ftree_q[solo_n_col],0)
				else
					ierr = add_to_queue_unlock!(ftree_q,
						levels,node_info,pad_node,
						solo_pad_col=solo_n_col)

					if ierr != 0
						error("add_to_queue_unlock! failed with error $ierr during solo column padding")
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

	#
	# handle column 8
	#
	cc = select_nodes_eq_column(node_info,8)
	pool = select_nodes_le_column(node_info,7)
	min_node = argmin_level_in_node_subset(pool,levels)

	if min_node == 0
		println("* no more room in columns 1 to 7")
		println("* only column 8 has room")
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
		if length(cc) > 1
			##
			## 2 or more nodes per column
			##
			n_add = 0
			cycle_len = length(cc)
			while n_add < n_lvl_up_min
				i_cycle = (n_add % cycle_len) +1
				up_node = cc[i_cycle]
				up_node_n = up_node.n_node

				ierr = add_to_queue_std!(ftree_q,levels,
					node_info,up_node_n)

				if ierr != 0
					error("add_to_queue_std! failed with error $ierr")
				end
				n_add += 1
			end
			println("* upgraded $n_add nodes in column 8")
			if (n_add % 2) != 0
				println("* 1 parity padding required")
				i_cycle = (n_add % cycle_len) +1
				up_node = cc[i_cycle]
				up_node_n = up_node.n_node

				ierr = add_to_queue_std!(ftree_q,levels,
					node_info,up_node_n)

				if ierr != 0
					error("add_to_queue_std! failed with error $ierr during parity padding")
				end
				n_add += 1
			else
				println("* no parity padding required")
			end
			##
			##
			##
		else
			## Last column is a solo
			## will not handle this case
			## never happens
			println("* solo column 8 not handled")
		end
	end

	# intermediate check
	q_sizes = [ length(q) for q in ftree_q ]
	n_node_q = sum(q_sizes)
	println("*** $n_node_q nodes in queues at the end of unlock stage")
	if (n_node_q % 2) != 0
		error("* parity check failed after unlock stage")
	else
		println("* parity check passed after unlock stage")
	end

	# fill till the end + parity padding
	max_levels = [ z.max_lvl for z in node_info ]
	total_nodes = sum(max_levels)
	#
	# WARNING : queue contains 0 that do no count as node
	#
	total_done = sum(levels)
	println("** $total_done / $total_nodes non zero nodes queued")
	n_remain = total_nodes - total_done
	println("** finish the $n_remain remaining nodes")

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

		while n_add < n_remain
			n_add += 1
		end
	end

	return ftree_q, levels
end

function print_complete_node_info(node_info,levels)
	for n_col in 1:8
		i_col = n_col - 1
		jj = findall(z->(z.i_col==i_col),node_info)
		for j in jj
			z = node_info[j]
			lvl = levels[j]
			i_str = "$(z.n_node) : "
			i_str = i_str * "lvl $(lvl)/$(z.max_lvl) "
			i_str = i_str * "(req. $(z.unlock_lvl)) "
			i_str = i_str * "n_page=$(z.n_page) "
			i_str = i_str * "i_col=$(z.i_col) "
			i_str = i_str * "n_slot=$(z.n_slot) "
			i_str = i_str * "i_slot=$(z.i_slot)"
			println(i_str)
		end
		if n_col < 8
			println("**")
		end
	end
end
