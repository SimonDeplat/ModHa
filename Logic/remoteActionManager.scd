(
connectToHost: { |self, ip, port = 57120|
	NetAddr(ip, port).sendMsg("/mhConnect");
	OSCFunc.newMatching(
		{ "Connection successful!".postln },
		"/mhHandshake",
		NetAddr(ip, port)
	).oneShot;
},

init: { |self|
	[
		[
			"/addPlayer", { |msg|
				// [playerID]
				var player;
				self.sliceMsg(msg);
				self[\msgArgs].postln;
				player = ~mh.addRemotePlayer;
				player.setID(self[\msgArgs][0]);
			},
		],
		[
			"/doPlay", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				~mh[\players][self[\msgArgs][0].asSymbol].doPlay;
			},
		],
		[
			"/doStop", { |msg|
				// [playerID]
				self.sliceMsg(msg);
				~mh[\players][self[\msgArgs][0].asSymbol].doStop;
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