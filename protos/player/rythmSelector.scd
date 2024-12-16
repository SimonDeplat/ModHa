(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\rythmFunction] = {
		var detectIndex = self[\divs].indexOfEqual(player[\rythm][0]);
		if(detectIndex.isNil)
		{ self[\divSelector].desindex; }
		{ self[\divSelector].state_(detectIndex); };
		detectIndex = self[\subdivs].indexOfEqual(player[\rythm][1]);
		if(detectIndex.isNil)
		{ self[\subdivSelector].desindex; }
		{ self[\subdivSelector].state_(detectIndex); };
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
	self[\divSelector].action_({ |index|
		player.setRythm([
			self[\divs][index],
			player[\rythm][1]
		]);
	});
	self[\subdivSelector].action_({ |index|
		player.setRythm([
			player[\rythm][0],
			self[\subdivs][index]
		]);
	});
	self[\rythmFunction].value;
	self[\player].addSignal(\rythm, self[\rythmFunction]);
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

setDivs: { |self, divs|
	self[\divs] = divs;
	self[\divSelector].states_(self[\divs].collect({ |n| n.asString; }));
	if(self[\player].notNil)
	{ self[\rythmFunction].value };
},

setSubdivs: { |self, divs|
	self[\subdivs] = divs;
	self[\subdivSelector].states_(self[\subdivs].collect({ |n| n.asString; }));
	if(self[\player].notNil)
	{ self[\rythmFunction].value };
},

hideLabel: { |self| self[\label].visible_(false); },

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\rythm, self[\rythmFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\rythmFunction] = nil;
		self[\playerRMFunction] = nil;
		self[\divSelector].action_({});
		self[\subdivSelector].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\divSelector].style_(widgetStyle);
	self[\subdivSelector].style_(widgetStyle);
	self[\label].style_(textStyle);
},

doRemove: { |self|
	self.disconnect;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\divs] = [1, 2, 3, 4, 5, 6, 7, 8, 9];
	self[\subdivs] = [1, 2, 3, 4, 5, 6, 7, 8, 9];
	self[\view] = UserView();
	self[\divSelector] = GMMultiButton()
	.states_(self[\divs].collect({ |n| n.asString; }));
	self[\subdivSelector] = GMMultiButton()
	.states_(self[\subdivs].collect({ |n| n.asString; }));
	self[\label] = GMTextView()
	.displayFrame_(true)
	.string_("rythm")
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
			.add(self[\divSelector], 1)
			.add(self[\subdivSelector], 1),
			9
		)
	);
	self
},
)