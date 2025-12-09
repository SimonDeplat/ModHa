(
host: nil,
connected: false,
connectToHost: { |self, ip, port = 57120|
	self[\host] = NetAddr(ip, port);
	self[\host].sendMsg("/mhConnect");
	OSCFunc.newMatching(
		{
			self[\connected] = true;
			if(~mh[\verbose]) {
				"Connection successful!".postln;
			};
		},
		"/mhHandshake",
		self[\host]
	).oneShot;
},

cmd: { |self, cmd, args = nil|
	// Time is not an argument on remote side
	var time = Date.gmtime.rawSeconds;

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

	if(self[\cmdPairs].includesKey(cmd) {
		// Remote commands
		if(self[\connected]) {
			self[\host].sendMsg(
				*([self[\cmdPairs][cmd], time] ++ args)
			);
		} {
			"Not connected to host.".warn;
		};
	} {
		// Local commands
		switch(cmd)
		{ \quit } {
			~mh.quit;
		};
	});
},
// Transforms a command name into
// an OSC address
cmdPairs: (
	addPlayer: "/mhAddPlayer",
	doPlay: "/mhDoPlay",
	doStop: "/mhDoStop",
	setTuning: "/mhSetTuning",
	setFreq: "/mhSetFreq",
),

init: { |self|
	[
		[
			"/mhAddPlayer", { |msg|
				// [playerID]
				var player;
				self.sliceMsg(msg);
				player = ~mh.addRemotePlayer;
				player.loadDatas(self[\msgArgs]);
			},
		],
		[
			"/mhDoPlay", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				~mh[\players][self[\msgArgs][0].asSymbol]
				.doPlay;
			},
		],
		[
			"/mhDoStop", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				~mh[\players][self[\msgArgs][0].asSymbol]
				.doStop;
			},
		],
		[
			"/mhSetTuning", { |msg|
				// [playerID, freq]
				self.sliceMsg(msg);
				~mh[\players][self[\msgArgs][0].asSymbol]
				.setTuning(
					self[\msgArgs][1]
				);
			},
		],
		[
			"/mhSetFreq", { |msg|
				// [playerID, freq]
				self.sliceMsg(msg);
				~mh[\players][self[\msgArgs][0].asSymbol]
				.setFreq(
					self[\msgArgs][1]
				);
			},
		],
	].do({ |pair|
		OSCFunc.newMatching(pair[1], pair[0]);
	});
},

msgTime: nil,
msgArgs: nil,
sliceMsg: { |self, msg|
	self[\msgTime] = msg[0];
	self[\msgArgs] = msg.copyRange(2, msg.size);
},
)