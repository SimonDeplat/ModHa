(
setPlayer: { |self, player|
	// Update self
	self[\player] = player;
	self.setOut(player[\defaultOut]);
	self.setFreq(player[\freq]);
	self.setTempo(player[\tempo]);
	self[\playerRMFunction] = { self.disconnectPlayer; };
	if(self[\synth].notNil)
	{ self[\synth].moveToHead(player[\continuousGroup]); };
	// Update player
	player.addSignal(\remove, self[\playerRMFunction]);
	player[\continuousSynths].add(self);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		// Update player
		self[\player][\continuousSynths].remove(self);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\playerRMFunction] = nil;
		// Update self
		if(self[\synth].notNil)
		{ self[\synth].moveToHead(~gmDef[\server].defaultGroup); };
		self[\player] = nil;
	};
},

playSynth: { |self|
	if(~gmDef[\server].serverRunning) {
		fork {
			var params = self[\params].deepCopy;
			var group = ~gmDef[\server].defaultGroupID;
			if(self[\player].notNil)
			{ group = self[\player][\continuousGroup].nodeID; };
			if(self[\tunable]) {
				if(self[\player].notNil)
				{ params[\freq] = self[\player][\freq]; }
				{ params[\freq] = 440; };
			};
			// SetTempo here
			params[\out] = self[\out];
			s.sync;
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

setFreq: { |self, freq|
	if(self[\tunable])
	{ self[\synth].set(\freq, freq); };
},

setTempo: { |self, tempo|

},

/*
		UPDATE:
		/!\ Work in progress
		Code is ugly, needs to be clarified
		
		At time of writing, I can think of
		5 different out destinations:
		- direct out
		- global effect
		- effect chain
		- dispatcher
		- scopeView

		I can't tell if they need different functions calls
		or can be treated all the same due to polymorphism
		Different functions for now, fusionned later on if unneeded

		/!\ self[\out] will be deprecated,
		save datas should manipulate [\outNode] directly
*/

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

getSaveData: { |self, dataName|
	var data = ();
	data[\name] = dataName;
	data[\out] = self[\out];
	data[\params] = self[\params].deepCopy;
	data
},

loadData: { |self, data|
	self[\params].clear;
	self[\params] = data[\params].deepCopy;
	// /!\ FIX ME: OUT LOADING NEEDS A SAFETY CHECK
	self[\out] = data[\out];

	// Update synth
	self[\params].keysValuesDo({ |key, value|
		self[\synth].set(key, value); });
	self[\synth].set(\out, self[\out]);

	// Ask UI update
	self[\params].keysDo({ |symbol|
		self.emitSignal(symbol); });
	self.emitSignal(\out);

	data[\params].clear;
	data.clear;
},

doRemove: { |self|
	self.disconnectPlayer;
	// Emit remove signal
	self.emitSignal(\remove);
	// Remove self from current effect if needed
	if(self[\outNode].notNil) {
		if(self[\outNode][\type] == \effect) {
			self[\outNode].removeInSynth(self);
		};
	};
	// Free running synth
	if(~gmDef[\synthFreed].not
		and: { self[\synth].notNil })
	{ self[\synth].free; };
	// Remove self from gmDef synths list
	~gmDef[\synths].removeAt(self[\id]);
	// Clear every collection
	// to allow/speed up garbage collection
	self[\params].clear;
	self[\defaultParams].clear;
	self[\signals].clear;
	self.clear;
},

init: { |self|
	self[\params] = ();
	self[\defaultParams] = ();
	self[\outNode] = nil;
	self[\signals] = ();
	
	// Fetch params default values
	self[\data][\params].do({ |param, index|
		self[\defaultParams][param[\symbol]] =
		param[\default];
	});
	
	self[\params] = self[\defaultParams].deepCopy;
	// Set default out
	self[\out] = 0;
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