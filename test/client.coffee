#!node_modules/coffee-script/bin/coffee
#
# Example: Sending a single log message to LumberJack.
#

lj = require "../lib/client"

lj.config "localhost", 51234

lj.log "test", "info", "I am a log message!"
