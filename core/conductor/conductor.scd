(
~mh[\conductor] = (
	// Tuning keys
	freq: 440,
	diapason: 440,
	scale: \minor,
	note: "A",
	chord: "-",
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
	isTonal: true,
	userNote: "A",
	// Clock related
	mainClock: TempoClock(),
	playing: false,
	isDumpTime: false,
	paused: false,

	// Methods

	// Freq & Scale
	setFreq: { |self, freq|
		self[\freq] = freq;
	},

	setDiapason: { |self, diapason|
		self[\diapason] = diapason;
		// setDiapason should always be called
		// when isTonal anyway
		if(self[\isTonal])
		{ self.setFreqFromNote; };
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
	},

	setFreqFromNote: { |self|
		// Starting from A, 440HZ
		var freqs = (69..80).midicps;
		// Tuning to current diapason
		freqs = standardFreqs * (self[\diapason] / 440);
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

	// Clock & Rythm
	startClock: { |self|
		self[\mainClock].play({
			if(self[\paused].not)
			{ self.tick; };
			// Return 1 to keep looping
			1
		});
		self[\playing] = true;
	},

	stopClock: { |self|
		self[\mainClock].clear;
		self.resetTime;
		self[\playing] = false;
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
		self.playScore;
		self.advance;
		if(self[\isDumpTime])
		{ self.dumpTime; };
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

	pause: { |self|
		self[\paused] = true;
	},

	resume: { |self|
		self[\paused] = false;
	},
	
);
)