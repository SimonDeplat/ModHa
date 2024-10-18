(
setSynth: { |self, synth|
	self.disconnectSynth;
	self[\synth] = synth;
	self[\view].action_({ |index, value|
		synth.setTrigger(index, value); });
	self[\triggerFunc] = {
		self[\view].values_(synth[\triggers]);
	};
	synth.addUINotification(
		\trigger,
		self[\triggerFunc]
	);
	self[\triggerFunc].value;
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmUINotification(
			\trigger,
			self[\triggerFunc]
		);
		self[\triggerFunc] = nil;
		self[\view].action_({});
		self[\synth] = nil;
	};
},

setPlayer: { |self, player|
	self.disconnectPlayer;
	self[\player] = player;
	self[\beatFunc] = {
		self[\view].beat_(self[\player][\actualBeat]);
	};
	self[\highlightsFunc] = {
		self[\view].highlights_(self[\player][\highlights]);
	};
	self[\beatFunc].value;
	self[\highlightsFunc].value;
	self[\player].addSignal(\beat, self[\beatFunc]);
	self[\player].addSignal(\highlights, self[\highlightsFunc]);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\beat, self[\beatFunc]);
		self[\player].rmSignal(\highlights, self[\highlightsFunc]);
		self[\player] = nil;
		self[\beatFunc] = nil;
		self[\highlightsFunc] = nil;
	};
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\view].style_(style);
},

init: { |self|
	self[\player] = nil;
	self[\synth] = nil;
	self[\view] = GMDuoSequencer()
	.actionMode_(\index);
	self
},
)