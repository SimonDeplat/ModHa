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
	self[\id] = nil;
	self[\isPlaying] = false;
	// Register globally
	~mh.registerPlayer(self);
	"Remote player added".postln;
	self
},
)