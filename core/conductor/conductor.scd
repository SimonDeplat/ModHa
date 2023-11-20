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
	// Score
	score: List(0),

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

	midiToNote: { |self, midiNote|
		var noteNames = [
			"A", "Bb", "B", "C", "Db", "D",
			"Eb", "E", "F", "Gb", "G", "Ab"
		];
		// Map to standard range
		while { midiNote < 69 }
		{ midiNote = midiNote + 12; };
		while { midiNote > 80 };
		{ midiNote = midiNote - 12; };
		// Return note name
		noteNames[midiNote - 69]
	},

	noteToMidi: { |self, noteName|
		var midi;
		noteName = self.sharpNoteToFlat(noteName);
		switch(noteName.asSymbol)
		{ \A } { midi = 69; }
		{ \Bb } { midi = 70; }
		{ \B } { midi = 71; }
		{ \C } { midi = 72; }
		{ \Db } { midi = 73; }
		{ \D } { midi = 74; }
		{ \Eb } { midi = 75; }
		{ \E } { midi = 76; }
		{ \F } { midi = 77; }
		{ \Gb } { midi = 78; }
		{ \G } { midi = 79; }
		{ \Ab } { midi = 81; };
		// Return midi note
		midi
	},

	chordToMidi: { |self, noteName, type|
		var midi = List(0);
		// Add root note
		midi.add(self.noteToMidi(noteName));
		switch(type.asSymbol)
		// Major
		{ "".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 7);
		}
		{ "M".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 7);
		}
		// Minor
		{ "-".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 7);
		}
		{ "m".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 7);
		}
		// V
		{ "7".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 10);
		}
		// V b9
		{ "7b9".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 10);
			midi.add(midi[0] + 13);
		}
		// maj7
		{ "maj7".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 11);
		}
		{ "^".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 11);
		}
		// -7
		{ "-7".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 10);
		}
		{ "m7".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 10);
		}
		// sus2
		{ "sus2".asSymbol } {
			midi.add(midi[0] + 2);
			midi.add(midi[0] + 7);
		}
		// sus4
		{ "sus4".asSymbol } {
			midi.add(midi[0] + 5);
			midi.add(midi[0] + 7);
		}
		// -6
		{ "-6".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 8);
		}
		// -#6
		{ "-#6".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 9);
		}
		// -maj7
		{ "-maj7".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 11);
		}
		// °
		{ "°".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 6);
		}
		// °7
		{ "°7".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 6);
			midi.add(midi[0] + 9);
		}
		// b5
		{ "b5".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 6);
		}
		// 6
		{ "6".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 9);
		}
		// b6
		{ "b6".asSymbol } {
			midi.add(midi[0] + 4);
			midi.add(midi[0] + 7);
			midi.add(midi[0] + 8);
		}
		// -7b5
		{ "-7b5".asSymbol } {
			midi.add(midi[0] + 3);
			midi.add(midi[0] + 6);
			midi.add(midi[0] + 10);
		}
		{ "Conductor : unsupported chord type".warn; };
		// Return the chord
		midi
	},

	chordToFreqs: { |self, noteName, type|
		self.chordToMidi(noteName, type).midicps
	},

	chordToTunedFreqs: { |self, noteName, type|
		self.tune(self.chordToFreqs(noteName, type))
	},

	supportedChordTypes: {
		[
			"", "M", "-", "m",
			"7", "7b9", "maj7", "^",
			"-7", "m7", "sus2", "sus4",
			"-6", "-#6", "-maj7", "°",
			"°7", "b5", "6", "b6",
			"-7b5"
		]
	},

	// Clock & Rythm
	setBPM: { |self, bpm|
		self[\bpm] = bpm;
		self[\mainClock].tempo_(
			(self[\bpm] / 60)
			* self[\maxSub]);
	},
	
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

	isCurrentSub: { |self, time| (time == self.getSubInCycle) },

	// Private
	playScore: { |self|
		// score is supposed to be loaded, play it
		s.listSendBundle(s.latency, self.getScore);
	},

	getScore: { |self| self[\score] },

	removeFromScore: { |self, obsoleteMsgs|
		obsoleteMsgs.do({ |msg|	self[\score].remove(msg); });
	},

	updateScore: { |self, obsoleteMsgs, newMsgs|
		if(obsoleteMsgs.notNil)
		{ self.removeFromScore(obsoleteMsgs); };
		if(newMsgs.notNil)
		{ newMsgs.do({ |msg| self[\score].add(msg);	}); };
	},

	dumpScore: { |self|
		if(self[\score].size > 0)
		{ self[\score].do({ |item| item.postln; }); }
		{ "Empty Score".postln; };
		"".postln;
	},

	overridePlayScore: { |self, aFunction|
		self[\playScore] = aFunction;
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