#!/bin/bash
source glob-coord.conf
## not master.conf here because win_id.conf is not up to date
source view.conf

source function-lib.sh
source visual-lib.sh
source remote-tools.sh

log_msg "*** respawn process PID=$$ ***"

wait_minutes=${1:-5}
log_msg "*** wait $wait_minutes minutes before respawn ***"
sleep $((wait_minutes*60))

log_msg "*** respawn game and bot now ***"
remote_auto_firestone_start
