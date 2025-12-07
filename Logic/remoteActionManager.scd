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
				"addPlayer cmd received".postln;
				msg.postln;
			},
		]
	].do({ |pair|
		OSCFunc.newMatching(pair[1], pair[0]);
	});
},
)