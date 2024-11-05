(
setSynth: { |self, synth|
	self.disconnectSynth;
	self[\synth] = synth;
	self[\view].action_({ |index, value|
		synth.setTrigger(index, value); });
	self[\triggerFunc] = {
		self[\view].values_(synth[\triggers]);
	};
	synth.addSignal(\trigger, self[\triggerFunc]);
	self[\triggerFunc].value;
	self[\synthRMFunction] = { self.disconnectSynth; };
	self[\synth].addSignal(\remove, self[\synthRMFunction]);
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(\trigger, self[\triggerFunc]);
		self[\synth].rmSignal(\remove, self[\synthRMFunction]);
		self[\view].action_({});
		self[\synth] = nil;
		self[\triggerFunc] = nil;
		self[\synthRMFunction] = nil;	
	};
},

setPlayer: { |self, player|
	self.disconnectPlayer;
	self[\player] = player;
	self[\beatFunc] = {
		if(self[\synth].notNil) {
			self[\view].beat_(
				player[\actualBeat] % self[\synth][\triggers].size);
		} {
			self[\view].beat_(
				player[\actualBeat] % player[\nBeats]);
		};
	};
	self[\highlightsFunc] = {
		self[\view].highlights_(self[\player][\highlights]);
	};
	self[\beatFunc].value;
	self[\highlightsFunc].value;
	self[\player].addSignal(\beat, self[\beatFunc]);
	self[\player].addSignal(\highlights, self[\highlightsFunc]);
	self[\playerRMFunction] = { self.disconnectPlayer; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\beat, self[\beatFunc]);
		self[\player].rmSignal(\highlights, self[\highlightsFunc]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\player] = nil;
		self[\beatFunc] = nil;
		self[\highlightsFunc] = nil;
		self[\playerRMFunction] = nil;
	};
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\view].style_(style);
},

doRemove: { |self|
	self.disconnectSynth;
	self.disconnectPlayer;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\player] = nil;
	self[\synth] = nil;
	self[\view] = GMDuoSequencer()
	.actionMode_(\index);
	self
},
)