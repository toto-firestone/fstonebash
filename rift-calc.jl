## Initialisations ##

function init_state(n_guard)
	orb_lvl = zeros(Int,n_guard)

	return orb_lvl
end

## Complete state ##

function generic_incremental_values(orb_lvl,bval,incr)
	x = zeros(Float64,size(orb_lvl))
	for i in axes(orb_lvl,1)
		x[i] = bval * incr^orb_lvl[i]
	end

	return x
end

function damages(orb_lvl)
	return generic_incremental_values(orb_lvl,1000.0,1.05)
end

function next_level_costs(orb_lvl)
	return map(ceil,generic_incremental_values(orb_lvl,2000.0,1.13))
end

## Simulate Rift gameplay ##

function orb_reward(n_hit,orb_lvl)
	dmg = damages(orb_lvl)
	println("*** hits boss $n_hit times ***")
	println("* guardian levels : ",orb_lvl)
	println("* guardian damages : ",dmg)
	ddd = sum(dmg)
	println("* guardian total damage = $ddd")
	n_ddd = n_hit*ddd
	println("* total damage = $n_ddd")
	n_orb = floor(0.25*n_ddd)
	println("** gained $n_orb orbs")

	return n_orb
end

function find_optim_single_purchase(n_orb,orb_lvl,crit)
	cost_thrs = next_level_costs(orb_lvl)
	upgradables = cost_thrs .<= n_orb
	println("*** spend $n_orb orbs for a single upgrade ***")
	println("* guardian levels : ",orb_lvl)
	println("* next level costs : ",cost_thrs)
	println("* upradables : ",upgradables)
	println("* criterion : $crit")

	i_opt = 0
	up_cost = 0

	curr_dmg = damages(orb_lvl)
	potentials = zeros(size(curr_dmg))
	if crit == "max_damage"
		for i in axes(curr_dmg,1)
			if upgradables[i]
				dmg_incr = curr_dmg[i]*0.05
				potentials[i] = dmg_incr
			end
		end
	elseif crit == "min_cost"
		for i in axes(cost_thrs,1)
			if upgradables[i]
				potentials[i] = 1.0 / cost_thrs[i]
			end
		end
	elseif crit == "max_ratio"
		for i in axes(curr_dmg,1)
			if upgradables[i]
				dmg_incr = curr_dmg[i]*0.05
				potentials[i] = dmg_incr / cost_thrs[i]
			end
		end
	elseif crit == "random"
		sub_set = orb_lvl[upgradables]
		if length(sub_set) > 0
			lvl_pick = rand(sub_set)
			i_opt = findfirst(isequal(lvl_pick),orb_lvl)
			potentials[i_opt] = 1.0
		end
	else
		error("*** criterion $crit not implemented ***")
	end
	println("* $crit potentials : ",potentials)

	i_opt = argmax(potentials)
	if potentials[i_opt] == 0.0
		println("* no purchase possible")
		i_opt = 0
		up_cost = 0
	else
		println("* optimal level up on guardian $i_opt")
		up_cost = cost_thrs[i_opt]
		println("* cost is $up_cost")
	end

	return i_opt, up_cost
end

function find_rand_single_purchase(n_orb,orb_lvl)
	cost_thrs = next_level_costs(orb_lvl)
	upgradables = cost_thrs .<= n_orb
	println("*** spend $n_orb orbs for a random upgrade ***")
	println("* guardian levels : ",orb_lvl)
	println("* next level costs : ",cost_thrs)
	println("* upradables : ",upgradables)

	i_rand = 0
	up_cost = 0

	sub_set = orb_lvl[upgradables]
	if length(sub_set) > 0
		println("* levels of upgradable guardians : ",sub_set)
		lvl_pick = rand(sub_set)
		println("* random pick : level $lvl_pick")
		i_rand = findfirst(isequal(lvl_pick),orb_lvl)
		println("* random level up on guardian $i_rand")
		up_cost = cost_thrs[i_rand]
		println("* cost is $up_cost")
	else
		println("* no purchase possible")
	end

	return i_rand, up_cost
end

## Tests ##

function tester()
	nn = init_state(4)
	println("nn = ",nn)

	dmg = damages(nn)
	println("dmg = ",dmg)

	nn = [0, 1, 2, 3]
	dmg = damages(nn)
	println("dmg = ",dmg)
	cc = next_level_costs(nn)
	println("cc = ",cc)

	r1 = orb_reward(1,nn)
	r10 = orb_reward(10,nn)

	i_opt, s_cost = find_optim_single_purchase(100.0,nn,"max_damage")
	i_opt, s_cost = find_optim_single_purchase(r1,nn,"max_damage")
	i_opt, s_cost = find_optim_single_purchase(r10,nn,"max_damage")
	i_opt, s_cost = find_optim_single_purchase(2600.0,nn,"max_damage")

	i_rand, s_cost = find_rand_single_purchase(600.0,nn,"max_damage")
	i_rand, s_cost = find_rand_single_purchase(2600.0,nn,"max_damage")
end

#tester()

## Heuristic 0 : random upgrade for each purchase ##

function random_each_test(n_orb,n_guard)
	nn = init_state(n_guard)
	println("*** random heuristic for $n_guard guardians ***")
	println("*** spending $n_orb orbs ***")
	println("** init levels : ",nn)
	dmg_f = sum(damages(nn))

	go_on = true
	while go_on
		i_opt, s_cost = find_rand_single_purchase(n_orb,nn)
		if i_opt == 0
			go_on = false
			println("*** no more spending ***")
			continue
		end

		# NOT REACHED IF CANNOT SPEND
		println("** spending $s_cost orbs on guardian $i_opt")
		nn[i_opt] += 1
		n_orb -= s_cost
		println("** remaining orbs : $n_orb")
		println("** current levels : ",nn)
		dmg_f = sum(damages(nn))
		println("** total damage : $dmg_f")
	end
	println("")
	println("*** final damage (random each) : $dmg_f ***")
	println("")
end

#random_each_test(8600.0,4)

## Non random heuristics ##

function generic_heuristic_upgrade(n_orb,n_guard,heuristic)
	nn = init_state(n_guard)
	println("*** $heuristic heuristic for $n_guard guardians ***")
	println("*** spending $n_orb orbs ***")
	println("** init levels : ",nn)
	dmg_f = sum(damages(nn))

	go_on = true
	while go_on
		i_opt, s_cost = find_optim_single_purchase(n_orb,nn,heuristic)
		if i_opt == 0
			go_on = false
			println("*** no more spending ***")
			continue
		end

		# NOT REACHED IF CANNOT SPEND
		println("** spending $s_cost orbs on guardian $i_opt")
		nn[i_opt] += 1
		n_orb -= s_cost
		println("** remaining orbs : $n_orb")
		println("** current levels : ",nn)
		dmg_f = sum(damages(nn))
		println("** total damage : $dmg_f")
	end
	n_up = sum(nn)
	println("")
	println("*** final damage ($heuristic) : $dmg_f ***")
	println("*** with $n_up upgrade purchases ***")
	println("")

	return(nn)
end

## Heuristic 0 : better implementation of random upgrade for each purchase ##

function random_each(n_orb,n_guard)
	generic_heuristic_upgrade(n_orb,n_guard,"random")
end

## Heuristic 1 : max damage for each purchase ##

function max_damage_each(n_orb,n_guard)
	generic_heuristic_upgrade(n_orb,n_guard,"max_damage")
end

#max_damage_each(8600.0,4)

## Heuristic 2 : min cost for each purchase ##

function min_cost_each(n_orb,n_guard)
	generic_heuristic_upgrade(n_orb,n_guard,"min_cost")
end

## Heuristic 3 : max damage increment on cost ratio for each purchase ##

function max_ratio_each(n_orb,n_guard)
	generic_heuristic_upgrade(n_orb,n_guard,"max_ratio")
end

## Heuristic 4 : look for number of upgrades equal to max_ratio ##

# import Pkg
# Pkg.add("Combinatorics")

using Combinatorics

function cost_of_level(i)
	return ceil(2000*1.13^(i-1))
end

function cost_of_guardian(lvl_i)
	s = 0.0
	for j in 1:lvl_i
		s += cost_of_level(j)
	end

	return s
end

function total_cost(orb_lvl)
	s = 0.0
	for i in axes(orb_lvl,1)
		s += cost_of_guardian(orb_lvl[i])
	end

	return s
end

function max_upgrades(n_orb,n_guard)
	nn_max_ratio = max_ratio_each(n_orb,n_guard)
	println("")
	println("*** max_upgrades heuristic ***")
	println("* max_ratio solution : ",nn_max_ratio)
	n_up = sum(nn_max_ratio)
	println("* looking for combinations with number of upgrades = $n_up")
	println("* and cost lower than $n_orb")

	save_max = 0.0
	save_upgr = init_state(n_guard)
	for combi in with_replacement_combinations(collect(0:n_up),n_guard)
		cs = sum(combi)
		tc = total_cost(combi)
		if cs == n_up && tc <= n_orb
			println("")
			println("** admissible upgrade pattern : ",combi)
			println("* cost = $tc orbs")
			dmg = damages(combi)
			dmg_f = sum(dmg)
			println("* total damage = $dmg_f")
			if dmg_f >= save_max
				save_max = dmg_f
				save_upgr = combi
			end
		end
	end
	println("")
	println("*** optimal combination : ",save_upgr)
	println("*** damage = $save_max")
end

## Heuristic 5 : look for combinations with damage higher than max_damage ##

function higher_damage(n_orb,n_guard)
	nn_max_ratio = max_ratio_each(n_orb,n_guard)
	n_up = sum(nn_max_ratio)
	nn_max_dmg = max_damage_each(n_orb,n_guard)
	println("")
	println("*** higher_damage heuristic ***")
	println("* max_damage solution : ",nn_max_dmg)
	min_dmg = sum(nn_max_dmg)
	println("* looking for combinations with damage >= $min_dmg")
	println("* and cost lower than $n_orb")
	println("* and maximum level per guardian <= $n_up")

	save_max = 0.0
	save_upgr = init_state(n_guard)
	for combi in with_replacement_combinations(collect(0:n_up),n_guard)
		dmg = damages(combi)
		dmg_f = sum(dmg)
		tc = total_cost(combi)
		if dmg_f >= min_dmg && tc <= n_orb
			println("")
			println("** admissible upgrade pattern : ",combi)
			println("* cost = $tc orbs")
			println("* total damage = $dmg_f")
			if dmg_f >= save_max
				save_max = dmg_f
				save_upgr = combi
			end
		end
	end
	println("")
	println("*** optimal combination : ",save_upgr)
	println("*** damage = $save_max")
end
