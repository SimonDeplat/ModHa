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
	// Rythm & Clock related
	mainClock: TempoClock(),
	playing: false,
	isDumpTime: false,
	paused: false,
	subInCycle: 0,
	subPerCycle: 16,

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

	setRootNote: { |self, note|
		note = self.sharpNoteToFlat(note);
		self[\rootNote] = note;
		// setNote should always be called
		// when isModal anyway
		if(self[\isModal])
		{ self.setRootFreqFromRootNote; };
	},

	setNote: { |self, note|
		self[\userNote] = note;
		note = self.sharpNoteToFlat(note);
		self[\note] = note;
		// setNote should always be called
		// when isModal anyway
		if(self[\isModal])
		{ self.setFreqFromNote; };
	},

	setRootFreqFromRootNote: { |self|
		var freq = self.getFreqFromNote(self[\rootNote]);
		// Tuning to current diapason
		freq = self.tune(freq);
		self.setRootFreq(freq);
	},
	
	setFreqFromNote: { |self|
		var freq = self.getFreqFromNote(self[\note]);
		// Tuning to current diapason
		freq = self.tune(freq);
		self.setFreq(freq);
	},

	setScale: { |self, scale|
		if(Scale.directory.includes(scale)) {
			self[\scale] = scale;
		} {
			"Conductor : invalid scale symbol".warn;
		};
	},

	getAudibleScale: { |self|
		var octave = 1.0;
		var fullScale;
		// Find scale ratios
		var scale = Scale.at(self[\scale]).ratios;
		// Multiply by root freq
		scale = scale * self[\rootFreq];
		// Tune
		scale = self.tune(scale);
		// Start constructing the full audible scale
		fullScale = scale.deepCopy;
		// Add lower octave until audition threshold is crossed
		while { fullScale[0] > self[\audibleRange][0] } {
			octave = octave / 2;
			fullScale = (scale * octave) ++ fullScale;
		};
		// Remove values below audition threshold
		while { fullScale[0] < self[\audibleRange][0] }
		{ fullScale.removeAt(0); };
		// Do the same upwards
		octave = 1.0;
		while { fullScale[fullScale.size - 1] < self[\audibleRange][1] } {
			octave = octave * 2;
			fullScale = fullScale ++ (scale * octave);
		};
		while { fullScale[fullScale.size - 1] > self[\audibleRange][1] }
		{ fullScale.pop; };
		// Return the result
		fullScale
	},

	setModal: { |self, aBoolean|
		self[\isModal] = aBoolean;
		// isModal == false implies isTonal == false
		if(aBoolean.not)
		{ self[\isTonal] = false; };
	},

	setTonal: { |self, aBoolean|
		self[\isTonal] = aBoolean;
		// isTonal == true implies isModal == true
		if(aBoolean) { self[\isModal] = true; };
	},

	// Private
	// Converts sharp notation to
	// enharmonic flat notation
	sharpNoteToFlat: { |self, note|
		note = note.asSymbol;
		switch(note)
		{ "A#".asSymbol } { note = "Bb"; }
		{ "B#".asSymbol } { note = "C"; }
		{ "C#".asSymbol } { note = "Db"; }
		{ "D#".asSymbol } { note = "Eb"; }
		{ "E#".asSymbol } { note = "F"; }
		{ "F#".asSymbol } { note = "Gb"; }
		{ "G#".asSymbol } { note = "Ab"; };
		note = note.asString;
		note
	},

	getFreqFromNote: { |self, note|
		// Default as root freq in case of error
		var freq = self[\rootFreq];
		// Starting from A, 440HZ
		var freqs = (69..80).midicps;
		switch(note.asSymbol)
		{ \A } { freq = freqs[0]; }
		{ \Bb } { freq = freqs[1]; }
		{ \B } { freq = freqs[2]; }
		{ \C } { freq = freqs[3]; }
		{ \Db } { freq = freqs[4]; }
		{ \D } { freq = freqs[5]; }
		{ \Eb } { freq = freqs[6]; }
		{ \E } { freq = freqs[7]; }
		{ \F } { freq = freqs[8]; }
		{ \Gb } { freq = freqs[9]; }
		{ \G } { freq = freqs[10]; }
		{ \Ab } { freq = freqs[11]; }
		{ "Conductor : invalid note name".warn; };
		freq
	},

	midiToTunedFreq: { |self, midiNote|
		// Polymorphism allows to convert
		// either single midi notes
		// or arrays of midi notes
		var freq = midiNote.midicps;
		freq = self.tune(freq);
		// Return freq
		freq
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

	// Rythm setters
	setMaxSection: { |self, int|
		self[\maxSection] = int;
	},
	setMaxCycle: { |self, int|
		self[\maxCycle] = int;
	},
	setMaxBeat: { |self, int|
		self[\maxBeat] = int;
		self.updateSubPerCycle;
	},
	setMaxSub: { |self, int|
		self[\maxSub] = int;
		self.updateSubPerCycle;
	},

	// Rythm getters
	getMaxSection: { |self| self[\maxSection] },
	getMaxCycle: { |self| self[\maxCycle] },
	getMaxBeat: { |self| self[\maxBeat] },
	getMaxSub: { |self| self[\maxSub] },
	getAbsTime: { |self| self[\absTime] },

	updateSubPerCycle: { |self|
		self[\subPerCycle] = self[\maxBeat] * self[\maxSub];
	},

	// Private
	resetTime: { |self|
		self[\absTime] = 0;
		self[\currentSection] = 0;
		self[\currentCycle] = 0;
		self[\currentBeat] = 0;
		self[\currentSub] = 0;
		self[\subInCycle] = 0;
	},

	// Private
	tick: { |self|
		if(self[\paused].not) {
			self.playScore;
			self.advance;
			if(self[\isDumpTime])
			{ self.dumpTime; };
		};
	},

	// Private
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

	// Private
	getSubInCycle: { |self|
		self[\subInCycle] =
		(self[\maxSub] * self[\currentBeat])
		+ self[\currentSub];
	},

	// Private
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