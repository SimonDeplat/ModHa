(
// DIAPASON
setDiapason: { |self, freq|
	var ratio = freq / self[\diapason];
	self[\diapason] = freq;
	self.setFreq(self[\freq] * ratio);
	self[\chromaticNotes] =
	(Scale.at(\chromatic).ratios ++ [2]) * freq;
	self.emitSignal(\diapason);
},

// FREQ & SCALE
setFreq: { |self, freq|
	// Update synths
	self[\continuousSynths].do({ |synth|
		synth.setFreq(freq); });
	self[\effectSynths].do({ |synth|
		synth.setFreq(freq); });
	// Update self
	self[\freq] = freq;
	self.updateScale;
	// Update UI
	self.emitSignal(\freq);
},

setScale: { |self, scaleSymbol|
	self[\scale] = scaleSymbol;
	self.updateScale;
	self.emitSignal(\scale);
	self.updateVHighlights;
},

// /!\ WIP
updateVHighlights: { |self|
	if(self[\vHighlights].size
		!= self[\scaleFreqs].size) {
			switch(self[\scaleFreqs].size)
			{ 5 } {
				self[\vHighlights] = [
					0.666, 0, 0, 0.333, 0] }
			{ 7 } {
				self[\vHighlights] = [
					0.666, 0, 0.333, 0, 0.333, 0, 0] };
			self.emitSignal(\vHighlights);
		};
},

// This can be called in two situations:
// - scale changed
// - freq changed
updateScale: { |self|
	self[\scaleFreqs] =
	Scale.at(self[\scale]).ratios * self[\freq];
	// Reset score with new scale
	self.fetchScore;
},

getFreqAtIndex: { |self, index|
	var freqMul = 1;
	while { index > (self[\scaleFreqs].size - 1) } {
		index = index - self[\scaleFreqs].size;
		freqMul = freqMul * 2;
	};
	while { index < 0 } {
		index = index + self[\scaleFreqs].size;
		freqMul = freqMul / 2;
	};
	(self[\scaleFreqs][index] * freqMul)
},

// RYTHM
setTempo: { |self, tempo|
	if(self[\integerTempo])
	{ tempo = tempo.asInteger; };
	// /!\ Tempo should be applied to every synth
	self[\effectSynths].do({ |synth|
		synth.setTempo(tempo); });
	self[\tempo] = tempo;
	self[\clock].tempo_(tempo / 60);
	self.emitSignal(\tempo);
},

setRythm: { |self, pair|
	self[\rythm] = pair;
	self[\nBeats] = pair[0] * pair[1];
	if(self[\currentBeat] >= self[\nBeats]) {
		self[\currentBeat] = 0;
		if(self[\isPlaying])
		{ self.fetchScore; };
	};
	// Update views
	self[\discreteSynths].do({ |synth|
		synth.setMaxBeat(self[\nBeats]); });
	// Notify UI
	self.emitSignal(\rythm);
	// Update highlights
	self.updateHighlights;
},

updateHighlights: { |self|
	var highlights;
	var filler;
	switch(self[\rythm][1])
	{ 1 } { filler = []; }
	{ 2 } { filler = [0]; }
	{ 3 } { filler = [0, 0.333]; }
	{ 4 } { filler = [0, 0.333, 0]; }
	{ 5 } { filler = [0, 0, 0.333, 0]; }
	{ 6 } { filler = [0, 0.333, 0, 0.333, 0]; }
	{ 7 } { filler = [0, 0, 0, 0.333, 0, 0]; }
	{ 8 } { filler = [0, 0, 0, 0.333, 0, 0, 0]; };
	switch(self[\rythm][0])
	{ 1 } { highlights = [0.9] ++ filler; }
	{ 2 } {
		highlights =
		[0.9] ++ filler
		++ [0.666] ++ filler;
	}
	{ 3 } {
		highlights =
		[0.9] ++ filler
		++ [0.666] ++ filler
		++ [0.666] ++ filler;
	}
	{ 4 } {
		highlights =
		[0.9] ++ filler
		++ [0.5] ++ filler
		++ [0.75] ++ filler
		++ [0.5] ++ filler;
	}
	{ 5 } {
		highlights =
		[0.9] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler
		++ [0.75] ++ filler
		++ [0.5] ++ filler;
	}
	{ 6 } {
		highlights =
		[0.9] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler
		++ [0.75] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler;
	}
	{ 7 } {
		highlights =
		[0.9] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler
		++ [0.75] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler;
	}
	{ 8 } {
		highlights =
		[0.9] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler
		++ [0.75] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler
		++ [0.5] ++ filler;
	};
	self[\highlights] = highlights;
	self.emitSignal(\highlights);
},

// ROUTINE
doPlay: { |self|
	self[\routine] = Routine({
		var actualTime = 0;
		self[\currentBeat] = 0;
		self[\currentCycle] = 0;
		self[\isPlaying] = true;
		loop {
			// Play here
			if(self[\score].size > 0) {
				s.listSendBundle(
					s.latency,
					self[\score].deepCopy
				);
			};
			// Update views
			self[\actualBeat] = self[\currentBeat];
			{
				if(self[\isPlaying]) { self.emitSignal(\beat); };
			}.defer(s.latency);
			// FIX SPECIAL CASE WHEN CHANGING RYTHM
			// ON LAST TIME ?
			// Update 'current' time
			self[\currentBeat] = self[\currentBeat] + 1;
			if(self[\currentBeat] == self[\nBeats]) {
				self[\currentBeat] = 0;
				self[\currentCycle] = self[\currentCycle] + 1;
				// Stop if max cycle reached
				if(self[\currentCycle] >= self[\maxCycle])
				{ self.doStop(false); };
			};
			// Fetch next score
			self.fetchScore;
			(1 / self[\rythm][1]).wait;

		};
	}).play(self[\clock]);
	self.emitSignal(\play);
},

doStop: { |self|
	if(self[\isPlaying]) {
		// Mute continuous synths if needed
		if(self[\muteContinuous]) {
			self[\continuousSynths].do({ |synth|
				if(synth[\hasAmpParam])
				{ synth.setMuted(true); };
			});
		};
		self[\isPlaying] = false;
		self[\score].clear;
		self[\currentBeat] = 0;
		self[\currentCycle] = 0;
		// Fetch starting score
		self.fetchScore;
		// Update views
		self[\actualBeat] = 0;
		self.emitSignal(\beat);
		// FIX ME? If not manual,
		// stop signal is emitted
		// 1 subdivision before the last beat emission
		self.emitSignal(\stop);
		// Stopping routine needs to be last,
		// because if doStop is called inside,
		// doStop evaluation will stop when the routine stops
		self[\routine].stop;
	};
},

setMaxCycle: { |self, nCycle|
	self[\maxCycle] = nCycle;
	self.emitSignal(\maxCycle);
},

// SCORE UTILITIES
fetchScore: { |self|
	self[\score].clear;
	self[\discreteSynths].do({ |synth|
		var notes = synth.getScoreAt(self[\currentBeat]);
		if(notes.notNil) {
			notes.do({ |note|
				self[\score].add(note);
			});
		};
	});
},

notifyMsgChange: { |self, oldMsgs, newMsgs|
	if(oldMsgs.notNil) {
		oldMsgs.do({ |msg|
			self[\score].removeAt(
				self[\score].indexOfEqual(msg);
			);
		});
	};
	if(newMsgs.notNil) {
		newMsgs.do({ |msg|
			self[\score].add(msg);
		});
	};
},

// SIGNALS
emitSignal: { |self, symbol|
	if(self[\signals].includesKey(symbol))
	{ self[\signals][symbol].value; };
},

addSignal: { |self, symbol, function|
	if(self[\signals][symbol].isNil)
	{ self[\signals][symbol] = FunctionList(); };
	self[\signals][symbol].addFunc(function);
},

rmSignal: { |self, symbol, function|
	if(self[\signals].includesKey(symbol))
	{ self[\signals][symbol].removeFunc(function); };
},

// GROUPS
createGroups: { |self|
	self[\playerGroup] = Group.new(
		~gmDef[\server].defaultGroupID,
		\addToHead
	);
	self[\inputGroup] = Group.new(
		self[\playerGroup].nodeID,
		\addToTail
	);
	self[\discreteGroup] = Group.new(
		self[\playerGroup].nodeID,
		\addToTail
	);
	self[\continuousGroup] = Group.new(
		self[\playerGroup].nodeID,
		\addToTail
	);
	self[\effectGroup] = Group.new(
		self[\playerGroup].nodeID,
		\addToTail
	);
	self[\masterGroup] = Group.new(
		self[\playerGroup].nodeID,
		\addToTail
	);
},

// MASTERS & SYNTHS
loadMasters: { |self|
	// Only supports stereo :
	var numOut =
	~gmDef[\server].options.numOutputBusChannels;
	numOut = numOut - (numOut % 2);
	numOut = numOut / 2;
	numOut = numOut.asInteger;
	numOut.do({ |index|
		var master = ~gmDef.getMaster;
		master.setOut(index * 2);
		master.setGroup(self[\masterGroup]);
		if(numOut > 1)
		{ master[\name] = "Master " ++ (index + 1); }
		{ master[\name] = "Master"; };
		self[\masters].add(master);
	});
	self[\defaultOut] = self[\masters][0];
},

addEffect: { |self, effect| self[\effects].add(effect); },

// DATAS
save: { |self|
	var file = File(
		self[\currentFileName].standardizePath, "w");
	var data = ();
	data[\name] = self[\currentDataName];
	data[\nBeats] = self[\nBeats];
	data[\diapason] = self[\diapason];
	data[\freq] = self[\freq];
	data[\scale] = self[\scale];
	data[\tempo] = self[\tempo];
	data[\rythm] = self[\rythm];
	file.write(data.asCompileString);
	file.close;
	data.clear;
},

saveAs: { |self, dataName|
	var fileName =
	~gmDef[\userFolder]
	++ "presets/players/"
	++ dataName
	++ "_" ++ ~gmDef.getUID
	++ ".gmdef_player";
	self[\currentFileName] = fileName;
	self[\currentDataName] = dataName;
	self.save;
},

load: { |self, file, dataName|
	var data = this.executeFile(file);
	self.setDiapason(data[\diapason]);
	self.setFreq(data[\freq]);
	self.setScale(data[\scale]);
	self.setTempo(data[\tempo]);
	self.setRythm(data[\rythm]);
	data.clear;
	if(self[\currentFileName] != file) {
		self[\currentFileName] = file;
		self[\currentDataName] = dataName;
	};
},

// MISC
// /!\ WIP
doRemove: { |self|
	self[\masters].do({ |master| master.doRemove; });
},

// INIT
init: { |self|
	self[\clock] = TempoClock();
	self[\routine] = nil;
	self[\isPlaying] = false;
	self[\actualBeat] = 0;
	self[\currentBeat] = 0;
	self[\currentCycle] = 0;
	self[\maxCycle] = inf;
	self[\nBeats] = 16;
	self[\discreteSynths] = List(0);
	self[\continuousSynths] = List(0);
	self[\effects] = List(0);
	self[\score] = List(0);
	self[\signals] = ();
	self[\diapason] = 440;
	self[\chromaticNotes] = nil;
	self[\freq] = 440;
	self[\scale] = \minor;
	self[\scaleFreqs] = nil;
	self[\vHighlights] = [0.666, 0, 0.333, 0, 0.333, 0, 0];
	self[\integerTempo] = true;
	self[\tempo] = 60;
	self[\rythm] = [4, 4];
	self[\highlights] = nil;
	self[\masters] = List(0);
	self[\defaultOut] = 0;
	self[\muteContinuous] = true;
	self[\currentFileName] = nil;
	self[\currentDataName] = nil;

	// Init
	self.createGroups;
	self.loadMasters;
	self.setDiapason(440);
	self.setFreq(self[\freq]);
	self.setScale(self[\scale]);
	self.setTempo(self[\tempo]);
	self.setRythm(self[\rythm]);
	self.updateHighlights;
	self.updateVHighlights;

	self
},
)