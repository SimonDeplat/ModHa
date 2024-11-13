(
type: \input,

playSynth: { |self|
	if(~gmDef[\server].serverRunning) {
		fork {
			var params = self[\params].deepCopy;
			var group = ~gmDef[\server].defaultGroupID;
			if(self[\player].notNil)
			{ group = self[\player][\inputGroup].nodeID; };
			params[\out] = self[\out];
			~gmDef[\server].sync;
			self[\synth] = Synth(
				self[\data][\symbol],
				params.asPairs,
				group,
				\addToTail
			);
			params.clear;
		};
	};
},

setPlayer: { |self, player|
	self[\player] = player;
	player[\inputSynths].add(self);
	self.setOut(player[\defaultOut]);
},

// Index useless for now,
// but allows polymorphism,
// and might be used later on
setParam: { |self, symbol, index, value|
	self[\synth].set(symbol, value);
	self[\params][symbol] = value;
	self.emitSignal(symbol);

	if((symbol == \amp)
		and: { self[\muted] }) {
			self[\muted] = false;
			self.emitSignal(\mute);
		};
},

setMasterOut: { |self, data|
	self[\synth].set(\out, data[\bus]);
},

setEffectOut: { |self, data|
	self[\synth].set(\out, data[\bus]);
	data.addInSynth(self);
},

setOut: { |self, data|
	// Remove self from current effect if needed
	if(self[\outNode].notNil) {
		if(self[\outNode][\type] == \effect) {
			self[\outNode].removeInSynth(self);
		};
	};
	switch(data[\type])
	{ \master } { self.setMasterOut(data); }
	{ \effect } { self.setEffectOut(data); };
	self[\outNode] = data;
	self.emitSignal(\out);
},

setInput: { |self, channel|
	self[\synth].set(\inBus, channel);
	self[\input] = channel;
	self.emitSignal(\input);
},

setMuted: { |self, aBoolean|
	if(self[\hasAmpParam]) {
		if(aBoolean) {
			self[\muteAmp] = self[\params][\amp];
			self.setParam(
				\amp,
				-1,
				0
			);
		} {
			self.setParam(
				\amp,
				-1,
				self[\muteAmp]
			);
		};
		self[\muted] = aBoolean;
		self.emitSignal(\mute);
	};
},

doRemove: { |self|
	// Remove self from current effect if needed
	if(self[\outNode].notNil) {
		if(self[\outNode][\type] == \effect) {
			self[\outNode].removeInSynth(self);
		};
	};
	if(self[\synth].notNil)
	{ self[\synth].free; };
	self[\defaultParams].clear;
	self[\params].clear;
	self[\signals].clear;
},

init: { |self|
	self[\params] = ();
	self[\defaultParams] = ();
	self[\outNode] = nil;
	self[\signals] = ();

	// Fetch params default values
	self[\data][\params].do({ |param, index|
		if([\in, \soundIn].includes(param[\type]).not) {
			self[\defaultParams][param[\symbol]] =
			param[\default];
		} {
			if(param[\type] == \soundIn)
			{ self[\numInputChannels] = param[\numChannels]; };
		};
	});

	self[\params] = self[\defaultParams].deepCopy;
	// Set default out
	self[\out] = 0;
	self[\input] = 0;
	// Play synth
	self.playSynth;
	
	if(self[\defaultParams].includesKey(\amp)) {
		self[\hasAmpParam] = true;
		self[\muted] = false;
		self[\muteAmp] = 0;
	} {
		self[\hasAmpParam] = false;
	};
	// /!\ WIP
	self[\hasTempoParam] = false;
},

).parent_(~gmDef[\synthParent])