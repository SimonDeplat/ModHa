(
//------//
// INIT //
init: { |self|
	// State
	self[\isPlaying] = false;
	self[\signals] = ();
	// Return
	self
},

// Remote player isn't registered
// until its ID is specified
setID: { |self, id|
	self[\id] = id;
	// Register globally
	~mh.registerPlayer(self);
	if(~mh[\verbose]) {
		(
			"Player "
			++ self[\id].asString
			++ " added"
		).postln;
	};
},

//---------//
// METHODS //
doPlay: { |self|
	if(self[\isPlaying].not) {
		self[\isPlaying] = true;
		self.emitSignal(\doPlay);
		if(~mh[\verbose]) {
			(
				"Player "
				++ self[\id].asString
				++ " playing"
			).postln;
		};
	};
},

doStop: { |self|
	if(self[\isPlaying]) {
		self[\isPlaying] = false;
		self.emitSignal(\doStop);
		if(~mh[\verbose]) {
			(
				"Player "
				++ self[\id].asString
				++ " stopped"
			).postln;
		};
	};
},

loadDatas: { |self, datas|
	// ID
	if(self[\id].isNil) {
		self.setID(datas[0].asSymbol);
	};
	// isPlaying
	if(datas[1]) {
		self.doPlay;
	} {
		self.doStop;
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