(
setPlayer: { |self, player|
	if(self[\player].isNil) {
		self[\playerView].setPlayer(player);
		self[\synths].do({ |s|
			s[\synth].setPlayer(player);
			s[\synthView].setPlayer(player);
		});
		self[\player] = player;
	} {
		"ModHa: invoker: player reassignment unsupported".warn;
	};
},

getUniqueName: { |self, synth|
	var defaultName;
	var currentName;
	var nameIndex = 1;
	var hasUniqueName = false;
	var nameCollision = false;
	defaultName = synth[\name];
	currentName = synth[\name];
	// Assign an unique name to the synth
	while { hasUniqueName.not } {
		nameCollision = false;
		self[\synths].do({ |synthProto|
			if(nameCollision.not) {
				if(synthProto[\synth][\name] == currentName)
				{ nameCollision = true; };
			};
		});
		if(nameCollision) {
			nameIndex = nameIndex + 1;
			currentName = defaultName ++ " " ++ nameIndex;
		} {
			synth.setName(currentName);
			hasUniqueName = true;
		};
	};
},

invokeSynth: { |self, def|
	var dict = ();
	dict[\synth] = ~gmDef.getSynth(def[\name].asSymbol);
	self.getUniqueName(dict[\synth]);
	if(self[\player].notNil)
	{ dict[\synth].setPlayer(self[\player]); };
	dict[\synthView] = ~gmDef.getSynthView;
	dict[\synthView].setSynth(dict[\synth]);
	dict[\synthView].hideRemove;
	if(self[\player].notNil)
	{ dict[\synthView].setPlayer(self[\player]); };
	dict[\window] = Window(
		dict[\synth][\name],
		Rect(
			Window.screenBounds.width * 0.2,
			Window.screenBounds.height * 0.2,
			Window.screenBounds.width * 0.4,
			Window.screenBounds.height * 0.4
		);
	);
	dict[\window].view.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(dict[\synthView][\view]);
	);
	if(self[\style].notNil) {
		dict[\synthView].setStyles(
			self[\style],
			self[\textStyle],
			self[\widgetStyle]
		);
	};
	dict[\nameFunc] = { dict[\window].title_(dict[\synth][\name]); };
	dict[\synth].connectSignal(\name, dict[\nameFunc]);
	// Equivalent to doRemove
	dict[\window].onClose_({
		dict[\synth].rmSignal(\name, dict[\nameFunc]);
		dict[\synth].doRemove;
		dict[\synthView].doRemove;
		self[\synths].remove(dict);
		dict.clear;
	});
	self[\synths].add(dict);
	dict[\window].front;
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\style] = style;
	self[\textStyle] = textStyle;
	self[\widgetStyle] = widgetStyle;
	self[\playerView].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\gmDefSelector].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\synths].do({ |s|
		s[\synthView].setStyles(
			style,
			textStyle,
			widgetStyle
		);
	});
},

doFront: { |self|
	self[\window].front;
},

doRemove: { |self|
	self[\synths].do({ |s|
		// Closing window will implicitely
		// remove everything
		s[\window].close;
	});
	self[\synths].clear;
	if(self[\player].notNil)
	{ self[\player].doRemove; };
	self[\playerView].doRemove;
	self[\gmDefSelector].doRemove;
	self[\window].view.removeAll;
	self[\window].view.remove;
	self[\window].close;
	self.clear;
},

init: { |self|
	self[\style] = nil;
	self[\textStyle] = nil;
	self[\widgetStyle] = nil;
	self[\player] = nil;
	self[\synths] = List(0);
	self[\window] = Window(
		"ModHa - Invoker",
		Rect(
			Window.screenBounds.width * 0.1,
			Window.screenBounds.height * 0.1,
			Window.screenBounds.width * 0.8,
			Window.screenBounds.height * 0.8
		);
	)
	.acceptsMouseOver_(true);
	self[\playerView] = ~gmDef.getMiniPlayerView;
	self[\gmDefSelector] = ~gmDef.getGMDefSelector;
	self[\gmDefSelector].assignFunction({ |def|
		self.invokeSynth(def);
	});
	// Layout
	self[\window].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\playerView][\view], 1)
		.add(self[\gmDefSelector][\view], 9)
	);
	self[\window].onClose_({ self.doRemove; });
	self
},
)