(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\cycleFunction] = {
		var cycles = [
			player[\rythm][1],
			player[\rythm][0],
			player[\maxCycle],	
		];
		if(cycles[2] == inf) { cycles[2] = 4; };
		self[\view].cycles_(cycles);
		self.updateBeat;
	};	
	self[\beatFunction] = { self.updateBeat; };
	self[\cycleFunction].value;
	player.addSignal(\maxCycle, self[\cycleFunction]);
	player.addSignal(\rythm, self[\cycleFunction]);
	player.addSignal(\beat, self[\beatFunction]);
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\maxCycle, self[\cycleFunction]);
		self[\player].rmSignal(\rythm, self[\cycleFunction]);
		self[\player].rmSignal(\beat, self[\beatFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\cycleFunction] = nil;
		self[\beatFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\player] = nil;
	};
},

updateBeat: { |self|
	if(self[\player].notNil) {
		// /!\ FIX ME: Player method should return this:
		var states = [0, 0, 0];
		// Rythm subdivision
		states[0] = self[\player][\actualBeat] % self[\player][\rythm][1];
		// Time
		states[1] = self[\player][\actualBeat] - states[0];
		states[1] = states[1] % self[\player][\nBeats];
		states[1] = states[1] / self[\player][\rythm][1];
		// Cycle
		states[2] = self[\player][\actualBeat] - states[0];
		states[2] = states[2] - (states[1] * self[\player][\rythm][1]);
		states[2] = states[2] / self[\player][\nBeats];
		if(self[\player][\maxCycle] == inf)
		{ states[2] % 4 };
		self[\view].states_(states);
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].style_(style);
},

doRemove: { |self|
	self.disconnect;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\view] = GMCycleView();
	self[\player] = nil;
	self
},
)