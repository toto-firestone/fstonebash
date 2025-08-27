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
