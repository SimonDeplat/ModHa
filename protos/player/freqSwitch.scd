(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\freqFunction] = {
		var selectorIndex = -1;
		((Scale.at(\chromatic).ratios ++ [2]) * player[\diapason])
		.do({ |note, index|
			if(note.asInteger == player[\freq].asInteger)
			{ selectorIndex = index; };
		});
		if(selectorIndex > -1)
		{ self[\view].state_(selectorIndex); }
		{ self[\view].states_(["-"]); };
	};
	self[\view].action_({ |index|
		if(self[\view].states == ["-"]) {
			player.setFreq(player[\diapason]);
			self[\view].states_([
				"A", "Bb", "B", "C", "Db", "D",
				"Eb", "E", "F", "F#", "G", "Ab"
			]);
		} {
			var chromaNotes = Scale.at(\chromatic).ratios;
			chromaNotes = chromaNotes * player[\diapason];
			player.setFreq(chromaNotes[index]);
		};
	});
	self[\freqFunction].value;
	self[\player].addSignal(\freq, self[\freqFunction]);
	// Disconnect self if player removed
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\freq, self[\freqFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\freqFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\view].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].style_(widgetStyle);
},

doRemove: { |self|
	self.disconnect;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\player] = nil;
	self[\view] = GMSwitchButton()
	.states_([
		"A", "Bb", "B", "C", "Db", "D",
		"Eb", "E", "F", "F#", "G", "Ab"
	]);
	self
},
)