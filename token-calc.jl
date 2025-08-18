#
# Calculates token spent in several things
# - War machines
# - Personal tree
#

struct WarMachine
	name
	level
	xp_bar
end

function wm_token_value(wm; verbose=true)
	n_token = 0
	i_level = 1
	i_xp_bar = 0
	i_xp_thresh = 100

	if verbose
		println("*** leveling up $(wm.name) from 1 to $(wm.level)")
	end
	while i_level < wm.level
		i_spend = 0
		while i_xp_bar < i_xp_thresh
			i_spend += 1
			n_token += 500
			i_xp_bar += 100
		end
		i_cost = 500*i_spend
		# level up done : refresh xp bar value
		i_xp_bar -= i_xp_thresh

		if verbose
			println("** leveling up from $(i_level) to $(i_level+1)")
			println("* spend $(i_spend) times 500 tokens = $(i_cost)")
			println("* extra xp in bar = $(i_xp_bar)")
		end

		i_level += 1
		# next threshold
		i_xp_thresh += 10
	end

	if verbose
		println("*** raise current level xp bar to $(wm.xp_bar)")
	end
	i_spend = 0
	while i_xp_bar < wm.xp_bar
		i_spend += 1
		n_token += 500
		i_xp_bar += 100
	end
	if verbose
		println("** final xp bar at $(i_xp_bar) / $(i_xp_thresh)")
		println("** spent $(n_token) on $(wm.name)")
	end

	return n_token
end

function any_wm_value(lvl)
	a = WarMachine("any",lvl,0)

	return wm_token_value(a,verbose=false)
end

function all_wm_token_value(wm_list)
	t = [wm_token_value(w,verbose=false) for w in wm_list]
	s = sum(t)
	println("** WM list :")
	for w in wm_list
		println("* ",w)
	end
	println("** total token value = $(s)")

	return s
end

#### #### ####

function ptree_node_cumcost(n_level; verbose=true)
	i_level = 0
	i_cost = 600
	n_cost = 0

	while i_level < n_level
		if verbose
			println("* ptree $(i_level) to $(i_level+1)")
			println("* cost = $(i_cost)")
		end
		n_cost += i_cost
		i_level += 1
		i_cost += 100
	end

	return n_cost
end

# TO BE COPY PASTED IN DATA FILE
EMPTY_PTREE_TEMPLATE = Dict{String,Int}(
	# 8 nodes on center
	"ptree_Miner" => 0,
	"ptree_BattleCry" => 0,
	"ptree_AllMainAttributes" => 0,
	"ptree_Prestigious" => 0,
	"ptree_FirestoneEffect" => 0,
	"ptree_RainingGold" => 0,
	"ptree_HeroLevelUpCost" => 0,
	"ptree_GuardianPower" => 0,
	# 6 nodes on left side
	"ptree_AttributeDamage" => 0,
	"ptree_AttributeHealth" => 0,
	"ptree_AttributeArmor" => 0,
	"ptree_EnergyHeroes" => 0,
	"ptree_ManaHeroes" => 0,
	"ptree_RageHeroes" => 0,
	# 6 nodes on right side
	"ptree_FistFight" => 0,
	"ptree_Precision" => 0,
	"ptree_MagicSpells" => 0,
	"ptree_TankSpecialization" => 0,
	"ptree_DamageSpecialization" => 0,
	"ptree_HealerSpecialization" => 0,
);

function all_ptree_node_cost(ptree)
	costs = [ ptree_node_cumcost(n,verbose=false) for (k,n) in ptree]
	s = sum(costs)

	println("** Ptree nodes list :")
	for (k,v) in ptree
		i_cost = ptree_node_cumcost(v,verbose=false)
		println("* $(k) level $(v) => $(i_cost) tokens")
	end
	println("** Ptree total cost : $(s)")

	return s
end

function get_token_count_filename()
	serv_str = read(`cat switch.conf`,String)
	serv_reg = r"^current_servname=(\w+)$"
	m_serv = match(serv_reg,serv_str)

	serv_name = m_serv.captures[1]
	serv_file = "./tmp/$(serv_name).token-spend.jl"

	return serv_file
end

token_spend_file = get_token_count_filename()
println("*** loading $(token_spend_file)")
include(token_spend_file)

#### #### #### #####
### WM operators ###
#### #### #### #####

function new_wm(name)
	n = WarMachine(name,1,0)
	wm_token_value(n)

	return n
end

function wm_level_up_once(wm)
	curr_lev = wm.level
	curr_xp_bar = wm.xp_bar
	xp_thresh = 100 + (curr_lev-1)*10

	while curr_xp_bar < xp_thresh
		curr_xp_bar += 100
	end
	curr_xp_bar -= xp_thresh
	n = WarMachine(wm.name,curr_lev+1,curr_xp_bar)

	return n
end

function wm_level_up(wm,n_times)
	nw = wm
	for i in 1:n_times
		nw = wm_level_up_once(nw)
	end

	return nw
end

function wm_display_info(wm)
	println("** WM name : ",wm.name)
	println("* level : ",wm.level)
	println("* xp bar : ",wm.xp_bar," / ",100 + (wm.level-1)*10)
	println("*")
end
