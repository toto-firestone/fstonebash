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
	sleep 1

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
	echo "*** auto flush 10 mails"
	focus_and_back_to_root_screen
	move_wait_click $X_mail_open $Y_mail_open 2
	sleep 1

	move_wait_click $X_mail_delete $Y_mail_delete 2
	sleep 1
	xdotool key Escape
	local i=0
	while [ "$i" -lt "9" ]; do
		sleep 1
		slow_safe_click
		sleep 1
		xdotool key Escape
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
