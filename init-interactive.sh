#!/bin/bash

#
# File to source for an interactive session
#

source glob-coord.conf
source master.conf
source function-lib.sh 
source visual-lib.sh 
source tricky-dailies.sh
source remote-tools.sh

# define now environment variables related to remote or local access
env_for_remote_or_local

## handling config files templates updates
update_config_files() {
	# this array is local
	declare -a config_files_A=(
		"auto-accept.conf"
		"daily.conf"
		"ftree.conf"
		"gameover.conf"
		"glob-coord.conf"
		"map.conf"
		"master.conf"
		"s1.firestone.conf"
		"s27.firestone.conf"
		"s31.firestone.conf"
		"s14.firestone.conf"
		"s25.firestone.conf"
		"s8.firestone.conf"
		"switch.conf"
		"view.conf"
		"win_id.conf"
	)
	for conf_f in "${config_files_A[@]}"; do
		echo "** processing $conf_f"
		local templ_f="templates/$conf_f"
		diff "$templ_f" "$conf_f"

		local ans
		read -p "* update this file ? (y/n) " ans
		if [ "$ans" == "y" ]; then
			echo "* copy to $templ_f"
			cp "$conf_f" "$templ_f"
		else
			echo "* skip"
		fi
		read -p "* press any key to continue "
		echo
	done
}

### backup for tmp directory
save_tmp_dir() {
	cp tmp/*.timestamp sample-tmp/
	cp tmp/*.todo sample-tmp/
	cp tmp/*.jl sample-tmp/
	cp tmp/*.hit sample-tmp/
	cp tmp/*.txt sample-tmp/
}
