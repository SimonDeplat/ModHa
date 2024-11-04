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
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\play, self[\playFunction]);
		self[\player].rmSignal(\stop, self[\stopFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\playFunction] = nil;
		self[\stopFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\view].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].style_(style);
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