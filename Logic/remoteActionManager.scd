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
	// Note that this doesn't work for collection arguments
	if(args.isKindOf(Collection).not) {
		args = [args];
	};

	if(self[\connected]) {
		switch(cmd)
		{ \addPlayer } {
			self[\host].sendMsg(*(["/mhAddPlayer", time] ++ args));
		}
		{ \doPlay } {
			self[\host].sendMsg(*(["/mhDoPlay", time] ++ args));
		}
		{ \doStop } {
			self[\host].sendMsg(*(["/mhDoStop", time] ++ args));
		}
		{ \setFreq } {
			self[\host].sendMsg(*(["/mhSetFreq", time] ++ args));
		}
		{ \quit } {
			~mh.quit;
		};
	} {
		"Not connected to host.".warn;
	};
},

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
				~mh[\players][self[\msgArgs][0].asSymbol].doPlay;
			},
		],
		[
			"/mhDoStop", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				~mh[\players][self[\msgArgs][0].asSymbol].doStop;
			},
		],
		[
			"/mhSetFreq", { |msg|
				// [playerID, freq]
				self.sliceMsg(msg);
				~mh[\players][self[\msgArgs][0].asSymbol].setFreq(
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