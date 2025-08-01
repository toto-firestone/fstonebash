#!/bin/bash
source glob-coord.conf
source function-lib.sh
source win_id.conf
source switch.conf

radish_message_noprompt "SAFE CLAIM PICKAXES"

server_config="$current_servname.firestone.conf"
echo "reading $server_config"
source $server_config

go_to_town
move_wait_click $X_guild_portal $Y_guild_portal 2

move_wait_click $X_guild_shop $Y_guild_shop 6
move_wait_click $X_guild_supplies $Y_guild_supplies 3
move_wait_click $X_guild_supplies $Y_guild_supplies 2
move_wait_click $X_guild_supplies $Y_guild_supplies 1
move_wait_click $X_claim_pickaxe $Y_claim_pickaxe 3

focus_and_back_to_root_screen
