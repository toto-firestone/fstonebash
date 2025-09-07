#
# Some daily tasks are difficult to test because things happen only once
# per day and we need to avoid conflict with already implemented tasks.
#
# The idea consists in testing the tricky dailies in an interactive shell.
# Thus the integration to automated script can be delayed and done at the
# right time.
#
# Before sourcing this function only script in an interactive shell,
# make sure to source init-interactive.sh
#
# Be aware of the convention of coding here :
# DO NOT USE switch.conf FOR SERVER AUTO DETECTION
#
# Because for testing, we may want to jump on a test server without
# breaking the auto script already running (no switch-server.sh).
# And some test servers are not configured for script switching.
#
# Thus, always consider servername as a local variable provided by
# toplevel caller.
#

soft_check_file_before_source() {
	if [ ! -f "$1" ]; then
		echo "*** Cannot find $1 file : error"
	else
		echo "*** $1 file found : sourcing"
		source $1
	fi
}

auto_beer_token_10_pull() {
	echo "*** auto buy 10 tokens with beer and play 10 pulls"
	go_to_town
	move_wait_click $X_tavern_main $Y_tavern_main 2
	move_wait_click $X_tavern_beer $Y_tavern_beer 4
	sleep 7
	move_wait_click $X_beer_shop $Y_beer_shop 3

	# spend x2 1500 beers
	move_wait_click $X_beer_to_token $Y_beer_to_token 4
	sleep 2
	slow_safe_click
	sleep 2
	xdotool key Escape
	sleep 2

	# pull 10 cards
	move_wait_click $X_beer_tavern_toggl $Y_beer_tavern_toggl 3
	move_wait_click $X_beer_tavern_play $Y_beer_tavern_play 2
	move_wait_click $X_beer_tavern_card $Y_beer_tavern_card 4
	sleep 20

	# try artifact craft
	go_to_town
	move_wait_click $X_tavern_main $Y_tavern_main 2
	move_wait_click $X_tavern_beer $Y_tavern_beer 4
	sleep 7
	move_wait_click $X_craft_artifact $Y_craft_artifact 2
	sleep 15

	focus_and_back_to_root_screen
}

auto_scarab_10_pull_and_vault() {
	echo "*** auto play 10 scarab pulls and open vaults"
	go_to_town
	move_wait_click $X_tavern_main $Y_tavern_main 2
	move_wait_click $X_tavern_scarab $Y_tavern_scarab 4
	sleep 7

	# 10 noble's tokens
	move_wait_click $X_scarab_tavern_toggl $Y_scarab_tavern_toggl 3
	sleep 2
	slow_safe_click
	sleep 1
	move_wait_click $X_scarab_tavern_play $Y_scarab_tavern_play 2
	sleep 10

	# 50 vaults open
	move_wait_click $X_scarab_vault_tab $Y_scarab_vault_tab 2
	sleep 2
	move_wait_click $X_scarab_vault_toggl $Y_scarab_vault_toggl 3
	sleep 2
	slow_safe_click
	sleep 1
	move_wait_click $X_scarab_vault_open $Y_scarab_vault_open 2
	sleep 20

	# try release beast
	go_to_town
	move_wait_click $X_tavern_main $Y_tavern_main 2
	move_wait_click $X_tavern_scarab $Y_tavern_scarab 4
	sleep 7
	move_wait_click $X_release_beast $Y_release_beast 2
	sleep 15

	focus_and_back_to_root_screen
}

auto_crystal_5_hit() {
	echo "*** auto hit arcane crystal with 5 pickaxes"
	go_to_town
	move_wait_click $X_guild_portal $Y_guild_portal 2
	sleep 6
	move_wait_click $X_arcane_crystal $Y_arcane_crystal 2
	sleep 4

	# 5 hits on crystal
	move_wait_click $X_crystal_hit_toggle $Y_crystal_hit_toggle 2
	sleep 1
	move_wait_click $X_hit_arcane_crystal $Y_hit_arcane_crystal 2
	sleep 1

	focus_and_back_to_root_screen
}

auto_open_10_max_chests() {
	echo "*** auto open 1 to 10 chests on top left bag slot"
	open_bag_chests
	move_wait_click $X_bag_slot_1_1 $Y_bag_slot_1_1 3
	sleep 1
	move_wait_click $X_chest_open_10_max $Y_chest_open_10_max 2
	sleep 15

	focus_and_back_to_root_screen
}

flush_daily_mail() {
	local n_mail=${1:-"5"}
	echo "*** auto flush $n_mail mails"
	focus_and_back_to_root_screen
	local i=0
	while [ "$i" -lt "$n_mail" ]; do
		move_wait_click $X_mail_open $Y_mail_open 2
		sleep 1
		move_wait_click $X_mail_delete $Y_mail_delete 2
		sleep 1
		# this one is for claim goods or close mail if no goods
		xdotool key Escape
		sleep 1
		# this one is for close mail or nothing
		xdotool key Escape
		sleep 1
		i=$((i+1))
	done

	focus_and_back_to_root_screen
}

auto_guardian_holy_upgrade() {
	local serv=$1

	soft_check_file_before_source "$serv.firestone.conf" > /tmp/soft_check.txt

	cat /tmp/soft_check.txt
	local err=$(cat /tmp/soft_check.txt | grep "error")
	if [ -n "$err" ]; then
		return
	fi
	# NOT REACHED IF CONF FILE ERROR

	if ! $ENABLE_AUTO_RIFT; then
		echo "** Auto Rift disabled on $serv **"
		return
	fi
	# NOT REACHED IF AUTO RIFT DISABLED

	echo "** auto upgrade holy damage for guardians"
	go_to_guardian
	sleep 7
	move_wait_click $X_guard_holy_tab $Y_guard_holy_tab 2
	sleep 3

	local i=0
	while [ "$i" -lt "$N_HOLY_UPGRADE_CYCLES" ]; do
		local i_guard
		local X_guard
		for i_guard in ${guardian_holy_cycle_A[@]}; do
			eval "X_guard=\$X_guard_slot_${i_guard}"
			move_wait_click $X_guard $Y_guard_slot 2
			sleep 1
			move_wait_click $X_guard_holy_upgrade $Y_guard_holy_upgrade 2

			sleep 1
		done
		i=$((i+1))
	done

	# select default guardian
	eval "X_guard=\$X_guard_slot_${i_guardian_slot-1}"
	move_wait_click $X_guard $Y_guard_slot 2
	sleep 1
	focus_and_back_to_root_screen
}

auto_chaos_rift_play() {
	local serv=$1

	soft_check_file_before_source "$serv.firestone.conf" > /tmp/soft_check.txt

	cat /tmp/soft_check.txt
	local err=$(cat /tmp/soft_check.txt | grep "error")
	if [ -n "$err" ]; then
		return
	fi
	# NOT REACHED IF CONF FILE ERROR

	if ! $ENABLE_AUTO_RIFT; then
		echo "** Auto Rift disabled on $serv **"
		return
	fi
	# NOT REACHED IF AUTO RIFT DISABLED

	echo "*** auto chaos rift play with 10 moon stones"
	go_to_town
	move_wait_click $X_guild_portal $Y_guild_portal 2
	sleep 6
	move_wait_click $X_chaos_rift $Y_chaos_rift 7
	sleep 10

	# 10 moon stones
	move_wait_click $X_chaos_rift_toggle $Y_chaos_rift_toggle 3
	sleep 2
	slow_safe_click
	sleep 1
	move_wait_click $X_chaos_rift_hit $Y_chaos_rift_hit 2
	sleep 10

	focus_and_back_to_root_screen
}

#### functions just for liberation misions ###

mission_ok() {
	xdotool windowactivate --sync $gamewin_id
	sleep 1
	xdotool key Escape
	sleep 5
}

liberation_click() {
	move_wait_only $1 $2 $3
	super_slow_click
}

##### #### #### #### #### #### #### #### #####

auto_liberation_1to4() {
	echo "** auto liberation for missions 1 to 4"
	local n_liber=$1
	local t_fight_sec=$2
	if [ "$n_liber" -le "0" ]; then
		echo "* $n_liber liberation mission - skip"
		return
	fi
	if [ "$t_fight_sec" -lt "10" ]; then
		echo "* $t_fight_sec sec timeout is too short - skip"
		return
	fi
	# NOT REACHED IF NO LIBERATION OR IRRELEVANT TIMEOUT

	go_to_map
	move_wait_click $X_camp_map $Y_camp_map 4
	move_wait_click $X_mission_button $Y_mission_button 6

	move_wait_click $X_liberations $Y_liberations 4
	sleep 4
	local i=0
	if [ "$i" -lt  "$n_liber" ]; then
		i=$((i+1))
		echo "liberation $i"
		liberation_click $X_liberation_1 $Y_liberation_1 2
		sleep $t_fight_sec
		mission_ok
	fi
	if [ "$i" -lt  "$n_liber" ]; then
		i=$((i+1))
		echo "liberation $i"
		liberation_click $X_liberation_2 $Y_liberation_2 2
		sleep $t_fight_sec
		mission_ok
	fi
	if [ "$i" -lt  "$n_liber" ]; then
		i=$((i+1))
		echo "liberation $i"
		liberation_click $X_liberation_3 $Y_liberation_3 2
		sleep $t_fight_sec
		mission_ok
	fi
	if [ "$i" -lt  "$n_liber" ]; then
		i=$((i+1))
		echo "liberation $i"
		liberation_click $X_liberation_4 $Y_liberation_4 2
		sleep $t_fight_sec
		mission_ok
	fi

	focus_and_back_to_root_screen
}

auto_liberation_5more() {
	echo "** auto liberation for missions 5 and more"
	local n_liber=$1
	local t_fight_sec=$2
	if [ "$n_liber" -le "4" ]; then
		echo "* $n_liber liberation mission - skip"
		return
	fi
	if [ "$t_fight_sec" -lt "10" ]; then
		echo "* $t_fight_sec sec timeout is too short - skip"
		return
	fi
	# NOT REACHED IF NO LIBERATION OR IRRELEVANT TIMEOUT

	go_to_map
	move_wait_click $X_camp_map $Y_camp_map 4
	move_wait_click $X_mission_button $Y_mission_button 6

	move_wait_click $X_liberations $Y_liberations 4
	# scrolled part
	echo "DON'T MOVE MOUSE NOW"
	xdotool mousemove $X_liberation_4 $Y_liberation_4
	sleep 4
	local i=4
	while [ "$i" -lt  "$n_liber" ]; do
		i=$((i+1))
		echo "let's scroll to liberation $i"
		smooth_drag_and_drop $X_liber_scroll_right $Y_liber_scroll $X_liber_scroll_left $Y_liber_scroll

		#slow_safe_click
		liberation_click $X_liberation_4 $Y_liberation_4 2
		sleep $t_fight_sec
		mission_ok
		# tempo correction
		sleep 4
	done

	focus_and_back_to_root_screen
}

auto_dungeon() {
	echo "** auto dungeon"
	local n_dung=$1
	local t_fight_sec=$2
	if [ "$n_dung" -le "0" ]; then
		echo "* $n_dung dungeon mission - skip"
		return
	fi
	if [ "$t_fight_sec" -lt "10" ]; then
		echo "* $t_fight_sec sec timeout is too short - skip"
		return
	fi
	# NOT REACHED IF NO LIBERATION OR IRRELEVANT TIMEOUT

	go_to_map
	move_wait_click $X_camp_map $Y_camp_map 4
	move_wait_click $X_mission_button $Y_mission_button 6

	move_wait_click $X_dungeons $Y_dungeons 6
	local i=0
	if [ "$i" -lt  "$n_dung" ]; then
		i=$((i+1))
		echo "dungeons $i"
		liberation_click $X_dungeon_1 $Y_dungeon_1 2
		sleep $t_fight_sec
		mission_ok
	fi
	if [ "$i" -lt  "$n_dung" ]; then
		i=$((i+1))
		echo "dungeons $i"
		liberation_click $X_dungeon_2 $Y_dungeon_2 2
		sleep $t_fight_sec
		mission_ok
	fi

	focus_and_back_to_root_screen
}

auto_liberation_dungeon() {
	echo "*** auto liberation and dungeon ***"
	anti_ad
	auto_liberation_1to4 $1 $3
	auto_liberation_5more $1 $3
	auto_dungeon $2 $3
}

auto_claim_gifts() {
	echo "*** auto oracle and shop gifts"
	go_to_oracle
	move_wait_click $X_oracle_shop $Y_oracle_shop 2
	move_wait_click $X_oracle_gift $Y_oracle_gift 2

	go_to_town
	move_wait_click $X_main_shop $Y_main_shop 2
	move_wait_click $X_free_box $Y_free_box 3
	sleep 1
	move_wait_click $X_checkin_tab $Y_checkin_tab 2
	echo "Warning : check-in button may change place when special offer occurs"
	echo "a wrong check-in coordinate is not harmful"
	move_wait_click $X_checkin_but $Y_checkin_but 2
	echo "try alternative position..."
	move_wait_click $X_checkin_but $((Y_checkin_but+46)) 2

	focus_and_back_to_root_screen
}

auto_exotic_sales() {
	echo "*** auto sale crap in exotic shop"
	go_to_exotic
	# toggle to X50
	move_wait_click $X_exo_toggle $Y_exo_toggle 2
	move_wait_click $X_exo_toggle $Y_exo_toggle 3
	sleep 1

	move_wait_click $X_speed_scroll $Y_speed_scroll 2
	move_wait_click $X_damage_scroll $Y_damage_scroll 2
	move_wait_click $X_health_scroll $Y_health_scroll 2
	move_wait_click $X_midas_touch $Y_midas_touch 2

	echo "scrolling to the bottom part"
	#sleep 2
	smooth_drag_and_drop $X_exotic_scroll $Y_exotic_scroll_bottom $X_exotic_scroll $Y_exotic_scroll_top
	sleep 2
	smooth_drag_and_drop $X_exotic_scroll $Y_exotic_scroll_bottom $X_exotic_scroll $Y_exotic_scroll_top

	move_wait_click $X_drum_war $Y_drum_war 2
	move_wait_click $X_dragon_armor $Y_dragon_armor 2
	move_wait_click $X_guardian_rune $Y_guardian_rune 2
	move_wait_click $X_totem_agony $Y_totem_agony 2
	move_wait_click $X_totem_annihil $Y_totem_annihil 2

	focus_and_back_to_root_screen
}

auto_claim_pickaxes() {
	echo "*** auto and safe claim of pickaxes"
	go_to_town
	move_wait_click $X_guild_portal $Y_guild_portal 2

	move_wait_click $X_guild_shop $Y_guild_shop 7
	move_wait_click $X_guild_supplies $Y_guild_supplies 3
	move_wait_click $X_guild_supplies $Y_guild_supplies 2
	move_wait_click $X_guild_supplies $Y_guild_supplies 1
	move_wait_click $X_claim_pickaxe $Y_claim_pickaxe 3

	focus_and_back_to_root_screen
}

print_daily_todo() {
	if [ -z "$1" ]; then
		echo "* Error : provide a server name as argument"
		return
	fi
	source daily.conf
	if ! ${auto_daily_H[$1]-false}; then
		echo "* Warning : auto daily disabled for $1"
		return
	fi

	echo "** daily todo list on $1"
	local f_todo="./tmp/$1.daily.todo"
	if [ ! -f "$f_todo" ]; then
		echo "empty"
	else
		cat $f_todo
	fi
}

edit_daily_todo() {
	if [ -z "$1" ]; then
		echo "* Error : provide a server name as argument"
		return
	fi
	source daily.conf
	if ! ${auto_daily_H[$1]-false}; then
		echo "* Warning : auto daily disabled for $1"
		return
	fi

	echo "** daily todo list on $1"
	local f_todo="./tmp/$1.daily.todo"
	if [ ! -f "$f_todo" ]; then
		echo "empty"
	else
		vi $f_todo
	fi
}

auto_arena_fight() {
	echo "*** auto arena fight"
	focus_and_back_to_root_screen
	xdotool key k
	sleep 6
	move_wait_click $X_arena_fight_slot_3 $Y_arena_fight_slot_3 2
	sleep 4
	move_wait_click $X_arena_fight_start $Y_arena_fight_start 2
	sleep $MAX_WM_FIGHT_TIME

	focus_and_back_to_root_screen
}

set_guardian_hits() {
	local serv=$1 n_hits=$2
	local hit_file="./tmp/$serv.guardian.hit"

	if [ ! -f "$serv.firestone.conf" ]; then
		echo "* cannot set guardian hits on unknown server $serv"
	elif [[ ! $n_hits =~ ^[0-9]+$ ]]; then
		echo "* cannot set non numeric guardian hits on server $serv"
	elif [ "$n_hits" -le "0" ]; then
		echo "* cannot set negative guardian hits on server $serv"
	else
		echo "$n_hits" > $hit_file
		echo "* set $n_hits guardian hits in $hit_file"
	fi
}

auto_guardian_climb() {
	local serv=$1
	local hit_file="./tmp/$serv.guardian.hit"

	if [ -f "$hit_file" ]; then
		local n_hits=$(cat $hit_file)
		n_hits=$((n_hits - 1))
		if [ "$n_hits" -gt "0" ]; then
			echo "$n_hits" > $hit_file
		else
			rm $hit_file
		fi
		focus_and_back_to_root_screen
		move_wait_click $X_fight_boss $Y_fight_boss 1
		sleep 2
		xdotool key space
		sleep .5
	else
		echo "* WARNING : no more guardian hits on $serv"
	fi
}

