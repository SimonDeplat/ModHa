(
~mh[\conductor] = (
	// Tuning keys
	rootFreq: 440,
	freq: 440,
	diapason: 440,
	scale: \minor,
	rootNote: "A",
	note: "A",
	chord: "-",
	degree: "I",
	// Rythm keys
	bpm: 60,
	absTime: 0,
	currentSection: 0,
	maxSection: 0,
	currentCycle: 0,
	maxCycle: inf,
	currentBeat: 0,
	maxBeat: 4,
	currentSub: 0,
	maxSub: 4,
	// Internals
	// Freq related
	isModal: true,
	isTonal: true,
	userRootNote: "A",
	userNote: "A",
	audibleRange: [20, 20000],
	// Clock relate,
	mainClock: TempoClock(),
	playing: false,
	isDumpTime: false,
	paused: false,

	// Methods

	// Freq & Scale
	setRootFreq: { |self, freq|
		self[\rootFreq] = freq;
	},
	
	setFreq: { |self, freq|
		self[\freq] = freq;
	},

	setDiapason: { |self, diapason|
		self[\diapason] = diapason;
		// setDiapason should always be called
		// when isModal anyway
		if(self[\isModal]) {
			self.setRootFreqFromNote;
			self.setFreqFromNote;
		};
	},

	tune: { |self, freq|
		// Polymorphism allows to tune
		// either single frequencies
		// or arrays of frequencies
		freq = freq * (self[\diapason] / 440);
		freq
	},

	setNote: { |self, note|
		self[\userNote] = note;
		switch(note.asSymbol)
		{ "A#".asSymbol } { self[\note] = "Bb"; }
		{ "B#".asSymbol } { self[\note] = "C"; }
		{ "C#".asSymbol } { self[\note] = "Db"; }
		{ "D#".asSymbol } { self[\note] = "Eb"; }
		{ "E#".asSymbol } { self[\note] = "F"; }
		{ "F#".asSymbol } { self[\note] = "Gb"; }
		{ "G#".asSymbol } { self[\note] = "Ab"; }
		{ self[\note] = note; };
		// setNote should always be called
		// when isModal anyway
		if(self[\isModal])
		{ self.setFreqFromNote(self[\note]); };
	},

	setRootFreqFromRootNote: { |self|
		// Starting from A, 440HZ
		var freqs = (69..80).midicps;
		// Tuning to current diapason
		freqs = self.tune(freqs);
		switch(self[\rootNote].asSymbol)
		{ \A } { self.setRootFreq(freqs[0]); }
		{ \Bb } { self.setRootFreq(freqs[1]); }
		{ \B } { self.setRootFreq(freqs[2]); }
		{ \C } { self.setRootFreq(freqs[3]); }
		{ \Db } { self.setRootFreq(freqs[4]); }
		{ \D } { self.setRootFreq(freqs[5]); }
		{ \Eb } { self.setRootFreq(freqs[6]); }
		{ \E } { self.setRootFreq(freqs[7]); }
		{ \F } { self.setRootFreq(freqs[8]); }
		{ \Gb } { self.setRootFreq(freqs[9]); }
		{ \G } { self.setRootFreq(freqs[10]); }
		{ \Ab } { self.setRootFreq(freqs[11]); }
		{ "Conductor : invalid root note name".warn; };
	},
	
	setFreqFromNote: { |self|
		// Starting from A, 440HZ
		var freqs = (69..80).midicps;
		// Tuning to current diapason
		freqs = self.tune(freqs);
		switch(self[\note].asSymbol)
		{ \A } { self.setFreq(freqs[0]); }
		{ \Bb } { self.setFreq(freqs[1]); }
		{ \B } { self.setFreq(freqs[2]); }
		{ \C } { self.setFreq(freqs[3]); }
		{ \Db } { self.setFreq(freqs[4]); }
		{ \D } { self.setFreq(freqs[5]); }
		{ \Eb } { self.setFreq(freqs[6]); }
		{ \E } { self.setFreq(freqs[7]); }
		{ \F } { self.setFreq(freqs[8]); }
		{ \Gb } { self.setFreq(freqs[9]); }
		{ \G } { self.setFreq(freqs[10]); }
		{ \Ab } { self.setFreq(freqs[11]); }
		{ "Conductor : invalid note name".warn; };
	},

	setScale: { |self, scale|
		if(Scale.directory.includes(scale)) {
			self[\scale] = scale;
		} {
			"Conductor : invalid scale symbol".warn;
		};
	},

	setModal: { |self, aBoolean|
		self[\isModal] = aBoolean;
		// isModal == false implies isTonal == false
		if(aBoolean.not)
		{ qself[\isTonal] = false; };
	},

	setTonal: { |self, aBoolean|
		self[\isTonal] = aBoolean;
		// isTonal == true implies isModal == true
		if(aBoolean) { self[\isModal] = true; };
	},

	// Clock & Rythm
	startClock: { |self|
		self[\mainClock].play({
			self.tick;
			// Return 1 to keep looping
			1
		});
		self[\playing] = true;
	},

	stopClock: { |self|
		self[\mainClock].clear;
		self.resetTime;
		self[\playing] = false;
		self[\paused] = false;
	},

	resetTime: { |self|
		self[\absTime] = 0;
		self[\currentSection] = 0;
		self[\currentCycle] = 0;
		self[\currentBeat] = 0;
		self[\currentSub] = 0;
		self[\subInCycle] = 0;
	},

	tick: { |self|
		if(self[\paused].not) {
			self.playScore;
			self.advance;
			if(self[\isDumpTime])
			{ self.dumpTime; };
		};
	},

	advance: { |self|
		self[\absTime] = self[\absTime] + 1;
		self[\currentSub] = self[\currentSub] + 1;
		if(self[\currentSub] >= self[\maxSub]) {
			self[\currentSub] = 0;
			self[\currentBeat] = self[\currentBeat] + 1;
			if(self[\currentBeat] >= self[\maxBeat]) {
				self[\currentBeat] = 0;
				self[\currentCycle] = self[\currentCycle] + 1;
				if(self[\currentCycle] >= self[\maxCycle]) {
					self[\currentCycle] = 0;
					self[\currentSection] = self[\currentSection] + 1;
					if(self[\currentSection] >= self[\maxSection]) {
						self[\currentSection] = 0;
					};
				};
			};
		};
		self.getSubInCycle;
	},

	getSubInCycle: { |self|
		self[\subInCycle] =
		(self[\maxSub] * self[\currentBeat])
		+ self[\currentSub];
	},

	playScore: { |self|
		
	},

	dumpTime: { |self|
		"Time : ".post;
		self[\currentSection].post;
		" ".post;
		self[\currentCycle].post;
		" ".post;
		self[\currentBeat].post;
		" ".post;
		self[\currentSub].post;
		" / ".post;
		self[\absTime].postln;
	},

	setDumpTime: { |self, aBoolean|
		self[\isDumpTime] = aBoolean;
	},

	doPause: { |self|
		self[\paused] = true;
	},

	doResume: { |self|
		self[\paused] = false;
	},
	
);
)