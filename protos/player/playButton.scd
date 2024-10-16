(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\view].setPlaying(player[\isPlaying]);
	self[\playFunction] = { self[\view].setPlaying(true); };
	self[\stopFunction] = { self[\view].setPlaying(false); };
	self[\view]
	.action_({ |isPlaying|
		if(isPlaying)
		{ player.doPlay; }
		{ player.doStop; };
	});
	self[\player].addSignal(\play, self[\playFunction]);
	self[\player].addSignal(\stop, self[\stopFunction]);	
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\play, self[\playFunction]);
		self[\player].rmSignal(\stop, self[\stopFunction]);
		self[\playFunction] = nil;
		self[\stopFunction] = nil;
		self[\view].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle|
	self[\view].setStyle_(style);
},

doRemove: { |self|
	self.disconnect;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\view] = GMPlayButton()
	.maxWidth_(192);
	self[\player] = nil;
	self
},
)