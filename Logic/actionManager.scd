(
cmd: { |self, cmd, args = nil, time = nil|
	// Creating variables outside
	// of switch statement to preserve inlining
	var variable;

	switch(cmd)
	{ \addPlayer } {
		variable = ~mh.addPlayer;
		self.updateRemoteClients("/mhAddPlayer", time, [variable[\id].asString]);
		variable
	}
	{ \doPlay } {
		~mh[\players][args[0]].doPlay;
		self.updateRemoteClients("/mhDoPlay", time, args);
	}
	{ \doStop } {
		self.updateRemoteClients("/mhDoStop", time, args);
	}
	{ \quit } {
		~mh.quit;
	};
},

updateRemoteClients: { |self, cmd, time, args = nil|
	var msg;
	msg = [cmd];
	msg = msg ++ [time];
	msg = msg ++ args;
	self.remoteClients.do({ |addr|
		addr.sendMsg(*msg);
	});
},

openNetwork: { |self|
	// Enable handshake protocol
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
				if(~mh[\verbose]) {
					"Remote connection detected".postln;
				};
			};
		},
		"/mhConnect"
	);
	~mh[\networkIsOpen] = true;

	// Enable OSCFunc dispatch
	[
		[
			"/mhAddPlayer", { |msg|
				// []
				self.sliceMsg(msg);
				self.cmd(\addPlayer, nil, self[\msgTime]);
			},
		],
		[
			"/mhDoPlay", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				self.cmd(\doPlay, [self[\msgArgs][0].asSymbol], self[\msgTime]);
			},
		],
		[
			"/mhDoStop", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				self.cmd(\doStop, [self[\msgArgs][0].asSymbol], self[\msgTime]);
			},
		],
	].do({ |pair|
		OSCFunc.newMatching(pair[1], pair[0]);
	});
},
remoteClients: List(0),

msgTime: nil,
msgArgs: nil,
sliceMsg: { |self, msg|
	self[\msgTime] = msg[0];
	self[\msgArgs] = msg.copyRange(2, msg.size);
},
)