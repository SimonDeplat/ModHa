(
type: \discrete,

setPlayer: { |self, player|
	self[\player] = player;
	self.setOut(player[\defaultOut]);
	self.setMaxBeat(player[\nBeats]);
	// Regenerate header to account for
	// the new target group
	self.generateHeader;
	self.updateMsg;
	self[\playerRMFunction] = { self.disconnectPlayer; };
	// Update player
	player.addSignal(\remove, self[\playerRMFunction]);
	player[\discreteSynths].add(self);
	player[\synths].add(self);
	if(self[\hasTempoParam]) {
		player[\tempoSynths].add(self);
		self.setTempo(player[\tempo]);
	};
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		// Update player
		var oldMsgs;
		if(self[\currentMsgs].notNil) {
			oldMsgs = self[\currentMsgs].deepCopy;
		} {
			oldMsgs = nil;
		};
		self[\player].notifyMsgsChange(oldMsgs, nil);
		if(oldMsgs.notNil) {
			oldMsgs.clear;
		};
		self[\player][\discreteSynths].remove(self);
		self[\player][\synths].remove(self);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\playerRMFunction] = nil;
		// Update self
		self[\player] = nil;
	};
},

audibleAt: { |self, time|
	var audible = true;
	if(self[\hasAmpParam]) {
		audible = self[\muted].not;
	};
	if(audible) {
		time = time%self[\nBeats];
		audible = self[\triggers][time].coin;
	};
	if(audible) {
		if(self[\hasAmpParam]
			and: { self[\track][time][\amp] == 0 }) {
				audible = false;
			};
	};
	if(audible) {
		if(self[\tunable]
			and: { self[\freqs][time] == nil; }) {
				audible = false;
			};
	};
	audible
},

getMsgAt: { |self, time|
	// FIX ME: SHOULD ONLY CHANGE CONTROLS THAT ACTUALLY CHANGED
	var msgs = nil;
	var oscMsg = self[\header].deepCopy.asList;
	time = time%self[\nBeats];
	msgs = List(0);
	// Fill params
	self[\track][time].keysValuesDo({ |symbol, value|
		oscMsg.add(symbol);
		switch(self[\data][\param][symbol][\type])
		{ \env } {
			oscMsg.add($[);
			value.asControlInput.do({ |segment|
				oscMsg.add(segment); });
			oscMsg.add($]);
		}
		{ \timeTempo } {
			oscMsg.add(
				(self[\tempo] / 60)
				* value.reciprocal
			);
		}
		{ \freqTempo } {
			oscMsg.add(
				(self[\tempo] / 60)
				* value
			);
		}
		{
			// Special case, polyphonic mixer
			if(
				(symbol == \amp)
				and: {
					self[\tunable]
					and: { self[\mixFreqs] }
				}
			) { self[\freqs][time].size.do({ value = value * 0.8; }); };
			oscMsg.add(value);
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
	msgs[0].postln;
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
		self[\player].notifyMsgsChange(oldMsgs, newMsgs);
		if(oldMsgs.notNil)
		{ oldMsgs.clear; };
	};
},

setMuted: { |self, aBoolean|
	self[\muted] = aBoolean;
	self.updateMsg;
	self.emitSignal(\mute);
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
		self.emitSignal(symbol);
	};
},

setMode: { |self, symbol, mode|
	self[\paramsModes][symbol] = mode;
	if(mode == \value) {
		self.setParam(
			symbol,
			-1,
			self[\params][symbol]
		);
	};
	self.emitSignal(symbol);
},

setTrigger: { |self, index, value|
	if(index < self[\nBeats]) {
		self[\triggers][index] = value;
		if(self[\player].notNil
			and: { self[\player][\currentBeat] == index })
		{ self.updateMsg; };
	};
	self.emitSignal(\trigger);
},

setFreq: { |self, index, value|
	if(self[\tunable] and: { index < self[\nBeats] }) {
		self[\freqs][index] = value;
		if(self[\player].notNil
			and: { self[\player][\currentBeat] == index })
		{ self.updateMsg; };
	};
},

setTempo: { |self, tempo|
	if(self[\hasTempoParam]) {
		self[\tempo] = tempo;
		self.updateMsg;
	};
},

setMasterOut: { |self, data|
	self[\out] = data[\bus].index;
},

setEffectOut: { |self, data|
	self[\out] = data[\bus].index;
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
	self.updateMsg;
	self[\outNode] = data;
	self.emitSignal(\out);
},

setMaxBeat: { |self, maxBeat|
	if(self[\nBeats] != maxBeat) {
		self[\nBeats] = maxBeat;
		if(self[\trigger].size < self[\nBeats]) {
			while { self[\triggers].size < self[\nBeats] } {
				if(self[\tunable]) {
					self[\triggers].add(1);
				} {
					self[\triggers].add(0);
				};
				self[\freqs].add(nil);
			};
		} {
			while { self[\triggers].size > self[\nBeats] } {
				self[\triggers].pop;
				self[\freqs].pop;
			};
		};
		self.resizeTrack;
		self.updateMsg;
	};
},

setMixFreqs: { |self, aBoolean|
	self[\mixFreqs] = aBoolean;
	self.updateMsg;
	self.emitSignal(\mixFreqs);
},

// /!\ WIP: Out not saved for now
getSaveData: { |self, dataName|
	var data = ();
	data[\name] = dataName;
	[
		\nBeats,
		\triggers,
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
	// Adapt to current rythm
	// (temporary)
	if(self[\player].notNil) {
		self.setMaxBeat(self[\player][\nBeats]);
	};
	self.updateMsg;
	// Ask UI update
	self.emitSignal(\trigger);
	self.emitSignal(\freqs);
	self.emitSignal(\nBeats);
	self[\params].keysDo({ |symbol|
		self.emitSignal(symbol); });
	self.emitSignal(\mixFreqs);
	data.clear;
},

constructTrack: { |self|
	self[\triggers] = List(0);
	if(self[\tunable]) {
		self[\freqs] = List(0);
	};
	self[\defaultTrack] = self[\params].deepCopy;
	self[\nBeats].do({
		self[\track].add(self[\defaultTrack].deepCopy);
		if(self[\tunable]) {
			// if synth is tunable, triggers can be set to one
			// cause nil frequencies still mute the synth
			self[\freqs].add(nil);
			self[\triggers].add(1);
		} {
			self[\triggers].add(0);
		};
	});	
},

resizeTrack: { |self|
	if(self[\track].size < self[\nBeats]) {
		while { self[\track].size < self[\nBeats] } {
			self[\track].add(self[\defaultTrack].deepCopy);
		};
	} {
		while { self[\track].size > self[\nBeats] } {
			self[\track].pop;
		};
	};
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
	// Remove self from gmDef synths list
	~gmDef[\synths].removeAt(self[\id]);
	self.clear;
},

init: { |self|
	self.initParent;
	// Construct osc msg header
	self.generateHeader;
	// Construct track & stuff
	self.constructTrack;
	// Misc
	self[\currentMsgs] = nil;
	if(self[\tunable])
	{ self[\mixFreqs] = true; };
},
).parent_(~gmDef[\synthParent])