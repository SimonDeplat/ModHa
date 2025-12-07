(
cmd: { |self, cmd, args = nil, time = nil|
	// Creating variables outside
	// of switch statement to preserve inlining
	var variable;

	switch(cmd)
	{ \addPlayer } {
		variable = ~mh.addPlayer;
		self.updateRemoteClients(cmd, time, args);
		variable
	}
	{ \doPlay } {
		// args[0] is players ID, String or Symbol
		args[0] = args[0].asSymbol;
		args[0].postln;
		~mh[\players][args[0]].doPlay;
		self.updateRemoteClients(cmd, time, args);
	}
	{ \doStop } {
		// args[0] is players ID, String or Symbol
		args[0] = args[0].asSymbol;
		~mh[\players][args[0]].doPlay;
		self.updateRemoteClients(cmd, time, args);
	}
	{ \quit } {
		~mh.quit;
	};
},

updateRemoteClients: { |self, cmd, time, args|
	var msg;
	cmd = "/" ++ cmd.asString;
	msg = [cmd];
	msg = msg ++ [time];
	msg = msg ++ [args];
	self.remoteClients.do({ |addr|
		addr.sendMsg(*msg);
	});
},

openNetwork: { |self|
	var oscReceiver = OSCFunc.newMatching(
		{ |msg, time, addr, port|
			// Check if not connected yet
			var match = false;
			self[\remoteClients].do({ |netAddr|
				if(netAddr.localIP == addr.localIP) {
					match = true;
				};
			});
			if(match.not) {
				self[\remoteClients].add(addr);
				addr.sendMsg("/mhHandshake");
			};
		},
		"/mhConnect"
	);
	~mh[\networkIsOpen] = true;
},
remoteClients: List(0),
)