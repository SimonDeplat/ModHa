(
// /!\ TO DO: change available tempi

setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\tempoFunction] = {
		var selectorIndex = -1;
		self[\tempoSlider].value_(player[\tempo]);
		[
			40, 60, 80 , 100,
			120, 140, 160
		].do({ |tempo, index|
			if(tempo == player[\tempo])
			{ selectorIndex = index; };
		});
		if(selectorIndex > -1)
		{ self[\tempoSelector].state_(selectorIndex); }
		{ self[\tempoSelector].desindex; };
	};
	self[\tempoSlider].action_({ |value|
		player.setTempo(value.asInteger);
	});
	self[\tempoSelector].action_({ |index|
		player.setTempo(
			[
				40, 60, 80 , 100,
				120, 140, 160
			][index]
		);
	});
	self[\tempoFunction].value;
	self[\player].addSignal(\tempo, self[\tempoFunction]);
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\tempo, self[\tempoFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\tempoFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\tempoSlider].action_({});
		self[\tempoSelector].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\tempoSlider].style_(style);
	self[\tempoSelector].style_(style);
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
	self[\tempoSlider] = GMSymbolSlider()
	.min_(20)
	.max_(200)
	.orientation_(\horizontal)
	.fontRatio_(0.5)
	.displayFunction_({ |value| value.asInteger });
	self[\tempoSelector] = GMMultiButton()
	.fontRatio_(0.5)
	.states_([
		"40", "60", "80", "100",
		"120", "140", "160"
	]);
	self[\label] = GMTextView()
	.displayFrame_(true)
	.string_("bpm")
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
			.add(self[\tempoSlider], 1)
			.add(self[\tempoSelector], 1),
			9
		)
	);
	self
},
)