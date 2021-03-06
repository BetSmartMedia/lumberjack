#!node_modules/coffee-script/bin/coffee
#
# LumberJack server. Run this with the path to the config file.
#
# Example: ./server.coffee config/default.json
#

fs     = require "fs"
dgram  = require "dgram"
server = dgram.createSocket "udp4"
sqlite = require "sqlite3"
daemon = require "daemon"

if process.argv.length < 3
	console.log "Usage: #{process.argv[1]} <config>"
	process.exit 1
cfgfile = process.argv[2]

try
	cfgjson = fs.readFileSync cfgfile
	config = JSON.parse cfgjson

	# Defaults
	config.ignore_facilities ?= []
	config.ignore_priorities ?= []
catch e
	console.log "Error reading/parsing config:", e.message
	process.exit 1

# Check if database file exists
try
	s = fs.statSync config.db_path
catch e
	console.log "Error: Cannot read database file: #{config.db_path}"
	console.log "       #{e.message}\n"
	console.log "To create it: cat sql/log_messages.sql | sqlite3 #{config.db_path}\n"
	process.exit 1

# Become a daemon
daemon.daemonize config.log_file, config.pid_file, (err, pid) ->
	return console.log "Error starting daemon: #{err}" if err?
	console.log "Daemon started"

	# catch SIGTERM and remove PID file
	process.on 'SIGTERM', ->
		console.log "Caught SIGTERM; shutting down"
		fs.unlinkSync config.pid_file
		process.exit 0

	db = new sqlite.Database config.db_path

	server.on "listening", ->
		addr = server.address()
		console.log "listening on #{addr.address}:#{addr.port}"

	server.on "message", (msg, rinfo) ->
		#console.log "recv: #{msg} from #{rinfo.address}:#{rinfo.port}"

		# LJ's wire protocol is simple. There are 4 strings, delimited with NUL characters (\0).
		#
		# <host>\0<facility>\0<priority>\0<message>
		try
			parts = msg.toString("utf8").split "\0"
		catch e
			console.log "Error receiving log message: #{e.message}"
			return

		if not parts[3]
			#console.log "Log message is empty, ignoring..."
			return

		# Scrub against the ignore lists
		return if parts[1] in config.ignore_facilities
		return if parts[2] in config.ignore_priorities

		sql = "INSERT INTO log_messages (ip,host,facility,priority,message,created_on) VALUES (?,?,?,?,?,?)"
		data = [
			rinfo.address,
			parts[0] || "unknown",
			parts[1] || "general",
			parts[2] || "info",
			parts[3],
			parseInt (new Date).getTime() / 1000
		]

		# retry until success
		insert = ->
			db.run sql, data, (err) ->
				return unless err?
				console.log err.message, "(retrying in 1 second)"
				setTimeout insert 1000
		insert()

	server.bind config.listen_port, config.listen_ip

