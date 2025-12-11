(
//------//
// INIT //
init: { |self|
	// State
	self[\id] = ~mh.getUID;
	self[\isPlaying] = false;
	self[\tuning] = 440;
	self[\freq] = 440;
	self[\scale] = \minor;
	self[\scaleRatios] = Scale.at(self[\scale]).ratios;
	self[\playCycles] = inf;
	self[\playFirstBeat] = false;
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

// Loop //
doPlay: { |self|
	if(self[\isPlaying].not) {
		self[\synth] = SynthDef(\testSine, { |freq|
			var snd = SinOsc.ar(freq!2, 0, 0.25);
			Out.ar(0, snd);
		}).play(args: [\freq, self[\freq]]);
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
		self[\synth].free;
		self[\synth] = nil;
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

setPlayCycles: { |self, nCycles|
	if(self[\playCycles] != nCycles) {
		self[\playCycles] = nCycles;
		self.emitSignal(\playCycles, [nCycles]);
	};
},

setPlayFirstBeat: { |self, boolean|
	if(self[\playFirstBeat] != boolean) {
		self[\playFirstBeat] = boolean;
		self.emitSignal(\playFirstBeat, [boolean]);
	};
},

// Rhythm //

// Freq & Scale //
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
		if(self[\synth].notNil) {
			self[\synth].set(\freq, freq);
		};
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

setScale: { |self, scale|
	if(self[\scale] != scale) {
		self[\scale] = scale;
		self[\scaleRatios] = Scale.at(scale).ratios;
		self.emitSignal(
			\scale,
			[
				self[\scale],
				self[\scaleRatios]
			]
		);
		if(~mh[\verbose]) {
			(
				"Player "
				++ self[\id].asString
				++ " scale: "
				++ self[\scale].asString
			).postln;
		};
	};
},

// Misc //

getDatas: { |self|
	[
		self[\id],
		self[\isPlaying],
		self[\tuning],
		self[\freq],
		self[\scale],
		self[\playCycles],
		self[\playFirstBeat],
	]
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

synth: nil,
)