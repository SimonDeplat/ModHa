(
cmd: { |self, cmd, args = nil, playerID = nil, time = nil|
	var player;
	if(playerID.notNil) {
		player = ~mh[\players][playerID];
	} {
		player = ~mh[\defaultPlayer];
		playerID = player[\id];d
	};

	if(player.notNil) {
		switch(cmd)
		{ \doPlay } {
			player.doPlay;
		}
		{ \doStop } {
			player.doStop;
		};
	};
},
)