(
setSynth: { |self, synth|
	self[\synthView].setSynth(synth);
},

setPlayer: { |self, player|
	self[\playerView].setPlayer(player);
	self[\synthView].setPlayer(player);
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\playerView].setStyles(
		style,
		textStyle,
		widgetStyle
	);
},

doFront: { |self| self[\window].front; },

init: { |self|
	self[\window] = Window(
		"ModHa - SingleView",
		Rect(
			Window.screenBounds.width * 0.1,
			Window.screenBounds.height * 0.1,
			Window.screenBounds.width * 0.8,
			Window.screenBounds.height * 0.8
		);
	)
	.acceptsMouseOver_(true);
	self[\playerView] = ~gmDef.getMiniPlayerView;
	self[\synthView] = ~gmDef.getSynthView;
	// Layout
	self[\window].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\playerView][\view], 1)
		.add(self[\synthView][\view], 9)
	);
	CmdPeriod.doOnce({ self[\window].close; });
	self
},
)