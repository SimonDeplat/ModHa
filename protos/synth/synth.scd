(
setName: { |self, aString|
	self[\name] = aString;
	self.emitSignal(\name);
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

dumpPairs: { |self|
	"".postln;
	"[".postln;
	(
		"\t"
		++ "\\instrument, \\"
		++ self[\data][\symbol]
		++ ","
	).postln;

	self[\params].keysValuesDo({ |key, value|
		(
			"\t\\"
			++ key
			++ ", "
			++ value
			++ ","
		).postln;
	});

	"]".postln;
	"".postln;
},

// This will create datas that are common to ALL synth types
initParent: { |self|
	// Variables
	self[\player] = nil;
	self[\params] = ();
	self[\track] = List(0);
	self[\paramsModes] = ();
	self[\signals] = ();
	self[\hasAmpParam] = false;
	self[\hasTempoParam] = false;
	self[\hasFreqParam] = false;
	self[\outNode] = nil;
	self[\out] = 0;
	self[\currentBeat] = -1;
	self[\nBeats] = 1;
	// Common construction
	self[\data][\params].do({ |param, index|
		switch(param[\type])
		{ \continuous } {
			self[\params][param[\symbol]] = param[\default];
			self[\paramsModes][param[\symbol]] = \value;
		}
		{ \discrete } {
			self[\params][param[\symbol]] = param[\default];
			self[\paramsModes][param[\symbol]] = \value;
		}
		{ \env } {
			self[\params][param[\symbol]] = param[\default].deepCopy;
			self[\paramsModes][param[\symbol]] = \value;
		}
		{ \timeTempo } {
			self[\params][param[\symbol]] = param[\default];
			self[\paramsModes][param[\symbol]] = \value;
			if(self[\hasTempoParam].not) {
				self[\hasTempoParam] = true;
				self[\tempoParams] = List(0);
			};
			self[\tempoParams].add(param[\symbol]);
		}
		{ \freqTempo } {
			self[\params][param[\symbol]] = param[\default];
			self[\paramsModes][param[\symbol]] = \value;
			if(self[\hasTempoParam].not) {
				self[\hasTempoParam] = true;
				self[\tempoParams] = List(0);
			};
			self[\tempoParams].add(param[\symbol]);
		};
	});
	// Check if synth has amp param
	if(self[\params].includesKey(\amp)) {
		self[\hasAmpParam] = true;
		self[\muted] = false;
		self[\muteAmp] = 0;
	};
},
)