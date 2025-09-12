#!/bin/bash
source glob-coord.conf
source master.conf
source function-lib.sh
source visual-lib.sh
source tricky-dailies.sh
source daily.conf

radish_message_noprompt "SPLIT THE WORKLOAD OF THE DAILIES"

source $current_servname.firestone.conf
f_task="./tmp/$current_servname.daily.todo"

if [ ! -f "$f_task" ]; then
	echo "Warning : $f_task not found on startup. Exit"
	exit
fi
if [ ! -s "$f_task" ]; then
	echo "Warning : $f_task empty on startup. Remove and exit"
	remove_task ${f_task#./tmp/}
	exit
fi
# NOT REACHED IF TASK FILE ISSUE
# NOW TASK FILE EXISTS AND NON EMPTY

Nlibe=${Nlibe_H[$current_servname]-"0"}
Ndung=${Ndung_H[$current_servname]-"0"}
TFight=${TFightSec_H[$current_servname]-"60"}

daily_cmd=$(head -n 1 $f_task)
sed -i '1d' $f_task

case $daily_cmd in
	"libe_dung") echo "* command read : $daily_cmd"
		echo "* expedition check before all liberations and dungeons"
		launch_and_claim_expedition

		echo "* doing $Nlibe liberations and $Ndung dungeons"
		echo "* timeout at $TFight sec"
		auto_liberation_dungeon $Nlibe $Ndung $TFight

		### not yet : don't do that incase of map position bug ###
		#echo "* map check after liberation"
		#./auto-map.sh
		echo;;
	"libe_1to4") echo "* command read : $daily_cmd"
		echo "* doing $Nlibe / 4 liberations"
		echo "* timeout at $TFight sec"
		auto_liberation_1to4 $Nlibe $TFight
		echo;;
	"libe_5more") echo "* command read : $daily_cmd"
		echo "* doing $Nlibe liberations at 5+"
		echo "* timeout at $TFight sec"
		auto_liberation_5more $Nlibe $TFight
		echo;;
	"dung") echo "* command read : $daily_cmd"
		echo "* doing $Ndung dungeons"
		echo "* timeout at $TFight sec"
		auto_dungeon $Ndung $TFight
		echo;;
	"gift_exotic") echo "* command read : $daily_cmd"
		auto_claim_gifts
		auto_exotic_sales
		echo;;
	"gift") echo "* command read : $daily_cmd"
		auto_claim_gifts
		echo;;
	"pickaxe_crystal") echo "* command read : $daily_cmd"
		auto_claim_pickaxes
		auto_crystal_5_hit
		echo;;
	"pickaxe") echo "* command read : $daily_cmd"
		auto_claim_pickaxes
		echo;;
	"beer") echo "* command read : $daily_cmd"
		auto_beer_token_10_pull
		echo;;
	"scarab") echo "* command read : $daily_cmd"
		auto_scarab_10_pull_and_vault
		echo;;
	"chest_mail") echo "* command read : $daily_cmd"
		auto_open_10_max_chests
		flush_daily_mail $N_FLUSH_MAILS
		echo;;
	"mail") echo "* command read : $daily_cmd"
		flush_daily_mail $N_FLUSH_MAILS
		echo;;
	"holy_rift") echo "* command read : $daily_cmd"
		auto_guardian_holy_upgrade $current_servname
		auto_chaos_rift_play $current_servname
		echo;;
	"arena") echo "* command read : $daily_cmd"
		auto_arena_fight
		echo;;
	*) echo "* command unknown : $daily_cmd - skip";;
esac

if [ ! -s "$f_task" ]; then
	echo "* End of : $f_task reached. Remove"
	remove_task ${f_task#./tmp/}
fi
