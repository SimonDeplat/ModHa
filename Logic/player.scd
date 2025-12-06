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
	self[\isPlaying] = false;
	self
},
)