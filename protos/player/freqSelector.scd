(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\diapasonFunction] = {
		self[\freqSlider]
		.min_(player[\diapason])
		.max_(player[\diapason] * 2);
	};
	self[\freqFunction] = {
		var selectorIndex = -1;
		self[\freqSlider].value_(player[\freq]);
		((Scale.at(\chromatic).ratios ++ [2]) * player[\diapason])
		.do({ |note, index|
			if(note.asInteger == player[\freq].asInteger)
			{ selectorIndex = index; };
		});
		if(selectorIndex > -1)
		{ self[\freqSelector].state_(selectorIndex); }
		{ self[\freqSelector].desindex; };
	};
	self[\freqSlider].action_({ |value|
		player.setFreq(value);
	});
	self[\freqSelector].action_({ |index|
		var chromaNotes = Scale.at(\chromatic).ratios;
		chromaNotes = chromaNotes ++ [2];
		chromaNotes = chromaNotes * player[\diapason];
		player.setFreq(chromaNotes[index]);
	});
	self[\diapasonFunction].value;
	self[\freqFunction].value;
	self[\player].addSignal(\diapason, self[\diapasonFunction]);
	self[\player].addSignal(\freq, self[\freqFunction]);
	// Disconnect self if player removed
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\diapason, self[\diapasonFunction]);
		self[\player].rmSignal(\freq, self[\freqFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\diapasonFunction] = nil;
		self[\freqFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\freqSlider].action_({});
		self[\freqSelector].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\freqSlider].style_(style);
	self[\freqSelector].style_(style);
	self[\label].style_(textStyle);
},

doRemove: { |self|
	self.disconnect;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\view] = UserView();
	self[\freqSlider] = GMSymbolSlider()
	.scale_(\exp)
	.orientation_(\horizontal)
	.fontRatio_(0.7);
	self[\freqSelector] = GMMultiButton()
	.fontRatio_(0.5)
	.states_([
		"A", "Bb", "B", "C", "Db", "D",
		"Eb", "E", "F", "F#", "G", "Ab", "A"
	]);
	self[\label] = GMTextView()
	.displayFrame_(true)
	.string_("freq")
	.fontRatio_(0.8)
	.maxFontSize_(24)
	.maxWidth_(192);
	self[\player] = nil;
	self[\view].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\label], 1)
		.add(
			VLayout()
			.margins_(0)
			.spacing_(0)
			.add(self[\freqSlider], 1)
			.add(self[\freqSelector], 1),
			9
		)
	);
	self
},
)