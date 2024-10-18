(
setPlayer: { |self, player|
	self.disconnectPlayer;
	self[\player] = player;
	self.updateStates;
	self[\nBeatFunc] = { self.updateStates; };
	self[\highlightsFunc] = { self.updateStates; };
	self[\player].addSignal(\rythm, self[\nBeatFunc]);
	self[\player].addSignal(\highlights, self[\highlightsFunc]);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\rythm, self[\nBeatFunc]);
		self[\player].rmSignal(\highlights, self[\highlightsFunc]);
		self[\player] = nil;
		self[\nBeatFunc] = nil;
		self[\highlightsFunc] = nil;
		self[\selectedBeat] = -1;
	};
},

setSelectedBeat: { |self, beat|
	self[\selectedBeat] = beat;
	if(beat == -1)
	{ self[\view].desindex; }
	{ self[\view].state_(beat); };
},

updateStates: { |self|
	if(self[\player].notNil) {
		self[\view].states_(
			Array.fill(
				self[\player][\nBeats], { |i|
					(
						string: "",
						color: Color(
							1, 1, 1,
							self[\player][\highlights][i%self[\player][\nBeats]]
						),
						fontColor: Color.black,
					)
				};
			);
		);
		if(self[\selectedBeat] == -1)
		{ self[\view].desindex; }
		{ self[\view].state_(self[\selectedBeat]); };
	};
},

setSynthView: { |self, view|
	self[\synthView] = view;
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\view].style_(style);
},

init: { |self|
	self[\selectedBeat] = -1;
	self[\synthView] = nil;
	self[\view] = GMMultiButton()
	.allowRetrigger_(true)
	.action_({ |index|
		if(self[\synthView].notNil)
		{ self[\synthView].setSelectedBeat(index); };
	});
	self
},
)