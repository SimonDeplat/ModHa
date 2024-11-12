(
type: \effect,

setPlayer: { |self, player|
	// Update self
	self[\player] = player;
	self.setOut(player[\defaultOut]);
	self.setFreq(player[\freq]);
	self.setTempo(player[\tempo]);
	self[\playerRMFunction] = { self.disconnectPlayer; };
	if(self[\synth].notNil)
	{ self[\synth].moveToHead(player[\effectGroup]); };
	// Update player
	player.addSignal(\remove, self[\playerRMFunction]);
	player[\effectSynths].add(self);
	self[\inputs].keysValuesDo({ |key, value|
		player[\effects].add(value); });
	// Update player's listeners
	player.emitSignal(\effect);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		// Update player
		self[\player][\effectSynths].remove(self);
		self[\inputs].keysValuesDo({ |key, value|
			self[\player][\effects].remove(value); });
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\playerRMFunction] = nil;
		// Update player's listeners
		self[\player].emitSignal(\effect);
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
			{ group = self[\player][\effectGroup].nodeID; };
			if(self[\tunable]) {
				if(self[\player].notNil)
				{ params[\freq] = self[\player][\freq]; }
				{ params[\freq] = 440; };
			};
			// SetTempo here
			params[\out] = self[\out];
			self[\inputs].keysValuesDo({ |key, input|
				params[input[\symbol]] = input[\bus]; });
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

setTempo: { |self, newTempo|

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
	// Should emit signal ?
},

setMasterOut: { |self, data|
	self[\synth].set(\out, data[\bus]);
},

setEffectOut: { |self, data|
	self[\synth].set(\out, data[\bus]);
	data.addInSynth(self);
	// Reorder nodes so they are calculated
	// consecutivly
	data[\parent].chainOrder;
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

// This recursively reorder nodes
// so they are calculated in the right order
// Nodes are pushed to the tail of the group
// to ensure they're calculated after
// any input they might have
chainOrder: { |self|
	self[\synth].moveToTail(self[\player][\effectGroup]);
	if(self[\outNode].notNil
		and: { self[\outNode][\type] == \effect })
	{ self[\outNode].chainOrder(self[\synth]); };
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

// Construct input busses & datas
addInput: { |self, param|
	var input, bus;
	bus = Bus.audio(~gmDef[\server], param[\numChannels]);
	// This ID must respect input polymorphism (see masterParent.scd)
	input = (
		name: (param[\text] ++ " (" ++ self[\name] ++ ")"),
		parent: self,
		symbol: param[\symbol],
		type: \effect,
		bus: bus
	);
	self[\inputs][param[\symbol]] = input;
	if(self[\player].notNil)
	{ self[\player].addEffect(input); };
},

addInSynth: { |self, node|
	if(self[\inSynths].includes(node).not)
	{ self[\inSynths].add(node); };
},

removeInSynth: { |self, node|
	self[\inSynths].remove(node);
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
	self.disconnectPlayer;
	// Emit remove signal
	self.emitSignal(\remove);
	// Reconnect 'in' synths
	// to current out
	if(self[\outNode].notNil) {
		self[\inSynths].do({ |synth|
			synth.setOut(self[\outNode]);
		});
		// Remove self from current effect if needed
		if(self[\outNode][\type] == \effect) {
			self[\outNode].removeInNode(self);
		};
	};
	// Free running synth
	if(~gmDef[\synthFreed].not
		and: { self[\synth].notNil })
	{ self[\synth].free; };
	// Free busses
	self[\inputs].do({ |input|
		input[\bus].free;
		input.clear;
	});
	self[\inputs].clear;
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
	self[\synth] = nil;
	self[\player] = nil;
	self[\params] = ();
	self[\defaultParams] = ();
	self[\inputs] = ();
	self[\outNode] = nil;
	self[\signals] = ();
	self[\inSynths] = List(0);
	// Fetch params default values,
	// and create in busses
	self[\data][\params].do({ |param, index|
		if(param[\type] == \in) {
			self.addInput(param);
		} {
			self[\defaultParams][param[\symbol]] =
			param[\default];
		};
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