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

// Allows sending cmds directly
// without knowing player's ID
cmd: { |self, cmd, args|
	args = [self[\id].asString] ++ args;
	~mh[\am].cmd(cmd, args);
},

//---------//
// SIGNALS //
emitSignal: { |self, symbol, args = nil|
	if(self[\signals].includesKey(symbol)) {
		if(args.isNil) {
			self[\signals][symbol].value;
		} {
			self[\signals][symbol].value(args);
		};
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