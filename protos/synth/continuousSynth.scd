(
type: \continuous,

setPlayer: { |self, player|
	// Update self
	self[\player] = player;
	self.setOut(player[\defaultOut]);
	self.setFreq(player[\freq]);
	self.setMaxBeat(player[\nBeats]);
	self[\playerRMFunction] = { self.disconnectPlayer; };
	if(self[\synth].notNil) {
		self[\synth].moveToHead(player[\continuousGroup]);
	};
	self[\playerStopFunction] = {
		if(self[\hasAmpParam]) {
			self[\synth].set(\amp, 0);
			self[\currentScore][\amp] = 0;
		};
		self[\nextScore] = self[\currentScore].deepCopy;
	};
	// Update player
	player.addSignal(\remove, self[\playerRMFunction]);
	player.addSignal(\stop, self[\playerStopFunction]);
	player[\continuousSynths].add(self);
	player[\synths].add(self);
	if(self[\hasTempoParam]) {
		player[\tempoSynths].add(self);
		self.setTempo(player[\tempo]);
	};
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		// Update player
		if(self[\currentMsg].notNil) {
			self[\player].notifyMsgChange(self[\currentMsg], nil);
		};
		self[\player][\continuousSynths].remove(self);
		self[\player][\synths].remove(self);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\player].rmSignal(\stop, self[\playerStopFunction]);
		// Update self
		if(self[\synth].notNil) {
			self[\synth].moveToHead(~gmDef[\server].defaultGroup);
		};
		self[\player] = nil;
	};
},

playSynth: { |self|
	if(~gmDef[\server].serverRunning) {
		fork {
			var params = self[\params].deepCopy;
			var group = ~gmDef[\server].defaultGroupID;
			if(self[\player].notNil) {
				group = self[\player][\continuousGroup].nodeID;
			};
			if(self[\tunable]) {
				if(self[\player].notNil) {
					params[\freq] = self[\player][\freq];
				} {
					params[\freq] = 440;
				};
			};
			params[\out] = self[\out];
			s.sync;
			self[\synth] = Synth(
				self[\data][\symbol],
				params.asPairs,
				group,
				\addToTail
			);
			self[\nodeID] = self[\synth].nodeID;
			params.clear;
		};
	};
},

setMuted: { |self, aBoolean|
	if(self[\hasAmpParam]) {
		if(aBoolean) {
			self[\synth].set(\amp, 0);
			self[\muteAmp] = self[\params][\amp];
			self[\currentScore][\amp] = 0;
			self[\muted] = true;
			self.emitSignal(\mute);
		} {
			self[\synth].set(\amp, self[\muteAmp]);
			self[\currentScore][\amp] = self[\muteAmp];
			self[\muted] = false;
			self.emitSignal(\mute);
		};
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

setFreq: { |self, freq|
	if(self[\tunable]) {
		self[\synth].set(\freq, freq);
	};
},

setTempo: { |self, tempo|
	var value, nextValue;
	if(self[\hasTempoParam]) {
		self[\tempo] = tempo;
		if(self[\player].notNil) {
			var actualBeat = self[\player][\actualBeat]%self[\nBeats];
			var currentBeat = self[\player][\currentBeat]%self[\nBeats];
			self[\tempoParams].do({ |symbol|
				// Update current value;
				value = self[\track][actualBeat][symbol];
				nextValue = self[\track][currentBeat][symbol];
				switch(self[\data][\param][symbol][\type])
				{ \timeTempo } {
					value = (60 / self[\tempo]) * value;
					nextValue = (60 / self[\tempo]) * nextValue;
				}
				{ \freqTempo } {
					value = (60 / self[\tempo]) * value.reciprocal;
					nextValue = (60 / self[\tempo]) * nextValue.reciprocal;
				};
				self[\synth].set(symbol, value);
				self[\currentScore][symbol] = value;
				self[\nextScore][symbol] = nextValue;
			});
			self.updateMsg;
		};
	};
},

getScoreAt: { |self, time|
	// Implicitely, this means previous beat
	// has been played
	self[\currentScore] = self[\nextScore].deepCopy;
	time = time%self[\nBeats];
	self[\track][time].keysValuesDo({ |key, value|
		switch(self[\data][\param][key][\type])
		{ \timeTempo } {
			value = (60 / self[\tempo]) * value;
		}
		{ \freqTempo } {
			value = (60 / self[\tempo]) * value.reciprocal;
		};
		if(key != \amp) {
			if(self[\nextScore][key] != value) {
				self[\nextScore][key] = value;
			};
		} {
			// If key is amp
			if(self[\muted].not) {
				if(self[\nextScore][key] != value) {
					self[\nextScore][key] = value;
				};
			};
		};
	});
	self.updateCurrentMsg;
	self[\currentMsg]
},

updateMsg: { |self|
	if(self[\player].notNil) {
		var oldMsg = self[\currentMsg].deepCopy;
		self.updateCurrentMsg;
		self[\player].notifyMsgChange(oldMsg, self[\currentMsg]);
	};
},

// This checks queued differences between current and next states
// to construct the smallest osc msg possible
updateCurrentMsg: { |self|
	self[\currentMsg] = List(0);
	self[\currentMsg].add("/n_set");
	self[\currentMsg].add(self[\nodeID]);
	self[\nextScore].keysValuesDo({ |key, value|
		if(self[\paramsModes][key] == \track) {
			if(self[\currentScore][key] != value) {
				self[\currentMsg].add(key);
				self[\currentMsg].add(value);
			};
		};
	});
	if(self[\currentMsg].size > 2) {
		self[\currentMsg] = self[\currentMsg].asArray;
	} {
		self[\currentMsg] = nil;
	};
},

setParam: { |self, symbol, index, value|
	if(index < self[\nBeats]) {
		if(index == -1) {
			// If updating whole track at once:
			// Update internal datas
			self[\params][symbol] = value;
			self[\track].do({ |beat|
				beat[symbol] = value;
			});
			// Convert tempo value if needed
			switch(self[\data][\param][symbol][\type])
			{ \timeTempo } {
				value = (60 / self[\tempo]) * value;
			}
			{ \freqTempo } {
				value =	(60 / self[\tempo]) * value.reciprocal;
			};
			// Update synth
			self[\synth].set(symbol, value);
			// Update current and queued scores
			self[\currentScore][symbol] = value;
			self.updateMsg;
			// Update UI
			self.emitSignal(symbol);
			// Update mute status if needed
			if(symbol == \amp) {
				if(self[\muted]) {
					self[\muted] = false;
					self.emitSignal(\mute);
				};
			};
		} {
			// If only updating one track beat:
			var nextBeatIsNil = true;
			var impactsCurrentBeat = false;
			// Update internal datas
			self[\track][index][symbol] = value;
			self[\nilTrack][index][symbol] = value;
			// Check if updating current osc msg is needed
			if(self[\player].notNil
				and: { self[\player][\currentBeat] == index }) {
					impactsCurrentBeat = true;
				};
			// Fill rest of the track,
			// update current osc msg if needed
			(self[\nBeats] - index - 1).do({ |i|
				if(nextBeatIsNil) {
					if(self[\nilTrack][index + i + 1][symbol] == nil) {
						self[\track][index + i + 1][symbol] = value;
						if(self[\player].notNil
							and: { self[\player][\currentBeat] == (index + i + 1) }) {
								impactsCurrentBeat = true;
							};
					} {
						nextBeatIsNil = false;
					};
				};
			});
			// Update if current beat is concerned
			if(impactsCurrentBeat) {
				// Convert tempo value if needed
				switch(self[\data][\param][symbol][\type])
				{ \timeTempo } {
					value = (60 / self[\tempo]) * value;
				}
				{ \freqTempo } {
					value =	(60 / self[\tempo]) * value.reciprocal;
				};
				// Update synth
				self[\synth].set(symbol, value);
				// Update current and queued scores
				self[\currentScore][symbol] = value;
				self.updateMsg;
				// Update mute status if needed
				if(symbol == \amp) {
					if(self[\muted]) {
						self[\muted] = false;
						self.emitSignal(\mute);
					};
				};
			};
			// Update UI
			self.emitSignal(symbol);
		};
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
	{ \master } {
		self.setMasterOut(data);
	}
	{ \effect } {
		self.setEffectOut(data);
	};
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

constructTrack: { |self|
	self[\params].keysDo({ |key|
		self[\nilParams][key] = nil;
	});
	self[\currentScore] = self[\params].deepCopy;
	self[\nextScore] = self[\params].deepCopy;
	self[\nBeats].do({
		self[\track].add(self[\params].deepCopy);
	});
	self[\nilTrack].add(self[\params].deepCopy);
	(self[\nBeats] - 1).do({
		self[\nilTrack].add(self[\nilParams].deepCopy);
	});
},

resizeTrack: { |self|
	if(self[\track].size < self[\nBeats]) {
		while { self[\track].size < self[\nBeats] } {
			self[\track].add(self[\track][self[\track].size - 1].deepCopy);
			self[\nilTrack].add(self[\nilParams].deepCopy);
		};
	} {
		while { self[\track].size > self[\nBeats] } {
			self[\track].pop;
			self[\nilTrack].pop;
		};
	};
},

setMaxBeat: { |self, maxBeat|
	if(self[\nBeats] != maxBeat) {
		self[\nBeats] = maxBeat;
		self.resizeTrack;
	}
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
		and: { self[\synth].notNil }) {
			self[\synth].free;
	};
	// Remove self from gmDef synths list
	~gmDef[\synths].removeAt(self[\id]);
	self.clear;
},

init: { |self|
	self.initParent;
	self[\synth] = nil;
	self[\nilParams] = ();
	self[\nilTrack] = List(0);
	self[\currentMsg] = nil;
	// Construct track & stuff
	self.constructTrack;
	// Play synth
	self.playSynth;
},
).parent_(~gmDef[\synthParent])