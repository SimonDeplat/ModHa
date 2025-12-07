(
cmd: { |self, cmd, args = nil, time = nil|
	// Creating variables outside
	// of switch statement to preserve inlining
	var variable;

	switch(cmd)
	{ \addPlayer } {
		variable = ~mh.addPlayer;
		variable
	}
	{ \doPlay } {
		// args[0] is players ID, String or Symbol
		args[0] = args[0].asSymbol;
		args[0].postln;
		~mh[\players][args[0]].doPlay;
	}
	{ \doStop } {
		// args[0] is players ID, String or Symbol
		args[0] = args[0].asSymbol;
		~mh[\players][args[0]].doPlay;
	}
	{ \quit } {
		~mh.quit;
	};
},
)