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
	if i <= 0
		return 0
	else
		return ceil(2000*1.13^(i-1))
	end
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
	min_dmg = sum(damages(nn_max_dmg))
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

## Heuristic 6 : look for combinations with damage higher than min_cost ##
## After some trials, this heuristic should be the good one ##

function better_min_cost(n_orb,n_guard)
	nn_min_cost = min_cost_each(n_orb,n_guard)
	n_up = sum(nn_min_cost)
	println("")
	println("*** better than minimal cost heuristic ***")
	println("* min_cost solution : ",nn_min_cost)
	min_dmg = sum(damages(nn_min_cost))
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


## A usable optimization tool ##

function optimize_orbs(guards_levels,orb_for_spend)
	n_guards = length(guards_levels)
	all_orbs = orb_for_spend + total_cost(guards_levels)
	better_min_cost(all_orbs,n_guards)
	println("*** results given for $n_guards guardians")
	println("*** $orb_for_spend additional orbs to spend ***")
	println("*** optimal guardians are given in arbitrary order ***")
end

## Heuristic 7 : the best combination with all guardian levels higher or
## equal than the current guardians levels

function better_than_previous(n_orb,nn_previous)
	n_guard = length(nn_previous)

	# min cost solution will provide the highest number of upgrades
	nn_min_cost = min_cost_each(n_orb,n_guard)
	n_up = sum(nn_min_cost)

	println("")
	println("*** better than previous heuristic ***")
	println("* previous solution : ",nn_previous)
	min_dmg = sum(damages(nn_previous))
	println("* looking for combinations with damage >= $min_dmg")
	println("* and cost lower than $n_orb")
	println("* and maximum level per guardian <= $n_up")

	save_max = 0.0
	save_upgr = init_state(n_guard)
	for combi in with_replacement_combinations(collect(0:n_up),n_guard)
		dmg = damages(combi)
		dmg_f = sum(dmg)
		tc = total_cost(combi)
		more_lvl = combi .>= nn_previous
		if dmg_f >= min_dmg && tc <= n_orb && all(more_lvl)
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


## An incremental optimization tool ##

function increment_optimize_orbs(guards_levels,orb_for_spend)
	n_guards = length(guards_levels)
	all_orbs = orb_for_spend + total_cost(guards_levels)
	# needs to be sorted in order to make vector comparison work
	lvl_sorted = sort(guards_levels)
	better_than_previous(all_orbs,lvl_sorted)
	println("*** results given for $n_guards guardians")
	println("*** $orb_for_spend additional orbs to spend ***")
	println("*** optimal guardians are given in arbitrary order ***")
end

## Manual ##

PURPOSE = """
I - Purpose

This tools has been written for optimizing the holy damage upgrade pattern
for guardians. In other words, how to spend orbs in order to obtain the
maximum damage.

Since chaos rift start, one year ago, i was using the following holy upgrade
pattern : always give maximum of orbs to 1 guardian, and lefover to other
ones. Trying another pattern in order to compare is hard since it requires
writing down damage done and upgrade purchased each day. And there is no
guarantee that these measurements are comparable over time, since guardians
are upgrading holy features with evolution and rarities. But the main
difficulty come from double and critical hits that make the data collected
in-game definitely non usable for an optimization process.

It took me one year to realize that i need a simulator that ignores all
random special hits that may boost damage occasionally. In this way, we can
focus on the maximization of holy BASE DAMAGE only.
"""

BACKGROUND = """
II - Background

At the begining, i was looking for an optimal way to spend orbs day after day
during the whole month of competition. In other words, it was trying to
calculate a time dependant function that tells which gardians are upgraded
at day 1, 2, 3, ... 30. The difficulty of that exercise in insane.

Then, i tried something much simpler : compare the method i used so far with
another commonly used one, which was upgrade equally all guardian. This
task was easy and the first result showed that upgrading equally holy damage
of all guardian leads to significantly better base damage than upgrading
one guardian as much as possible, leaving leftover to others.

The next question was : is there a better method  than upgrading equally
for the maximization of total base damage of all guardians ? To answer this
question, no need to go into theories. Just need to write a random upgrade
method, run it several times, and if it catches a better pattern, then the
answer will be clearly yes. So the answer was yes. But now, how to compute
that optimal upgrade pattern ?
"""

METHODS = """
III - Method

Finding the optimal holy upgrade pattern for a set of guardians can be
expressed as follows : Maximize the total base damage that we can obtain
with N orbs and G guardians.

Of course, we need to optimize daily orb spending. At this point, an important
choice has been made. In order to ensure that the calculator gives optimal
solution, incremental approaches with time dependant upgrade patterns will be
ignored. This choice has been influence by the difficulty to handle time
in the preliminary studies.

This calulator will consider that already spent orbs are refund, guardian's
holy levels are reset. Refunded orbs are gathered with freshly gained orbs
in order to upgrade again the same number of guardians. Of course the games
doesn't work like this. But this "reset" approach will definitely avoid
the risk of computing suboptimal answers.

However, keep in mind that the risk taken is that the computed optimal
upgrades may be non feasible. In real game, guardians cannot be downgraded.
In this case, which WILL HAPPEN, use EQUAL UPGRADE paradigm.
"""

SOLVING = """
IV - Solving

Nothing special to say about it : according to the small size of input data,
a brute force method is affordable. The combinatory explosion remains
ridiculous.

All combinations of possible guardian holy upgrade are tested. Then only
feasible ones are selected (cost lower than orb stock) and only relevant ones
are shown (total holy base damage greater or equal than minimal cost solution ;
that minimal cost solution correspond to the equally upgraded guardians).

Brute force is the way that optimality is ensured. This explains why the
"reset" approach has been chosen.
"""

USAGE = """
V - Usage

Let's say i have 3 guardians at holy level equal to 10, 11 and 19. The order
does not matter. I also have 20741 more orbs to spend after having claimed
the reward.

This command line in Julia session :

julia> optimize_orbs([10, 11, 19],20741)

will end like this :

*** optimal combination : [15, 15, 15]
*** damage = 6236.784538234106
*** results given for 3 guardians
*** 20741 additional orbs to spend ***
*** optimal guardians are given in arbitrary order ***

which means that i can level up only the 2 lowest guardians. This is a non
feasible optimal solution.

Another example with 2 guardians at levels 1é and 16, and 14994 orbs to spend :

julia> optimize_orbs([12, 16],14994)

*** optimal combination : [12, 17]
*** damage = 4087.8746438231638
*** results given for 2 guardians
*** 14994 additional orbs to spend ***
*** optimal guardians are given in arbitrary order ***

This is a feasible solution. Just upgrade once the level 16 guardian.

How to install Julia is beyond the scope of this manual. This calculator
requires an external package :

julia> import Pkg
julia> Pkg.add("Combinatorics")

VI - Update to incremental method

After a month using the former function, i found out many times not being able
to perform the recommended upgrade pattern. Sometimes, even the equal upgrade
pattern is not feasible. Then i figured out that the incremental opimization
method should also consider less optimal combinations than all equal.

This ends up with the simplest approach, which was not obvious finally.
We just examine all combinations, keep only the ones we can afford,
doing more damage than the previous guardian set-up and with no downgrade.
The maximum holy level of a guardian is still upper bounded according to
the total upgrades found in mininal cost purchase approach, that maximizes
the number of purchased holy upgrades.

This command line in Julia session (leading to a non feasible optimum
using former approach - cannot donwgrade lvl 19 to 15) :

julia> increment_optimize_orbs([10, 11, 19],20741)

will end like this :

*** optimal combination : [10, 13, 19]
*** damage = 6041.493964476319
*** results given for 3 guardians
*** 20741 additional orbs to spend ***
*** optimal guardians are given in arbitrary order ***

"""

function manual()
	println(PURPOSE)
	println(BACKGROUND)
	println(METHODS)
	println(SOLVING)
	println(USAGE)
	println("Version 1.0")
end

manual()
