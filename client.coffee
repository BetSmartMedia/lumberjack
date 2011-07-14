#!node_modules/coffee-script/bin/coffee
#
# Example: Sending a single log message to LumberJack.
#

dgram = require "dgram"
client = dgram.createSocket "udp4"

message = new Buffer "web1\0wcore\0info\0Hello, world!"
client.send message, 0, message.length, 51234, "localhost"
client.close()
