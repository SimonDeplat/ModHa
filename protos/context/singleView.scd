(
setSynth: { |self, synth|
	if(self[\synth].isNil) {
		if(synth[\type] != \effect) {
			self[\synthView].setSynth(synth);
			if(synth[\tunable].not)
			{ self[\playerView].hideTuning; };
			if(synth[\type] == \continuous)
			{ self[\playerView].hideRythm; };
			// /!\ TO DO: hide tempo slider if needed
			self[\synth] = synth;
			self[\window].name_(synth[\name]);
			self[\synthRMFunction] = { self.disconnectSynth; };
			self[\synth].addSignal(\remove, self[\synthRMFunction]);
		} {
			"ModHa: singleView: effect synth unsupported".warn;
		};
	} {
		"ModHa: singleView: synth reassignment unsupported".warn;
	};
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(\remove, self[\synthRMFunction]);
		self[\synthRMFunction] = nil;
		self[\synth] = nil;
	};
},

setPlayer: { |self, player|
	if(self[\player].isNil) {
		self[\playerView].setPlayer(player);
		self[\synthView].setPlayer(player);
		self[\player] = player;
	} {
		"ModHa: singleView: player reassignment unsupported".warn;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\playerView].setStyles(
		style,
		textStyle,
		widgetStyle
	);
},

doFront: { |self| self[\window].front; },

doRemove: { |self|
	if(self[\synth].notNil)
	{ self[\synth].doRemove; };
	if(self[\player].notNil)
	{ self[\player].doRemove; };
	self[\synthView].doRemove;
	self[\playerView].doRemove;
	self[\window].view.removeAll;
	self[\window].view.remove;
	self.clear;
},

init: { |self|
	self[\synth] = nil;
	self[\player] = nil;
	self[\window] = Window(
		"ModHa - SingleView",
		Rect(
			Window.screenBounds.width * 0.1,
			Window.screenBounds.height * 0.1,
			Window.screenBounds.width * 0.8,
			Window.screenBounds.height * 0.8
		);
	)
	.acceptsMouseOver_(true);
	self[\playerView] = ~gmDef.getMiniPlayerView;
	self[\synthView] = ~gmDef.getSynthView;
	self[\synthView].hideOut;
	self[\synthView].hideRemove;
	// Layout
	self[\window].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\playerView][\view], 1)
		.add(self[\synthView][\view], 9)
	);
	self[\window].onClose_({ self.doRemove; });
	//CmdPeriod.doOnce({ self[\window].postln; self[\window].close; });
	self
},
)