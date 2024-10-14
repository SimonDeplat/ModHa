(
playSynth: { |self|
	if(~gmDef[\server].serverRunning) {
		fork {
			var params = self[\params].deepCopy;
			var group = ~gmDef[\server].defaultGroupID;
			if(self[\player].notNil)
			{ group = self[\player][\continuousGroup].nodeID; };
			if(self[\tunable]) {
				if(self[\player].notNil)
				{ params[\freq] = self[\player][\freq] }
				{ params[\freq] = 440; };
			};
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

muted: false,
muteAmp: 0,
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

setFreq: { |self, freq|
	if(self[\tunable])
	{ self[\synth].set(\freq, freq); };
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

outNode: nil,

setMasterOut: { |self, data|
	self[\synth].set(\out, data[\bus]);
},

setEffectOut: { |self, data|
	self[\synth].set(\out, data[\bus]);
},

setOut: { |self, data|
	switch(data[\type])
	{ \master } { self.setMasterOut(data); }
	{ \effect } { self.setEffectOut(data); };
	self[\outNode] = data;
	self.notifyUI(\out);
},

doRemove: { |self|
	// Free running synth
	if(~gmDef[\synthFreed].not
		and: { self[\synth].notNil })
	{ self[\synth].free; };
	// Clear every collection
	// to speed up garbage collection
	self[\params].clear;
	self[\defaultParams].clear;
	self[\ui].clear;
	self.clear;
},

setPlayer: { |self, player|
	self[\player] = player;
	player[\continuousSynths].add(self);
	self.setFreq(player[\freq]);
	self.setOut(player[\defaultOut]);
	// FIX ME: THIS SHOULD ALSO
	// UPDATE TEMPO RELATED PARAMS
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
	self[\params].keysDo({ |key|
		self.notifyUI(key); });
	self.notifyUI(\out);

	data[\params].clear;
	data.clear;
},

init: { |self|
	self[\params] = ();
	self[\defaultParams] = ();

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
	if(self[\defaultParams].includesKey(\amp))
	{ self[\hasAmpParam] = true; };
	self[\ui] = ();
},
).parent_(~gmDef[\synthParent])