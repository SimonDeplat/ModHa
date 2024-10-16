(
setPlayer: { |self, player|
	self.disconnect;
	self[\player] = player;
	self[\rythmFunction] = {
		var detectIndex;
		detectIndex = [
			1, 2, 3, 4,
			5, 6, 7, 8
		].indexOfEqual(player[\rythm][0]);
		if(detectIndex.isNil)
		{ self[\divSelector].desindex; }
		{ self[\divSelector].state_(detectIndex); };
		detectIndex = [
			1, 2, 3, 4,
			5, 6, 7, 8
		].indexOfEqual(player[\rythm][1]);
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
			[
				1, 2, 3, 4,
				5, 6, 7, 8
			][index],
			player[\rythm][1]
		]);
	});
	self[\subdivSelector].action_({ |index|
		player.setRythm([
			player[\rythm][0],
			[
				1, 2, 3, 4,
				5, 6, 7, 8
			][index]
		]);
	});
	self[\rythmFunction].value;
	self[\player].addSignal(\rythm, self[\rythmFunction]);
},

disconnect: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\rythm, self[\rythmFunction]);
		self[\rythmFunction] = nil;
		self[\divSelector].action_({});
		self[\subdivSelector].action_({});
		self[\player] = nil;
	};
},

setStyles: { |self, style, textStyle|
	self[\divSelector].style_(style);
	self[\subdivSelector].style_(style);
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
	self[\divSelector] = GMMultiButton()
	.states_([
		"1", "2", "3", "4",
		"5", "6", "7", "8"]);
	self[\subdivSelector] = GMMultiButton()
	.states_([
		"1", "2", "3", "4",
		"5", "6", "7", "8"]);
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