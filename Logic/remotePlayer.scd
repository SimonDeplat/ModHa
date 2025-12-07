(
doPlay: { |self|
	self[\isPlaying] = true;
	"Playing".postln;
},

doStop: { |self|
	self[\isPlaying] = false;
	"Stopped".postln;
},

init: { |self|
	// State
	self[\isPlaying] = false;
	self
},

// Remote player isn't registered
// until its ID is specified
setID: { |self, id|
	self[\id] = id;
	// Register globally
	~mh.registerPlayer(self);
	if(~mh[\verbose]) {
		(
			"Player "
			++ self[\id].asString
			++ " added"
		).postln;
	};
},
)