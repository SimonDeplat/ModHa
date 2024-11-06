(
setSynth: { |self, synth|
	var range = [0, 0];
	self.disconnectSynth;
	self[\synth] = synth;
	self[\pianoRoll].action_({ |index, value|
		synth.setFreq(index, value); });
	self[\freqFunc] = {
		self[\pianoRoll].values_(synth[\freqs]; );
	};
	synth.addSignal(\freqs, self[\freqFunc]);
	if(~gmDef[\gmDefs][synth[\synthName].asSymbol]
		.includesKey(\pianoRollRange))
	{ range = ~gmDef[\gmDefs]
		[synth[\synthName].asSymbol][\pianoRollRange]; };
	if(self[\range] != range)
	{ self.setRange(range); };
	self[\freqFunc].value;
	range.clear;
	self[\synthRMFunction] = { self.disconnectSynth; };
	self[\synth].addSignal(\remove, self[\synthRMFunction]);
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(\freqs, self[\freqFunc]);
		self[\synth].rmSignal(\remove, self[\synthRMFunction]);
		self[\pianoRoll].action_({});
		self[\synth] = nil;
		self[\freqFunc] = nil;
		self[\synthRMFunction] = nil;
	};
},

setPlayer: { |self, player|
	self.disconnectPlayer;
	self[\player] = player;
	self[\beatFunc] = {
		if(self[\synth].notNil) {
			self[\pianoRoll].beat_(
				player[\actualBeat] % self[\synth][\freqs].size);
		} {
			self[\pianoRoll].beat_(
				player[\actualBeat] % player[\nBeats]);
		};
	};
	self[\beatFunc].value;
	player.addSignal(\beat, self[\beatFunc]);
	self[\highlightsFunc] = { self[\pianoRoll].highlights_(player[\highlights]); };
	self[\highlightsFunc].value;
	player.addSignal(\highlights, self[\highlightsFunc]);
	self[\vHighlightsFunc] = { self.updateVHighlights; };
	self[\vHighlightsFunc].value;
	player.addSignal(\vHighlights, self[\vHighlightsFunc]);
	self[\playerRMFunction] = { self.disconnectPlayer; };
	player.addSignal(\remove, self[\playerRMFunction]);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\beat, self[\beatFunc]);
		self[\player].rmSignal(\highlights, self[\highlightsFunc]);
		self[\player].rmSignal(\vHighlights, self[\vHighlightsFunc]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\player] = nil;
		self[\beatFunc] = nil;
		self[\highlightsFunc] = nil;
		self[\vHighlightsFunc] = nil;
		self[\playerRMFunction] = nil;
	};
},

updateVHighlights: { |self|
	if(self[\player].notNil) {
		var vHighlights = self[\player][\vHighlights].deepCopy;
		if(self[\range][0] < 0) {
			vHighlights =
			self[\player][\vHighlights].copyRange(
				self[\player][\vHighlights].size
				- self[\range][0].abs,
				self[\player][\vHighlights].size
			)
			++ vHighlights;
		};
		vHighlights = vHighlights
		++ self[\player][\vHighlights].copyRange(0, self[\range][1]);
		self[\pianoRoll].vHighlights_(vHighlights);
		vHighlights.clear;
	};
},

setRange: { |self, range|
	var nNotes = 8;
	self[\range].clear;
	self[\range] = range;
	if(self[\player].notNil)
	{ nNotes = self[\player][\scaleFreqs].size + 1; };
	self[\pianoRoll].entries_(
		Array.series(
			(range[0].abs + nNotes + range[1]),
			range[0]
		);
	);
	self.updateVHighlights;
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\pianoRoll].style_(style);
},

doRemove: { |self|
	self.disconnectSynth;
	self.disconnectPlayer;
	self[\range].clear;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\player] = nil;
	self[\synth] = nil;
	self[\range] = [0, 0];
	self[\vHighlights] = nil;
	self[\view] = UserView();
	self[\pianoRoll] = GMListPianoRoll()
	.actionMode_(\index);
	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\pianoRoll])
	);
	self
},
)