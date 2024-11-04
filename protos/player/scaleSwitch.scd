(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\scaleFunction] = {
		var detectIndex =
		self[\scaleSymbols].indexOfEqual(player[\scale]);
		if(detectIndex.isNil)
		{ self[\view].states_(["-"]); }
		{ self[\view].state_(detectIndex); };
	};
	self[\view].action_({ |index|
		if(self[\view].states == ["-"]) {
			player.setScale(self[\scaleSymbols][0]);
			self[\view].states_(self[\scaleNames]);
		} {
			player.setScale(self[\scaleSymbols][index]);
		};
	});
	self[\scaleFunction].value;
	self[\player].addSignal(\scale, self[\scaleFunction]);
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\scale, self[\scaleFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\scaleFunction] = nil;
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
	self[\scaleNames] = [
		"Minor", "Locrian", "Major", "Dorian",
		"Phrygian", "Lydian", "Mixolydian"
	];
	self[\scaleSymbols] = [
		\minor, \ionian, \major, \dorian,
		\phrygian, \lydian, \mixolydian
	];
	self[\view] = GMSwitchButton()
	.states_(self[\scaleNames]);
	self[\player] = nil;
	self
},
)