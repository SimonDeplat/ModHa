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
		time =
		(Date().gmtime.rawSeconds
			- self[\referenceTime])
		.trunc(self[\timeTrunc]);
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
		self.updateRemoteClients(
			"/mhAddPlayer",
			time,
			variable.getDatas
		);
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
			self.updateRemoteClients(
				"/mhDoPlay",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\doPlay,
				time
			);
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
			self.updateRemoteClients(
				"/mhDoStop",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\doStop,
				time
			);
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
			self.updateRemoteClients(
				"/mhSetTuning",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\setTuning,
				time
			);
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
			self.updateRemoteClients(
				"/mhSetFreq",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\setFreq,
				time
			);
		};
	}
	{ \setScale } {
		// [playerID, scale]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\setScale,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].setScale(args[1]);
			self.updateRemoteClients(
				"/mhSetScale",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\setScale,
				time
			);
		};
	}
	{ \setPlayIters } {
		// [playerID, nCycles]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\setPlayIters,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].setPlayIters(args[1]);
			self.updateRemoteClients(
				"/mhSetPlayIters",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\setPlayIters,
				time
			);
		};
	}
	{ \setPlayFirstBeat } {
		// [playerID, boolean]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\setPlayFirstBeat,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].setPlayIters(args[1]);
			self.updateRemoteClients(
				"/mhSetPlayFirstBeat",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\setPlayFirstBeat,
				time
			);
		};
	}
	{ \setNCycles } {
		// [playerID, nBeats]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\setNCycles,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].setNCycles(args[1]);
			self.updateRemoteClients(
				"/mhSetNCycles",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\setNCycles,
				time
			);
		};
	}
	{ \setNBeats } {
		// [playerID, nBeats]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\setNBeats,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].setNBeats(args[1]);
			self.updateRemoteClients(
				"/mhSetNBeats",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\setNBeats,
				time
			);
		};
	}
	{ \setNSubs } {
		// [playerID, nSubs]
		if(bypassTimeCheck.not) {
			obsolete = self.checkCmdTime(
				args[0].asSymbol,
				\setNSubs,
				time
			);
		};
		if(obsolete.not) {
			~mh[\players][args[0].asSymbol].setNSubs(args[1]);
			self.updateRemoteClients(
				"/mhSetNSubs",
				time,
				args
			);
			self.updateTimeCheck(
				args[0].asSymbol,
				\setNSubs,
				time
			);
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
				addr.sendMsg(
					"/mhHandshake",
					self[\referenceTime],
					self[\timeTrunc]
				);
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
				self.cmd(
					\addPlayer,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhDoPlay", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				self.cmd(
					\doPlay,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhDoStop", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				self.cmd(
					\doStop,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhSetPlayIters", { |msg|
				// [playerID, nCycles]
				self.sliceMsg(msg);
				self.cmd(
					\setPlayIters,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhSetPlayFirstBeat", { |msg|
				// [playerID, boolean]
				self.sliceMsg(msg);
				self.cmd(
					\setPlayFirstBeat,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhSetTuning", { |msg|
				// [playerID, freq]
				self.sliceMsg(msg);
				self.cmd(
					\setTuning,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhSetFreq", { |msg|
				// [playerID, freq]
				self.sliceMsg(msg);
				self.cmd(
					\setFreq,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhSetScale", { |msg|
				// [playerID, scale]
				self.sliceMsg(msg);
				self.cmd(
					\setScale,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhSetNCycles", { |msg|
				// [playerID, nCycles]
				self.sliceMsg(msg);
				self.cmd(
					\setNCycles,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhSetNBeats", { |msg|
				// [playerID, nBeats]
				self.sliceMsg(msg);
				self.cmd(
					\setNBeats,
					self[\msgArgs],
					self[\msgTime]
				);
			},
		],
		[
			"/mhSetNSubs", { |msg|
				// [playerID, nSubs]
				self.sliceMsg(msg);
				self.cmd(
					\setNSubs,
					self[\msgArgs],
					self[\msgTime]
				);
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
	self[\msgTime] = msg[1];
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
	self[\timeChecks][id] = ();
	[
		\doPlay, \doStop,
		\setPlayIters, \setPlayFirstBeat,
		\setTuning, \setFreq, \setScale,
		\setNCycles, \setNBeats, \setNSubs,
	].do({ |symbol|
		self[\timeChecks][id][symbol] = 0
	});
},
rmPlayerTimeChecks: { |self, id|
	self[\timeChecks].removeAt(id);
},

timeTrunc: 0.001,
referenceTime: 0,
defineReferenceTime: { |self|
	self[\referenceTime] =
	Date().gmtime.rawSeconds.trunc(1).asInteger;
},
)