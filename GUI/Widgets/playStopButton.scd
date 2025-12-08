(
//------//
// INIT //
init: { |self|
	self[\view] = GMPlayButton()
	.maxWidth_(192)
	.onClose_({
		if(self[\removed].not) {
			self[\view] = nil;
			self.doRemove;
		};
	});
	self[\player] = nil;
	self
},

//---------//
// METHODS //
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\view].setPlaying(player[\isPlaying]);
	self[\playFunction] = { self[\view].setPlaying(true); };
	self[\stopFunction] = { self[\view].setPlaying(false); };
	self[\view]
	.action_({ |isPlaying|
		if(isPlaying) {
			~mh.cmd(\doPlay, [self[\player][\id]])
		} {
			~mh.cmd(\doStop, [self[\player][\id]])
		};
	});
	self[\player].addSignal(\doPlay, self[\playFunction]);
	self[\player].addSignal(\doStop, self[\stopFunction]);
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\doPlay, self[\playFunction]);
		self[\player].rmSignal(\doStop, self[\stopFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\playFunction] = nil;
		self[\stopFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\view].action_({});
		self[\player] = nil;
	};
},

removed: false;
doRemove: { |self|
	self.disconnect;
	if(self[\view].notNil) {
		self[\removed] = true;
		self[\view].remove;
	};
	self.clear;
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].style_(style);
},
)