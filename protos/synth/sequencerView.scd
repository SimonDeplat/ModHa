(
setSynth: { |self, synth|
	self.disconnectSynth;
	self[\synth] = synth;
	self[\sequencer].action_({ |index, value|
		synth.setTrigger(index, value); });
	self[\triggerFunc] = {
		self[\sequencer].values_(synth[\triggers]);
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
		self[\sequencer].action_({});
		self[\synth] = nil;
	};
},

setPlayer: { |self, player|
	self.disconnectPlayer;
	self[\player] = player;
	self[\beatFunc] = {
		self[\sequencer].beat_(self[\player][\actualBeat]);
	};
	self[\highlightsFunc] = {
		self[\sequencer].highlights_(self[\player][\highlights]);
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
	self[\sequencer].style_(style);
},

init: { |self|
	self[\view] = UserView();
	self[\player] = nil;
	self[\synth] = nil;
	self [\sequencer] = GMDuoSequencer()
	.actionMode_(\index);
	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\sequencer])
	);
},
)