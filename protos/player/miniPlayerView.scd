(
setPlayer: { |self, player|
	if(self[\player].isNil) {
		self[\player] = player;
		self[\views].do({ |view|
				view.setPlayer(player); });
	} {
		"ModHa: miniPlayerView: player reassignment unsupported".warn;
	};
},

hideTempo: { |self|
	self[\tempoSlider][\view].visible_(false);
},

hideRythm: { |self|
	self[\playButton][\view].visible_(false);
	self[\rythmSelector][\view].visible_(false);
	self[\maxCycleSwitch][\view].visible_(false);
},

hideTuning: { |self|
	self[\tuningView].visible_(false);
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].background_(
		Color(
			style.backColor.red * 0.666,
			style.backColor.green * 0.666,
			style.backColor.blue * 0.666
		)
	);
	self[\playButton].setStyles(style, textStyle, widgetStyle);
	self[\views].do({ |view|
		view.setStyles(style, textStyle, widgetStyle); });
	self[\recordButton].style_(widgetStyle);
},

doRemove: { |self|
	self[\views].do({ |view| view.doRemove; });
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\player] = nil;
	self[\view] = UserView();
	self[\window] = nil;
	self[\playButton] = ~gmDef.getPlayButton;
	self[\playButton][\view].maxWidth_(192);
	// Tempo & Rythm
	self[\tempoSlider] = ~gmDef.getTempoSlider;
	self[\rythmSelector] = ~gmDef.getRythmSelector;
	self[\rythmSelector]
	.setDivs_([2, 3, 4, 6, 8])
	.setSubdivs_([2, 3, 4, 6, 8])
	.hideLabel;
	// Freq & Scale switches
	self[\freqSwitch] = ~gmDef.getFreqSwitch;
	self[\scaleSwitch] = ~gmDef.getScaleSwitch;
	self[\tuningView] = UserView()
	.maxWidth_(192)
	.layout_(
		VLayout()
		.spacing_(0)
		.margins_(0)
		.add(self[\freqSwitch][\view], 1)
		.add(self[\scaleSwitch][\view], 1)
	);
	// Cycles Switch
	self[\maxCycleSwitch] = ~gmDef.getMaxCycleSwitch;
	self[\maxCycleSwitch][\view].maxWidth_(192);
	// Record button stays independant for now
	self[\recordButton] = GMRecordButton()
	.symbolRatio_(0.4)
	.maxWidth_(192);
	// Layout
	self[\view].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\playButton][\view], 1)
		.add(self[\tempoSlider][\view], 2)
		.add(self[\rythmSelector][\view], 3)
		.add(self[\tuningView], 2)
		.add(self[\maxCycleSwitch][\view], 2)
		.add(self[\recordButton], 1)
	);
	self[\views] = [
		self[\playButton],
		self[\tempoSlider],
		self[\rythmSelector],
		self[\freqSwitch],
		self[\scaleSwitch],
		self[\maxCycleSwitch],
	];
	self
},
)