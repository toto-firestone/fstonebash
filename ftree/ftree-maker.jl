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

TEST_CASE_SYNTAX = """
1 - How to write Ftree input

Numbers of node per column
#
tst_case_prof = [3, 2, 1, 1, 2, 2, 2, 3];
####

Tree number, just for naming
#
tst_case_id = 2;
####

Max levels for each node
#
tst_case_max = [20, 50, 40, 15, 15, 30, 30, 50, 15, 50, 15, 50, 50, 30, 30, 30];
####

Use triplets for unlock equirement. Extra values are not used.
For instance, when wiki says all nodes in column N must have level 4,
it doesn't say how many. Then we always provide 3 values.
When it says 6/5, we know there are only 2 nodes. Third value can be 0.
When it says 6/4/4, the is no ambiguity.
#
tst_case_unlock = [(6,4,4), (5,5,5), (6,6,6), (4,4,4), (5,5,5), (6,5,0), (10,10,10)];
####


2 - How to do testing in case of bugs

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
		error("max level array length is not 16")
	end
	if length(u_levels) != 7
		error("unlock level array length is not 7")
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

		if u_lvl > m_lvl
			error("* unlock level > max at node $n_node")
		end
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
	if n_col < 1 || n_col > 8
		# column out of range
		return 3
	end


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
trick_case_prof = [1, 3, 2, 1, 1, 3, 2, 3];
trick_case_id = 0;
trick_case_max = [5, 7, 6, 7, 6, 6, 30, 30, 50, 15, 50, 15, 50, 52, 30, 30];
###############     #       #     #  #  #        #     #
trick_case_max = [5, 5, 6, 9, 6, 7, 6, 5, 7, 7, 7, 5, 8, 5, 5, 5];
####################   1          2       3       4         5        6       7
trick_case_unlock = [(4,4,4), (3,4,7), (6,7,5), (5,6,6), (4,4,4), (3,5,7), (5,6,4)];

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
	if ! detect_last_solo_node(node_info,levels)
		error("* cannot use last_solo_node_n without caution")
	end
	max_levels = [ z.max_lvl for z in node_info ]
	rooms = max_levels - levels

	return findfirst(x -> x > 0,rooms)
end

function fill_ftree_queues(node_info)
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

# require another file for improving that huge function
include("fill-advanced.jl")

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

function write_ftree_and_queues(profile,id,max_levels,unlock_levels)
	node_info = init_ftree(profile,id,max_levels,unlock_levels)
	ftree_q, levels_chk = fill_ftree_queues(node_info)
	print_complete_node_info(node_info,levels_chk)

	# debug purpose only
	for i_q in 1:9
		println(i_q," : ",ftree_q[i_q])
	end

	q_unlock_out = "out.queue-unlock.todo"
	q_fill_out = "out.queue-fill.todo"

	open(q_unlock_out,"w") do q_fd
		for n in 1:8
			if isempty(ftree_q[n])
				continue
			end
			q_str = join(ftree_q[n],"\n")*"\n"
			write(q_fd,q_str)
		end
	end
	if isempty(ftree_q[9])
		println("* filling not required. already filled after unlock")
	else
		open(q_fill_out,"w") do q_fd
			q_str = join(ftree_q[9],"\n")*"\n"
			write(q_fd,q_str)
		end
	end
end

function write_ftree_and_queues_V2(profile,id,max_levels,unlock_levels)
	node_info = init_ftree(profile,id,max_levels,unlock_levels)
	ftree_q, levels_chk = advanced_fill_ftree_queues(node_info)
	print_complete_node_info(node_info,levels_chk)

	# debug purpose only
	for i_q in 1:9
		println(i_q," : ",ftree_q[i_q])
	end

	q_unlock_out = "out.queue-unlock.todo"
	q_fill_out = "out.queue-fill.todo"

	open(q_unlock_out,"w") do q_fd
		for n in 1:8
			if isempty(ftree_q[n])
				continue
			end
			q_str = join(ftree_q[n],"\n")*"\n"
			write(q_fd,q_str)
		end
	end
	if isempty(ftree_q[9])
		println("* filling not required. already filled after unlock")
	else
		open(q_fill_out,"w") do q_fd
			q_str = join(ftree_q[9],"\n")*"\n"
			write(q_fd,q_str)
		end
	end
end

FINAL_USAGE_TXT = """
3 - Final usage

Use this function
#
write_ftree_and_queues(profile,id,max_levels,unlock_levels)
###

Output files are in same directory

- out.ftree-maker.dat : contains the ftree descriptor.
Rename it to s*.ftree.dat so that auto-ftree.sh script can find it

- out.queue-unlock.todo : contains queue for unlocking all columns
- out.queue-fill.todo : contains the queue for filling until the end
Rename the to s*.ftreestart.todo so that auto-ftree.sh script can find them
It's possible to merge the 2 files with cat command
"""

println(FINAL_USAGE_TXT)
