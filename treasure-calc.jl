##
## Tools for calculating chaos rift guild loot distribution
## Intended to be run in interactive Julia session
##

# ######### #
# Constants #
# ######### #


COLUMN_KEYS = [
	"player_id";
	"dmg_percent";
	"tavern_reward";
	"tavern_distrib";
	"tavern_percent";
	"dust_reward";
	"dust_distrib";
	"dust_percent";
	"contract_reward";
	"contract_distrib";
	"contract_percent";
	"tome_reward";
	"tome_distrib";
	"tome_percent";
]

# reverse association with dictionnary
# for loop and Meta.parse cannot modify toplevel

### ######################### ###
### Reverse mapping functions ###
### ######################### ###

function key_mapping(symbols)
	return Dict( symbols[i] => i for i in 1:length(symbols) )
end

function print_key_map(key_map,symbols)
	for k in symbols
		i = key_map[k]
		println("* $k = $i")
	end
	println("")
end

### ######################### ###


MAP_COL_J = key_mapping(COLUMN_KEYS)

println("*** keys to column index mapping ***")
print_key_map(MAP_COL_J,COLUMN_KEYS)


## Creating the empty array for data ##
# The code data has dimension number_players * number_columns
# however, we will want to export the results in file
# then 2 additional lines are required above :
#  - titles for columns
#  - total reward to distribute
# 1 additional line is required on the bottom for checksums


function init_spreadsheet(dmg_dict,rew_dict,
			key_map=MAP_COL_J,symbols=COLUMN_KEYS)
	tavern = rew_dict["tavern"]
	dust = rew_dict["dust"]
	contract = rew_dict["contract"]
	tome = rew_dict["tome"]

	n = 2 + length(dmg_dict) + 1
	m = length(symbols)
	dat = Matrix{Union{Int, String, Float64}}(undef,n,m)
	dat .= ""

	for j in 1:m
		dat[1,j] = symbols[j]
	end
	dat[2,key_map["tavern_reward"]] = tavern
	dat[2,key_map["dust_reward"]] = dust
	dat[2,key_map["contract_reward"]] = contract
	dat[2,key_map["tome_reward"]] = tome
	dat[end,key_map["player_id"]] = "checksum"

	raw_players = [ k for k in keys(dmg_dict) ]
	player_with_i = [ raw_players[i]*" [i=$i]"
				for i in 1:length(raw_players) ]
	dat[3:end-1,key_map["player_id"]] = player_with_i

	distrib_dmg = [ k for k in values(dmg_dict) ]
	dat[3:end-1,key_map["dmg_percent"]] = distrib_dmg
	dat[end,key_map["dmg_percent"]] = sum(distrib_dmg)

	for r_str in ["tavern", "dust", "contract", "tome"]
		rew = dat[2,key_map["$(r_str)_reward"]]

		dist_float = rew/100 * distrib_dmg
		dat[3:end-1,key_map["$(r_str)_reward"]] = dist_float
		chk = sum(dist_float)
		dat[end,key_map["$(r_str)_reward"]] = chk

		dist_int = [ round(Int,x) for x in dist_float ]
		dat[3:end-1,key_map["$(r_str)_distrib"]] = dist_int
		chk = sum(dist_int)
		dat[end,key_map["$(r_str)_distrib"]] = chk

		rew_percent = 100/rew * dist_int
		dat[3:end-1,key_map["$(r_str)_percent"]] = rew_percent
		chk = sum(rew_percent)
		dat[end,key_map["$(r_str)_percent"]] = chk
	end

	return dat
end


function str_pad(s,col_len)
	n = length(s)
	if n >= col_len
		pad_s = s
	else
		pad_s = repeat(" ",col_len - n) * s
	end
	return pad_s
end


function view_by_reward(dat,r_str,
			key_map=MAP_COL_J)
	numcol_len = 12
	col_len = 80 - 4 * numcol_len
	view_str = ""

	i = 1
		player_str = string(dat[i,key_map["player_id"]])*" ,"
		line_str = str_pad(player_str,col_len)

		r_val = "dmg_%"
		dmg_str = string(r_val)*" ,"
		line_str = line_str * str_pad(dmg_str,numcol_len)

		r_val = "$(r_str)"
		reward_str = string(r_val)*" ,"
		line_str = line_str * str_pad(reward_str,numcol_len)

		i_val = "distrib"
		distrib_str = string(i_val)*" ,"
		line_str = line_str * str_pad(distrib_str,numcol_len)

		r_val = "percent"
		percent_str = string(r_val)*" \n"
		line_str = line_str * str_pad(percent_str,numcol_len)

		view_str = view_str * line_str

	i = 2
		player_str = string(dat[i,key_map["player_id"]])*" ,"
		line_str = str_pad(player_str,col_len)

		r_val = dat[i,key_map["dmg_percent"]]
		dmg_str = string(r_val)*" ,"
		line_str = line_str * str_pad(dmg_str,numcol_len)

		r_val = dat[i,key_map["$(r_str)_reward"]]
		reward_str = string(r_val)*" ,"
		line_str = line_str * str_pad(reward_str,numcol_len)

		i_val = dat[i,key_map["$(r_str)_distrib"]]
		distrib_str = string(i_val)*" ,"
		line_str = line_str * str_pad(distrib_str,numcol_len)

		r_val = dat[i,key_map["$(r_str)_percent"]]
		percent_str = string(r_val)*" \n"
		line_str = line_str * str_pad(percent_str,numcol_len)

		view_str = view_str * line_str

	for i in 3:size(dat,1)
		player_str = string(dat[i,key_map["player_id"]])*" ,"
		line_str = str_pad(player_str,col_len)

		r_val = round(dat[i,key_map["dmg_percent"]],digits=3)
		dmg_str = string(r_val)*" ,"
		line_str = line_str * str_pad(dmg_str,numcol_len)

		r_val = round(dat[i,key_map["$(r_str)_reward"]],digits=3)
		reward_str = string(r_val)*" ,"
		line_str = line_str * str_pad(reward_str,numcol_len)

		i_val = dat[i,key_map["$(r_str)_distrib"]]
		distrib_str = string(i_val)*" ,"
		line_str = line_str * str_pad(distrib_str,numcol_len)

		r_val = round(dat[i,key_map["$(r_str)_percent"]],digits=3)
		percent_str = string(r_val)*" \n"
		line_str = line_str * str_pad(percent_str,numcol_len)

		view_str = view_str * line_str
	end

	println("")
	title = "*** view by $(r_str) ***"
	pad = ceil(Int,(80 - length(title))/2)
	println(repeat(" ",pad),title)
	println(view_str)

	return nothing
end


function tweek_distribution(dat,r_str,player_i,increment,
				key_map=MAP_COL_J)
	i = 2 + player_i
	j = key_map["$(r_str)_distrib"]
	new_val = dat[i,j] + increment
	dat[i,j] = round(Int,new_val)
	dist_new = dat[3:end-1,key_map["$(r_str)_distrib"]]
	chk = sum(dist_new)
	dat[end,key_map["$(r_str)_distrib"]] = chk

	rew = dat[2,key_map["$(r_str)_reward"]]
	rew_percent = 100/rew * dist_new
	dat[3:end-1,key_map["$(r_str)_percent"]] = rew_percent
	chk = sum(rew_percent)
	dat[end,key_map["$(r_str)_percent"]] = chk

	view_by_reward(dat,r_str)

	return nothing
end


function generate_report(dat,out_file,
			key_map=MAP_COL_J)
	play_i = 3:(size(dat,1)-1)
	play_j = key_map["player_id"]
	rewards = [ "tavern", "dust", "contract", "tome" ]

	open(out_file,"w") do fd
		for i in play_i
			player_str = dat[i,play_j]
			n_pad = 70 - length(player_str)
			println(fd,"*** ",player_str,repeat("*",n_pad))

			for r in rewards
				rew_j = key_map["$(r)_distrib"]
				println(fd,"* $r = ",dat[i,rew_j])
			end

			println(fd,"* check status : \n\n\n\n")
		end
	end

	println("*** report written to $out_file ***")

	return nothing
end

## Loading external package for ordered dictionary ##

# import Pkg
# Pkg.add("DataStructures")

using DataStructures


# ########################## #
# Sample test / example data #
# ########################## #

# these input data have to be in text files

test_damage_2025_07 = OrderedDict(
	"theFaint" => 53.3,
	"Fayath" => 6.6,
	"Punk" => 5.5,
	"Emil" => 3.5,
	"toto" => 2.7,
	"Renseiga" => 2.7,
	"Nardole" => 2.7,
	"Abulafia" => 2.6,
	"Lea" => 2.5,
	"Vonbaxter" => 2.5,
	"Stjornhok" => 2.4,
	"BassTCrunch" => 2.4,
	"Athena" => 2.4,
	"Morrigan" => 2.4,
	"Knuck" => 2.3,
	"Keimex" => 2.2,
	"Nadole33" => 1.5,
	"Tig" => 0.,
)

test_reward_2025_07 = Dict(
	"tavern" => 140,
	"dust" => 7000,
	"contract" => 1400,
	"tome" => 210,
)

# ########################## #
# ########################## #



########### just check ##########
#println("*** damage percent ***")
#for (player,dmg_percent) in damage_2025_07
	#println("* $player => $dmg_percent %")
#end
########### ########## ##########

########### manual is here ##########
#include("test_file.jl")
#test_sheet_2025_07 = init_spreadsheet(test_damage_2025_07,test_reward_2025_07)

#view_by_reward(test_sheet_2025_07,"tavern")
#view_by_reward(test_sheet_2025_07,"dust")
#view_by_reward(test_sheet_2025_07,"contract")
#view_by_reward(test_sheet_2025_07,"tome")

#backup = copy(test_sheet_2025_07)

#tweek_distribution(test_sheet_2025_07,"dust",5,100)

# and restore
#test_sheet_2025_07 = copy(backup)

#generate_report(test_sheet_2025_07,"tmp/test_treasure.txt")
########### ############## ##########

