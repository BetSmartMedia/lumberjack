#
# A client for Lumberjack
#
# Example Usage:
#   lj = require "lumberjack"
#   lj.config "127.0.01", 51234
#   
#   lj.log "test", "info", "I am a log message!"
#   lj.log "test", "warning", "So am I!"
#

dgram = require "dgram"
os    = require "os"

# fetch hostname, the short version
hostname = os.hostname()
idx      = hostname.indexOf '.'
hostname = hostname.substring 0, idx if idx > -1

# configuration defaults
cfg =
	host: '127.0.0.1'
	port: 51234

config = (host, port) ->
	cfg.host = host
	cfg.port = port

log = (facility, priority, message) ->
	client = dgram.createSocket "udp4"

	# LJ's wire protocol is simple. There are 4 strings, delimited with NUL characters (\0).
	#
	# <host>\0<facility>\0<priority>\0<message>
	
	# coerce the message into a string
	message = message.toString()

	buf = new Buffer "#{hostname}\0#{facility}\0#{priority}\0#{message}"
	client.send buf, 0, buf.length, cfg.port, cfg.host
	client.close()

exports.config = config
exports.log    = log
