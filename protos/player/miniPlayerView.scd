(
setPlayer: { |self, player|
	if(self[\player].isNil) {
		self[\player] = player;
		self[\playButton].setPlayer(player);
		self[\rythmSelector].setPlayer(player);
		self[\freqSwitch].setPlayer(player);
		self[\scaleSwitch].setPlayer(player);
	} {
		"ModHa: singleView: player reassignment unsupported".warn;
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\playButton].setStyles(style, textStyle, widgetStyle);
	self[\rythmSelector].setStyles(style, textStyle, widgetStyle);
	self[\freqSwitch].setStyles(style, textStyle, widgetStyle);
	self[\scaleSwitch].setStyles(style, textStyle, widgetStyle);
},

init: { |self|
	self[\player] = nil;
	self[\view] = UserView();
	self[\window] = nil;
	self[\playButton] = ~gmDef.getPlayButton;
	// Rythm Selector
	self[\rythmSelector] = ~gmDef.getRythmSelector;
	self[\rythmSelector]
	.setDivs_([2, 3, 4, 6, 8])
	.setSubdivs_([2, 3, 4, 6, 8])
	.hideLabel;
	// Freq & Scale switches
	self[\freqSwitch] = ~gmDef.getFreqSwitch;
	self[\freqSwitch][\view].maxWidth_(192);
	self[\scaleSwitch] = ~gmDef.getScaleSwitch;
	self[\scaleSwitch][\view].maxWidth_(192);
	// Layout
	self[\view].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\playButton][\view], 1)
		.add(self[\rythmSelector][\view], 3)
		.add(
			VLayout()
			.spacing_(0)
			.margins_(0)
			.add(self[\freqSwitch][\view], 1)
			.add(self[\scaleSwitch][\view], 1),
			2
		)
	);
	self
},
)