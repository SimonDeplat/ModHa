(
// /!\ TO DO: allow to change available scales

setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\scaleFunction] = {
		var detectIndex =
		self[\scaleSymbols].indexOfEqual(player[\scale]);
		if(detectIndex.isNil)
		{ self[\scaleSelector].desindex }
		{ self[\scaleSelector].state_(detectIndex); };
	};
	self[\scaleSelector].action_({ |index|
		player.setScale(self[\scaleSymbols][index]);
	});
	self[\scaleFunction].value;
	self[\player].addSignal(\scale, self[\scaleFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\scale, self[\scaleFunction]);
		self[\scaleFunction] = nil;
		self[\scaleSelector].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\scaleSelector].style_(style);
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
	self[\scaleNames] = [
		"Minor", "Locrian", "Major", "Dorian",
		"Phrygian", "Lydian", "Mixolydian"
	];
	self[\scaleSymbols] = [
		\minor, \ionian, \major, \dorian,
		\phrygian, \lydian, \mixolydian
	];
	self[\scaleSelector] = GMMultiButton()
	.fontRatio_(0.5)
	.states_(self[\scaleNames]);
	self[\label] = GMTextView()
	.displayFrame_(true)
	.string_("scale")
	.fontRatio_(0.8)
	.maxFontSize_(24)
	.maxWidth_(192);
	self[\player] = nil;
	self[\view].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\label], 1)
		.add(self[\scaleSelector], 9);
	);
	self
},
)