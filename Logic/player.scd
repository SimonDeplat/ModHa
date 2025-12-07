(
//------//
// INIT //
init: { |self|
	// State
	self[\id] = ~mh.getUID;
	self[\isPlaying] = false;
	self[\signals] = ();
	// Register globally
	~mh.registerPlayer(self);
	if(~mh[\verbose]) {
		(
			"Player "
			++ self[\id].asString
			++ " added"
		).postln;
	};
	// Return
	self
},

//---------//
// METHODS //
doPlay: { |self|
	self[\isPlaying] = true;
	self.emitSignal(\doPlay);
	if(~mh[\verbose]) {
		(
			"Player "
			++ self[\id].asString
			++ " playing"
		).postln;
	};
},

doStop: { |self|
	self[\isPlaying] = false;
	self.emitSignal(\doStop);
	if(~mh[\verbose]) {
		(
			"Player "
			++ self[\id].asString
			++ " stopped"
		).postln;
	};
},

//---------//
// SIGNALS //
emitSignal: { |self, symbol|
	if(self[\signals].includesKey(symbol)) {
		self[\signals][symbol].value;
	};
},

addSignal: { |self, symbol, function|
	if(self[\signals][symbol].isNil) {
		self[\signals][symbol] = FunctionList();
	};
	self[\signals][symbol].addFunc(function);
},

rmSignal: { |self, symbol, function|
	if(self[\signals].includesKey(symbol)) {
		self[\signals][symbol].removeFunc(function);
	};
},
)