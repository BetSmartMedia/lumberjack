## LumberJack: Taming the logs

LumberJack is a very simple network-based log aggregator written in CoffeeScript for
NodeJS. It listens on a UDP port and logs messages to a SQLite3 database.

It also comes bundled with a very simple log viewer written in PHP. You are encouraged to
write better viewers (in better languages). If you do, please let me know so I can use it. :)


### Impetus

Medium-to-large websites require multiple servers, and application logs are typically
dumped to the filesystem of the server in question. This can make it difficult to get
a comprehensive view or your application's log files across all servers.  LumberJack
solves this.


### Security

Please note that LumberJack provides no security/authentication. It is up to you to
protect the UDP ports with a firewall or some other form of access control.


### Alternatives

Most Linux systems come with syslog-ng, or a variant thereof. These are far more
robust and capable logging facilities, and they are network-capable.

Personally, I like to keep my application-level logs separate from my system-level
logs. I also wanted something small and lightweight. Hence LumberJack.

