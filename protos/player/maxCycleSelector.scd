(
// /!\ TO DO: allow to change available cycles

setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\maxCycleFunction] = {
		var detectIndex = self[\cycles].indexOfEqual(player[\maxCycle]);
		if(detectIndex.isNil)
		{ self[\cycleSelector].desindex; }
		{ self[\cycleSelector].state_(detectIndex); };
	};
	self[\cycleSelector].action_({ |index|
		player.setMaxCycle(self[\cycles][index]);
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
		self[\cycleSelector].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\cycleSelector].style_(widgetStyle);
	self[\label].style_(textStyle);
},

doRemove: { |self|
	self.disconnect;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\player] = nil;
	self[\view] = UserView();
	self[\cycles] = [1, 2, 4, 8, 16, inf];
	self[\cycleSelector] = GMMultiButton()
	.fontRatio_(0.5)
	.states_(self[\cycles].collect({ |n| n.asString }));
	self[\label] = GMTextView()
	.displayFrame_(true)
	.string_("cycles")
	.fontRatio_(0.8)
	.maxFontSize_(24)
	.maxWidth_(192);
	self[\view].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\label], 1)
		.add(self[\cycleSelector], 9);
	);
	self
},
)