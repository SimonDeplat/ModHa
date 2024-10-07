(
audibleAt: { |self, time|
	var audible = self[\muted].not;

	time = time%self[\nBeats];

	if(audible)
	{ audible = self[\triggers][time].coin; };

	if(audible) {
		if(self[\hasAmpParam]
			and: { self[\track][time][\amp] == 0 })
		{ audible = false; };
	};

	if(audible) {
		if(self[\tunable]
			and: { self[\freqs][time] == nil; })
		{ audible = false; };
	};

	audible
},

getMsgAt: { |self, time|
	var msgs = nil;
	var oscMsg = self[\header].deepCopy.asList;

	time = time%self[\nBeats];

	msgs = List(0);

	// Fill params
	self[\defaultParams].keysDo({ |key|
		var value;
		if(self[\paramsModes][key] == \value)
		{ value = self[\params][key]; }
		{ value = self[\track][time][key]; };

		// Normal params and Envs are different :
		if(value.isKindOf(Env).not) {
			// Special case, polyphonic mixer
			if(
				(key == \amp)
				and: {
					self[\tunable]
					and: { self[\mixFreqs] }
				}
			)
			{ self[\freqs][time].size.do({ value = value * 0.8; }); };
			oscMsg.add(key);
			oscMsg.add(value);
		} {
			oscMsg.add(key);
			oscMsg.add($[);
			value.asControlInput.do({ |segment|
				oscMsg.add(segment); });
			oscMsg.add($]);
		};
	});

	// Out param
	oscMsg.add(\out);
	oscMsg.add(self[\out]);

	// Frequency management
	if(self[\tunable]) {
		self[\freqs][time].do({ |freq|
			var msg = oscMsg.deepCopy;
			msg.add(\freq);
			if(self[\player].notNil)
			{ msg.add(self[\player].getFreqAtIndex(freq)); }
			{ msg.add(freq); };
			msgs.add(msg.asArray);
			msg.clear;
		});
	} {
		// Needs to be an Array
		msgs.add(oscMsg.asArray);
	};
	oscMsg.clear;

	msgs
},

getScoreAt: { |self, time|
	var msgs = nil;
	if(self.audibleAt(time))
	{ msgs = self.getMsgAt(time); };

	// Update cached msgs
	if(self[\currentMsgs].notNil)
	{ self[\currentMsgs].clear; };
	if(msgs.notNil)
	{ self[\currentMsgs] = msgs.deepCopy; }
	{ self[\currentMsgs] = nil; };

	// Return
	msgs
},

playAt: { |self, time|
	var msgs = self.getMsgAt(time);
	if(msgs.notNil) {
		s.listSendBundle(
			0,
			msgs
		);
		msgs.clear;
	};
},

generateHeader: { |self|
	var group = ~gmDef[\server].defaultGroupID;

	if(self[\player].notNil)
	{ group = self[\player][\discreteGroup].nodeID; };

	self[\header].clear;

	self[\header].add(\s_new);
	self[\header].add(self[\data][\symbol]);
	self[\header].add(-1);
	self[\header].add(0);
	self[\header].add(group);
},

// Player holds osc msgs ready one beat in advance.
// If a modification impacts the msg it currently holds,
// (i. e. user modified current cached osc msg)
// we notify it to update its score.
updateMsg: { |self|
	if(self[\player].notNil) {
		var oldMsgs, newMsgs;
		if(self[\currentMsgs].notNil)
		{ oldMsgs = self[\currentMsgs].deepCopy; }
		{ oldMsgs = nil; };
		newMsgs = self.getScoreAt(self[\player][\currentBeat]);
		self[\player].notifyMsgChange(oldMsgs, newMsgs);
		if(oldMsgs.notNil)
		{ oldMsgs.clear; };
	};
},

muted: false,
setMuted: { |self, aBoolean|
	self[\muted] = aBoolean;
	self.updateMsg;
	self.notifyUI(\mute);
},

setParam: { |self, symbol, index, value|
	if(index < self[\nBeats]) {
		if(index == -1) {
			self[\params][symbol] = value;
			self[\track].do({ |beat|
				beat[symbol] = value;
			});
			self.updateMsg;
		} {
			self[\track][index][symbol] = value;
			if(self[\player].notNil
				and: { self[\player][\currentBeat] == index })
			{ self.updateMsg; };
		};
		self.notifyUI(symbol);
	};
},

setMode: { |self, symbol, mode|
	self[\paramsModes][symbol] = mode;
	if(mode == \value) {
		self.setParam(
			symbol, -1, self[\params][symbol]);
	};
	self.notifyUI(symbol);
},

setTrigger: { |self, index, value|
	if(index < self[\nBeats]) {
		self[\triggers][index] = value;
		if(self[\player].notNil
			and: { self[\player][\currentBeat] == index })
		{ self.updateMsg; };
	};
	self.notifyUI(\trigger);
},

setFreq: { |self, index, value|
	if(self[\tunable] and: { index < self[\nBeats] }) {
		self[\freqs][index] = value;
		if(self[\player].notNil
			and: { self[\player][\currentBeat] == index })
		{ self.updateMsg; };
	};
	self.notifyUI(\freqs);
},

outNode: nil,

setMasterOut: { |self, data|
	self[\out] = data[\bus].index;
},

setEffectOut: { |self, data|
	self[\out] = data[\bus].index;
},

setOut: { |self, data|
	switch(data[\type])
	{ \master } { self.setMasterOut(data); }
	{ \effect } { self.setEffectOut(data); };
	self.updateMsg;
	self[\outNode] = data;
	self.notifyUI(\out);
},

setMaxBeat: { |self, maxBeat|
	if(self[\nBeats] != maxBeat) {
		// Not enough beats
		if(self[\nBeats] < maxBeat) {
			var difference = maxBeat - self[\nBeats];
			// Freq and triggers
			if(self[\tunable]) {
				difference.do({
					self[\freqs].add(nil);
					self[\triggers].add(1);
				});
			} {
				difference.do({
					self[\triggers].add(0); });
			};
			// Params
			difference.do({
				self[\track].add(
					self[\params].deepCopy);
				self[\defaultTrack].add(
					self[\defaultParams].deepCopy);
			});
		} {
			// Too many beats
			var nTriggers, nTrack, nDefaultTrack;
			nTriggers = self[\triggers].copyRange(0, maxBeat - 1);
			self[\triggers].clear;
			self[\triggers] = nTriggers;
			nTrack = self[\track].copyRange(0, maxBeat - 1);
			self[\track].clear;
			self[\track] = nTrack;
			nDefaultTrack = self[\defaultTrack].copyRange(0, maxBeat - 1);
			self[\defaultTrack].clear;
			self[\defaultTrack] = nDefaultTrack;
			if(self[\tunable]) {
				var nFreqs = self[\freqs].copyRange(0, maxBeat - 1);
				self[\freqs].clear;
				self[\freqs] = nFreqs;
			};
		};

		self[\nBeats] = maxBeat;
		// Kinda need to update every
		// associated views here
		self.notifyUI(\nBeats);
		self.notifyUI(\freqs);
		self.notifyUI(\trigger);
		self[\params].keysDo({ |key|
			self.notifyUI(key); });
	};
},

setMixFreqs: { |self, aBoolean|
	self[\mixFreqs] = aBoolean;
	self.updateMsg;
	self.notifyUI(\mixFreqs);
},

doRemove: { |self|
	// Clear every collection
	// to speed up garbage collection
	self[\triggers].clear;
	self[\params].clear;
	self[\defaultParams].clear;
	self[\track].do({ |beat|
		beat.clear; });
	self[\track].clear;
	self[\defaultTrack].do({ |beat|
		beat.clear; });
	self[\defaultTrack].clear;
	self[\paramsModes].clear;
	if(self[\tunable])
	{ self[\freqs].clear; };
	self[\header].clear;
	if(self[\currentMsgs].notNil) {
		self[\currentMsgs].do({ |msg| msg.clear; });
		self[\currentMsgs].clear;
	};
	self[\ui].clear;
	self.clear;
},

setPlayer: { |self, player|
	self[\player] = player;
	player[\discreteSynths].add(self);
	self.setMaxBeat(player[\nBeats]);
	// Regenerate header to account for
	// the new target group
	self.setOut(player[\defaultOut]);
	self.generateHeader;
	self.updateMsg;
},

getSaveData: { |self, dataName|
	var data = ();

	data[\name] = dataName;

	[
		\nBeats,
		\triggers,
		\out,
		\params,
		\track,
		\paramsModes,
	].do({ |symbol|
		data[symbol] = self[symbol].deepCopy;
	});

	if(self[\tunable]) {
		[
			\freqs,
			\mixFreqs
		].do({ |symbol|
			data[symbol] = self[symbol].deepCopy;
		});
	};

	data
},

loadData: { |self, data|
	[
		\nBeats,
		\triggers,
		\out,
		\params,
		\track,
		\paramsModes,
	].do({ |symbol|
		self[symbol].clear;
		self[symbol] = data[symbol].deepCopy;
		data[symbol].clear;
	});

	if(self[\tunable]) {
		[
			\freqs,
			\mixFreqs
		].do({ |symbol|
			self[symbol].clear;
			self[symbol] = data[symbol].deepCopy;
			data[symbol].clear;
		});
	};

	self.updateMsg;

	// Ask UI update
	self.notifyUI(\trigger);
	self.notifyUI(\freqs);
	self.notifyUI(\nBeats);
	self.notifyUI(\out);
	self[\params].keysDo({ |key|
		self.notifyUI(key); });
	self.notifyUI(\mixFreqs);

	// Clear collections
	[
		\nBeats,
		\triggers,
		\out,
		\params,
		\track,
		\paramsModes,
	].do({ |symbol| data[symbol].clear; });

	if(self[\tunable])
	{ data[\freqs].clear; };
	data.clear;
},

init: { |self|
	// Construct osc msg header
	self.generateHeader;

	// Score related datas
	self[\triggers] = List(0);
	self[\params] = ();
	self[\defaultParams] = ();
	self[\track] = List(0);
	self[\defaultTrack] = List(0);
	self[\paramsModes] = ();

	// if synth is tunable, triggers can be set to one
	// cause nil frequencies still mute the synth
	if(self[\tunable]) {
		self[\freqs] = List(0).add(nil);
		self[\triggers].add(1);
	} {
		self[\triggers].add(0);
	};

	// Fetch params default values
	self[\data][\params].do({ |param, index|
		self[\defaultParams][param[\symbol]] =
		param[\default];
	});

	// Fill placeholders
	self[\params] = self[\defaultParams].deepCopy;
	self[\track].add(self[\defaultParams].deepCopy);
	self[\defaultTrack].add(self[\defaultParams].deepCopy);
	self[\defaultParams].keysDo({ |key|
		self[\paramsModes][key] = \value; });

	// Set default out
	self[\out] = 0;

	// Misc
	self[\currentMsgs] = nil;
	self[\nBeats] = 1;

	if(self[\defaultParams].includesKey(\amp))
	{ self[\hasAmpParam] = true; }
	{ self[\hasAmpParam] = false; };

	if(self[\tunable])
	{ self[\mixFreqs] = true; };

	self[\ui] = ();
},
).parent_(~gmDef[\synthParent])