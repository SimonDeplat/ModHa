(
type: \effect,

playSynth: { |self|
	if(~gmDef[\server].serverRunning) {
		fork {
			var params = self[\params].deepCopy;
			var group = ~gmDef[\server].defaultGroupID;
			if(self[\player].notNil)
			{ group = self[\player][\effectGroup].nodeID; };
			if(self[\tunable]) {
				if(self[\player].notNil)
				{ params[\freq] = self[\player][\freq] }
				{ params[\freq] = 440; };
			};
			if(self[\tunable]) {
				if(self[\player].notNil)
				{ params[\freq] = self[\player][\freq] }
				{ params[\freq] = 440; };
			};
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

setPlayer: { |self, player|
	self[\player] = player;
	player[\effectSynths].add(self);
	self.setFreq(player[\freq]);
	self.setTempo(player[\tempo]);
	self[\inputs].keysValuesDo({ |key, value|
		player.addEffect(value); });
	self.setOut(player[\defaultOut]);
},

// Index useless for now,
// but allows polymorphism,
// and might be used later on
setParam: { |self, symbol, index, value|
	self[\synth].set(symbol, value);
	self[\params][symbol] = value;
	self.notifyUI(symbol);

	if((symbol == \amp)
		and: { self[\muted] }) {
			self[\muted] = false;
			self.notifyUI(\mute);
		};
},

doRemove: { |self|
	// Free running synth
	if(~gmDef[\synthFreed].not
		and: { self[\synth].notNil })
	{ self[\synth].free; };
	// Free busses
	self[\inputs].keysValuesDo({ |key, input|
		input[\bus].free; });
	// Clear every collection
	// to speed up garbage collection
	self[\params].clear;
	self[\defaultParams].clear;
	self[\ui].clear;
	self[\inputs].clear;
	self.clear;
},

setFreq: { |self, freq|
	if(self[\tunable])
	{ self[\synth].set(\freq, freq); };
},

setMasterOut: { |self, data| self[\synth].set(\out, data[\bus]); },

setEffectOut: { |self, data|
	self[\synth].set(\out, data[\bus]);
	// Reorder nodes so they are calculated
	// consecutivly
	data[\parent].chainOrder;
},

setOut: { |self, data|
	switch(data[\type])
	{ \master } { self.setMasterOut(data); }
	{ \effect } { self.setEffectOut(data); };
	self[\outNode] = data;
	self.notifyUI(\out);
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
	self[\params].keysDo({ |key|
		self.notifyUI(key); });
	self.notifyUI(\out);

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
		self.notifyUI(\mute);
	};
},

init: { |self|
	self[\params] = ();
	self[\defaultParams] = ();
	self[\inputs] = ();
	self[\outNode] = nil;

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

	self[\ui] = ();
},

).parent_(~gmDef[\synthParent])