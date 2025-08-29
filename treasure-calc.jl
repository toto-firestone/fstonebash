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


function init_spreadsheet(key_map,symbols,dmg_dict,tavern,dust,contract,tome)
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

tavern_reward = 140
dust_reward = 7000
contract_reward = 1400
tome_reward = 210

println("*** damage percent ***")
for (player,dmg_percent) in damage_2025_07
	println("* $player => $dmg_percent %")
end

sheet_2025_07 = init_spreadsheet(map_col_j,column_keys,damage_2025_07,
	tavern_reward,dust_reward,contract_reward,tome_reward)

for i in 1:size(sheet_2025_07,1)
	println(sheet_2025_07[i,:])
end

