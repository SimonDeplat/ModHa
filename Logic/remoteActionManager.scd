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

cmd: { |self, cmd, args = nil, time = nil|
	if(self[\connected]) {
		switch(cmd)
		{ \addPlayer } {
			self[\host].sendMsg("/mhAddPlayer", time, nil);
		}
		{ \doPlay } {
			self[\host].sendMsg("/mhDoPlay", time, args);
		}
		{ \doStop } {
			self[\host].sendMsg("/mhDoStop", time, args);
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
				player.setID(self[\msgArgs][0].asSymbol);
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