(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\maxCycleFunction] = {
		var detectIndex = self[\cycles].indexOfEqual(player[\maxCycle]);
		if(detectIndex.isNil)
		{ self[\view].states_(["-"]); }
		{ self[\view].state_(detectIndex); };
	};
	self[\view].action_({ |index|
		if(self[\view].states == ["-"]) {
			player.setMaxCycle(self[\cycles][0]);
			self[\view].states_(
				self[\cycles].collect({ |n| ("cycles: " ++ n.asString) })
			);
		} {
			player.setMaxCycle(self[\cycles][index]);
		};
	});
	self[\maxCycleFunction].value;
	self[\player].addSignal(\maxCycle, self[\maxCycleFunction]);
	self[\playerRMFunction] = { self.disconnect; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\maxCycle, self[\maxCycleFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\maxCycleFunction] = nil;
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
	self[\cycles] = [1, 2, 4, 8, 16, inf];
	self[\view] = GMSwitchButton()
	.fontRatio_(0.25)
	.states_(self[\cycles].collect({ |n| ("cycles: " ++ n.asString) }));
	self
},
)