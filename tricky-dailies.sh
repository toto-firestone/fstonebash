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
