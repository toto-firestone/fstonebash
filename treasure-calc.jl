##
## Tools for calculating chaos rift guild loot distribution
## Intended to be run in interactive Julia session
##

# ######### #
# Constants #
# ######### #


column_keys = [
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


map_col_j = key_mapping(column_keys)

println("*** keys to column index mapping ***")
print_key_map(map_col_j,column_keys)


## Creating the empty array for data ##
# The code data has dimension number_players * number_columns
# however, we will want to export the results in file
# then 2 additional lines are required above :
#  - titles for columns
#  - total reward to distribute
# 1 additional line is required on the bottom for checksums


function init_spreadsheet(key_map,symbols,dmg_dict,rew_dict)
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

	dat[3:end-1,key_map["player_id"]] = [ k for k in keys(dmg_dict) ]

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


function view_by_reward(dat,key_map,r_str)
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
end


## Loading external package for ordered dictionary ##

# import Pkg
# Pkg.add("DataStructures")

using DataStructures


# ########################## #
# Sample test / example data #
# ########################## #

damage_2025_07 = OrderedDict(
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

reward_2025_07 = Dict(
	"tavern" => 140,
	"dust" => 7000,
	"contract" => 1400,
	"tome" => 210,
)

println("*** damage percent ***")
for (player,dmg_percent) in damage_2025_07
	println("* $player => $dmg_percent %")
end

sheet_2025_07 = init_spreadsheet(map_col_j,column_keys,
	damage_2025_07,reward_2025_07)

view_by_reward(sheet_2025_07,map_col_j,"tavern")
view_by_reward(sheet_2025_07,map_col_j,"dust")
view_by_reward(sheet_2025_07,map_col_j,"contract")
view_by_reward(sheet_2025_07,map_col_j,"tome")

