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

struct PtreeNode
	name
	level
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
