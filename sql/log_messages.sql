CREATE TABLE "log_messages" (
	"id" INTEGER PRIMARY KEY,

	-- ip address of sender
	"ip" VARCHAR(15) NOT NULL,

	-- hostname of sender
	"host" VARCHAR(255) NOT NULL,

	-- Facility/category of log message
	"facility" VARCHAR(255) NOT NULL,

	-- Priority of message (convention is one of: debug/info/warning/error)
	"priority" VARCHAR(255) NOT NULL,
	
	"message" TEXT NOT NULL,

	-- Unix timestamp
	"created_on" INTEGER UNSIGNED NOT NULL
) /*! DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci */;

CREATE INDEX "log_messages.host" ON "log_messages" ("host");
CREATE INDEX "log_messages.facility" ON "log_messages" ("facility");
CREATE INDEX "log_messages.priority" ON "log_messages" ("priority");
CREATE INDEX "log_messages.created_on" ON "log_messages" ("created_on");
