#!node_modules/coffee-script/bin/coffee
#
# Example: Sending a single log message to LumberJack.
#

dgram = require "dgram"
client = dgram.createSocket "udp4"

# LJ's wire protocol is simple. There are 4 strings, delimited with NUL characters (\0).
#
# <host>\0<facility>\0<priority>\0<message>

message = new Buffer "web1\0wcore\0info\0Hello, world!"
client.send message, 0, message.length, 51234, "localhost"
client.close()
