(
setStyle: { |self, style, smallStyle|
	self[\sequencer].style_(style);
},

disconnect: { |self|
	if(self[\synth].notNil
		and: { self[\uiFunc].notNil }) {
		self[\synth].rmUINotification(
			\trigger,
			self[\uiFunc]
		);
		self[\uiFunc] = nil;
	};
	self[\sequencer].action_({});
	self[\synth] = nil;
},

setBeat: { |self, beat|
	self[\sequencer].beat_(beat);
},

setHighlights: { |self, highlights|
	self[\sequencer].highlights_(highlights);
},

setSynth: { |self, synth|
	// Disconnect from previous synth
	self.disconnect;

	// Connect
	self[\synth] = synth;
	self[\sequencer].action_({ |index, value|
		synth.setTrigger(index, value); });
	self[\uiFunc] = {
		self[\sequencer].values_(
			synth[\triggers]; );
	};
	synth.addUINotification(
		\trigger,
		self[\uiFunc]
	);
	self[\uiFunc].value;
},

init: { |self|
	self[\view] = UserView();
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