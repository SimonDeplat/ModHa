(
//------//
// INIT //
init: { |self|
	// State
	self[\id] = nil;
	self[\isPlaying] = false;
	self[\tuning] = 440;
	self[\freq] = 440;
	self[\signals] = ();
	// Return
	self
},

//---------//
// METHODS //

// Loop //
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

// Freq //
setTuning: { |self, freq|
	var tuning;
	if(self[\tuning] != freq) {
		tuning = self[\tuning];
		self[\tuning] = freq;
		tuning = self[\tuning] / tuning;
		self.emitSignal(\tuning, [freq]);
		if(~mh[\verbose]) {
			(
				"Player "
				++ self[\id].asString
				++ " tuning: "
				++ self[\tuning].round(0.01).asString
			).postln;
		};
		self.setFreq(self[\freq] * tuning);
	};
},

setFreq: { |self, freq|
	if(self[\freq] != freq) {
		self[\freq] = freq;
		self.emitSignal(\freq, [freq]);
		if(~mh[\verbose]) {
			(
				"Player "
				++ self[\id].asString
				++ " freq: "
				++ self[\freq].round(0.01).asString
			).postln;
		};
	};
},

// Misc //

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

// Datas loading
/*
0 - ID
1 - isPlaying
2 - Tuning
3 - Freq
*/
loadDatas: { |self, datas|
	// ID
	if(self[\id].isNil) {
		self.setID(datas[0].asSymbol);
	};
	// isPlaying
	if(datas[1] == 1) {
		self.doPlay;
	} {
		self.doStop;
	};
	// Freq
	self.setTuning(datas[2]);
	self.setFreq(datas[3]);
},

// Allows sending cmds directly
// without knowing player's ID
cmd: { |self, cmd, args|
	if(args.isNil) {
		args = [self[\id].asString];
	} {
		if(args.isKindOf(Array).not) {
			args = [args];
		};
		args = [self[\id].asString] ++ args;
	};
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