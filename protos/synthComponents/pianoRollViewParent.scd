(
setStyle: { |self, style, smallStyle|
	self[\pianoRoll].style_(style);
},

disconnect: { |self|
	if(self[\synth].notNil
		and: { self[\uiFunc].notNil }) {
		self[\synth].rmUINotification(
			\freqs,
			self[\uiFunc]
		);
		self[\uiFunc] = nil;
	};
	self[\pianoRoll].action_({});
	self[\synth] = nil;
},

setBeat: { |self, beat|
	self[\pianoRoll].beat_(beat);
},

setHighlights: { |self, highlights|
	self[\pianoRoll].highlights_(highlights);
},

setVHighlights: { |self, vHighlights|
	self[\vHighlights] = vHighlights;
	self.adaptVHighlights;
},

adaptVHighlights: { |self|
	if(self[\vHighlights].notNil) {
		var vHighlights = self[\vHighlights].deepCopy;

		if(self[\range][0] < 0) {
			vHighlights =
			self[\vHighlights].copyRange(
				self[\vHighlights].size
				- self[\range][0].abs,
				self[\vHighlights].size
			)
			++ vHighlights;
		};

		vHighlights = vHighlights
		++ self[\vHighlights].copyRange(0, self[\range][1]);

		self[\pianoRoll].vHighlights_(vHighlights);
		vHighlights.clear;
	};
},

range: [0, 0],
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

	self.adaptVHighlights;
},

setSynth: { |self, synth|
	var range = [0, 0];
	// Disconnect from previous synth
	self.disconnect;

	// Connect
	self[\synth] = synth;

	self[\pianoRoll].action_({ |index, value|
		synth.setFreq(index, value); });

	self[\uiFunc] = {
		self[\pianoRoll].values_(
			synth[\freqs]; );
	};

	synth.addUINotification(
		\freqs,
		self[\uiFunc]
	);

	if(~gmDef[\gmDefs][synth[\synthName].asSymbol]
		.includesKey(\pianoRollRange))
	{ range = ~gmDef[\gmDefs]
		[synth[\synthName].asSymbol][\pianoRollRange]; };

	if(self[\range] != range)
	{ self.setRange(range); };

	self[\uiFunc].value;

	range.clear;
},
)