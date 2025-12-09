(
cmd: { |self, cmd, args = nil, time = nil|
	var bypassTimeCheck = false;
	var obsolete = false;
	// Creating variables outside
	// of switch statement to preserve inlining
	var variable;

	// Reference time if not specified
	// If already specified, this means
	// it is a remote command
	// (and we check if it is obsolete)
	if(time.isNil) {
		bypassTimeCheck = true;
		time = Date.gmtime.rawSeconds;
	};

	// Safety
	if(args.isNil) {
		args = [];
	};

	// player.cmd(\setFreq, 330)
	// is converted to
	// player.cmd(\setFreq, [330])
	// Note that this doesn't work for Array arguments,
	// which need to be checked within
	// the dispatcher function itself
	if(args.isKindOf(Array).not) {
		args = [args];
	};

	switch(cmd)
	{ \addPlayer } {
		// []
		variable = ~mh.addPlayer;
		self.updateRemoteClients("/mhAddPlayer", time, variable.getDatas);
		variable
	}
	{ \doPlay } {
		// [playerID]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\doPlay,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].doPlay;
			self.updateRemoteClients("/mhDoPlay", time, args);
			self.updateTimeCheck(args[0].asSymbol, \doPlay, time);
		};
	}
	{ \doStop } {
		// [playerID]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\doPlay,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].doStop;
			self.updateRemoteClients("/mhDoStop", time, args);
			self.updateTimeCheck(args[0].asSymbol, \doStop, time);
		};
	}
	{ \setTuning } {
		// [playerID, freq]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\setTuning,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].setTuning(args[1]);
			self.updateRemoteClients("/mhSetTuning", time, args);
			self.updateTimeCheck(args[0].asSymbol, \setTuning, time);
		};
	}
	{ \setFreq } {
		// [playerID, freq]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\setFreq,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].setFreq(args[1]);
			self.updateRemoteClients("/mhSetFreq", time, args);
			self.updateTimeCheck(args[0].asSymbol, \setFreq, time);
		};
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
				self.cmd(\addPlayer, self[\msgArgs], self[\msgTime]);
			},
		],
		[
			"/mhDoPlay", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				self.cmd(\doPlay, self[\msgArgs], self[\msgTime]);
			},
		],
		[
			"/mhDoStop", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				self.cmd(\doStop, self[\msgArgs], self[\msgTime]);
			},
		],
		[
			"/mhSetFreq", { |msg|
				// [playerID, freq]
				self.sliceMsg(msg);
				self.cmd(\setFreq, self[\msgArgs], self[\msgTime]);
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

timeChecks: (),
checkCmdTime: { |self, key, index, time|
	var obsolete = false;
	if(self[\timeChecks][key][index] >= time) {
		obsolete = true;
	};
	obsolete
},
updateTimeCheck: { |self, key, index, time|
	self[\timeChecks][key][index] = time;
},
addPlayerTimeChecks: { |self, id|
	self[\timeChecks][id] = (
		doPlay: 0,
		doStop: 0
	);
},
)