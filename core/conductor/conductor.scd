(
~mh[\conductor] = (
	// Tuning keys
	freq: 440,
	diapason: 440,
	scale: \minor,
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
	mainClock: TempoClock(),
	playing: false,
	isDumpTime: false,

	// Methods

	// Clock
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
);
)