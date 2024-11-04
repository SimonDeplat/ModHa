(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\tempoFunction] =
	{ self[\view].value_(player[\tempo]); };
	self[\view].action_({ |value|
		player.setTempo(value.asInteger);
	});
	self[\tempoFunction].value;
	self[\player].addSignal(\tempo, self[\tempoFunction]);
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\tempo, self[\tempoFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\tempoFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\view].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].style_(widgetStyle);
},

doRemove: { |self|
	self.disconnect;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\player] = nil;
	self[\view] = GMSymbolSlider()
	.min_(20)
	.max_(200)
	.orientation_(\horizontal)
	.fontRatio_(0.333)
	.symbolMaxSize_(32)
	.displayFunction_({ |value|
		("bpm: " ++ value.asInteger.asString)
	});
	self
},
)