(
cmd: { |self, cmd, args = nil, time = nil|
	// Creating variables outside
	// of switch statement to preserve inlining
	var variable;

	switch(cmd)
	{ \addPlayer } {
		variable = ~mh.addPlayer;
		// Passes only player's ID
		// FIXME: this implies both player's configuration
		// is the same, so it should pass every state parameters !
		self.updateRemoteClients("addPlayer", time, [variable[\id].asString]);
		variable
	}
	{ \doPlay } {
		~mh[\players][args[0]].doPlay;
		self.updateRemoteClients(cmd, time, args);
	}
	{ \doStop } {
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
		addr.sendMsg(cmd, time, args);
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