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
