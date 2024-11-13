(
setPlayer: { |self, player|
	if(self[\player].isNil) {
		self[\player] = player;
		self[\playerView].setPlayer(player);
		self[\synthView].setPlayer(player);
		self[\sections].do({ |section|
			section[\synth].do({ |synth| synth.setPlayer(player); });
		});
	} {
		"ModHa: Orchestra: player reassignment unsupported".warn;
	};
},

addSection: { |self, name|
	var sectionIndex = nil;
	self[\sections].add(
		(
			name: name,
			synths: List(0),
			currentSynth: nil,
		)
	);
	self[\sectionSelector].states_(
		["Player"] ++
		self[\sections].collect({ |section| section[\name] })
	);
	self[\sections].do({ |section, index|
		if(sectionIndex.isNil) {
			if(section[\name] == name)
			{ sectionIndex = index; };
		};
	});
	self.selectSection(sectionIndex);
},

selectSection: { |self, index|
	self[\currentSection] = self[\sections][index];
	if(self[\currentSection][\currentSynth].notNil)
	{ self[\synthView].setSynth(self[\currentSection][\currentSynth]); }
	{ self[\synthView].disconnectSynth; };
	self[\sectionSelector].state_(index + 1);
	self.updateSynthSelector;
	self[\synthMenu].visible_(true);
	self[\layout].index_(1);
},

addSynth: { |self, synthData|
	var synth = ~gmDef.getSynth(synthData[\name].asSymbol);
	if(self[\player].notNil)
	{ synth.setPlayer(self[\player]); };
	self[\synthView].connectSynth(synth);
	self[\currentSection][\synths].add(synth);
	self[\synthRMfuncs][synth[\id]] = { self.removeSynth(synth); };
	synth.addSignal(\remove, self[\synthRMfuncs][synth[\id]]);
	// Set synth as current selection
	self[\currentSection][\currentSynth] = synth;
	self.updateSynthSelector;
	self[\synthView].setSynth(synth);
},

removeSynth: { |self, synth|
	self[\sections].do({ |section, index|
		if(section[\synths].includes(synth)) {
			var index = section[\synths].indexOfEqual(synth);
			index = max(
				0,
				index - 1
			);
			section[\synths].remove(synth);
			if(section[\currentSynth] == synth) {
				if(section[\synths].size > 0) {
					section[\currentSynth] = section[\synths][index];
				} {
					section[\currentSynth] = nil;
				};
			};
			if(self[\currentSection] == section) {
				if(section[\currentSynth].notNil)
				{ self[\synthView].setSynth(section[\currentSynth]); }
				{ self[\synthView].disconnectSynth; };
				self.updateSynthSelector;
			};
		};
	});
	// Remove stored signal function
	self[\synthRMfuncs].removeAt(synth[\id]);
},

updateSynthSelector: { |self|
	if(self[\currentSection][\synths].size > 0) {
		self[\synthSelector].states_(
			self[\currentSection][\synths].collect({ |synth| synth[\name] });
		);
		self[\synthSelector].state_(
			self[\currentSection][\synths].indexOf(self[\currentSection][\currentSynth]);
		);
	} {
		self[\synthSelector].states_([""]);
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\style] = style;
	self[\textStyle] = textStyle;
	self[\widgetStyle] = widgetStyle;
	self[\window].background_(style.secondBorderColor);
	self[\sectionSelector].style_(style);
	self[\addSectionButton].style_(style);
	self[\synthSelector].style_(style);
	self[\addSynthButton].style_(style);
	self[\gmDefSelectorView].background_(style.secondBorderColor);
	self[\gmDefSelectorLabel].style_(textStyle);
	self[\gmDefSelectorCloseButton].style_(widgetStyle);
	self[\gmDefSelector].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\playerView].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\synthView].setStyles(
		style,
		textStyle,
		widgetStyle
	);
},

doTextInput: { |self, text = "", defaultText = "", function|
	var view = UserView()
	.maxWidth_(720)
	.maxHeight_(64 * 3);
	var label = GMTextView()
	.fontRatio_(0.5)
	.displayFrame_(true)
	.string_(text);
	var closeButton = GMCloseButton()
	.action_({
		self[\overlay].visible_(false);
		view.removeAll;
		view.remove;
	});
	var textInput = TextField()
	.minHeight_(0)
	.string_(defaultText)
	.align_(\center)
	.action_({
		function.value(textInput.string);
		self[\overlay].visible_(false);
		view.removeAll;
		view.remove;
	})
	.focus;
	var validateButton = GMButton()
	.maxWidth_(192)
	.svg_(~gmDef.getIcon(\check))
	.action_({
		function.value(textInput.string);
		self[\overlay].visible_(false);
		view.removeAll;
		view.remove;
		
	});
	if(self[\style].notNil) {
		view.background_(self[\style].backColor);
		label.style_(self[\textStyle]);
		closeButton.style_(self[\widgetStyle]);
		textInput.font_(self[\style].font);
		validateButton.style_(self[\widgetStyle]);
	};
	view.layout_(
		VLayout()
		.spacing_(2)
		.margins_(2)
		.add(
			HLayout()
			.margins_(0)
			.spacing_(0)
			.add(label, 9)
			.add(closeButton, 1),
			1
		)
		.add(textInput, 1)
		.add(
			HLayout()
			.margins_(0)
			.spacing_(0)
			.add(validateButton),
			1
		)
	);
	self[\overlay].layout_(
		HLayout()
		.spacing_(0)
		.margins_(0)
		.add(view)
	);
	self[\overlay].visible_(true);
},

doFront: { |self|
	self[\window].front;
},

doRemove: { |self|
	// Remove views
	self[\synthView].doRemove;
	self[\playerView].doRemove;
	// Clear sections (thus synths)
	self[\sections].do({ |section|
		section[\synths].do({ |synth|
			// Disconnect \remove func to prevent infinite loop
			synth.rmSignal(\remove, self[\synthRMfuncs][synth[\id]]);
			self[\synthRMfuncs].removeAt(synth[\id]);
			synth.doRemove;
		});
		section[\synths].clear;
		section.clear;
	});
	self[\sections].clear;
	// Remove player
	if(self[\player].notNil)
	{ self[\player].doRemove; };
	self[\synthRMfuncs].clear;
	self[\window].view.removeAll;
	self[\window].view.remove;
	self[\window].close;
	self.clear;
},

init: { |self|
	// Variables
	self[\style] = nil;
	self[\textStyle] = nil;
	self[\widgetStyle] = nil;
	self[\player] = nil;
	self[\synths] = List(0);
	self[\sections] = List(0);
	self[\currentSection] = nil;
	self[\synthRMfuncs] = ();
	// Window
	self[\window] = Window(
		"ModHa - Orchestra",
		Rect(
			Window.screenBounds.width * 0.1,
			Window.screenBounds.height * 0.1,
			Window.screenBounds.width * 0.8,
			Window.screenBounds.height * 0.8
		);
	)
	.acceptsMouseOver_(true);
	self[\mainView] = UserView();
	self[\overlay] = UserView()
	.background_(Color(0, 0, 0, 0.5))
	.visible_(false);
	// GMDef Selector
	self[\gmDefSelector] = ~gmDef.getGMDefSelector;
	self[\gmDefSelector].assignFunction({ |synthData|
		self.addSynth(synthData);
		self[\gmDefSelectorView].visible_(false);
	});
	self[\gmDefSelectorView] = UserView();
	self[\gmDefSelectorLabel] = GMTextView()
	.string_("Please select a synth:")
	.maxHeight_(64);
	self[\gmDefSelectorCloseButton] = GMCloseButton()
	.maxHeight_(64)
	.action_({ self[\gmDefSelectorView].visible_(false); });
	self[\gmDefSelectorView] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(
			HLayout()
			.margins_(0)
			.spacing_(0)
			.add(self[\gmDefSelectorLabel], 9)
			.add(self[\gmDefSelectorCloseButton], 1),
			1
		)
		.add(self[\gmDefSelector][\view], 9)
	);
	self[\gmDefSelectorView].visible_(false);
	self[\overlayLayout] = StackLayout().mode_(\stackAll);
	self[\overlayLayout].add(self[\gmDefSelectorView]);
	self[\overlayLayout].add(self[\overlay]);
	self[\overlayLayout].add(self[\mainView]);
	// StackLayout
	self[\layout] = StackLayout();
	// Section selector
	self[\sectionMenu] = UserView()
	.maxHeight_(128);
	self[\sectionSelector] = GMMultiButton()
	.states_(["Player"])
	.action_({ |index|
		if(index == 0) {
			self[\synthMenu].visible_(false);
			self[\layout].index_(0);
			self[\currentSection] = nil;
		} {
			self.selectSection(index - 1);
		};
	});
	self[\addSectionButton] = GMButton()
	.maxWidth_(128)
	.svg_(~gmDef.getIcon(\add))
	.action_({
		self.doTextInput(
			"Please select a section name:",
			"Section",
			{ |name| self.addSection(name); }
		);
	});
	self[\sectionMenu].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\sectionSelector], 9)
		.add(self[\addSectionButton], 1)
	);
	// Synth selector
	self[\synthMenu] = UserView()
	.maxWidth_(96);
	self[\synthSelector] = GMMultiButton()
	.fontRatio_(0.4)
	.orientation_(\vertical)
	.direction_(\top)
	.states_([""])
	.action_({ |index|
		if(self[\currentSection].notNil) {
			if(self[\currentSection][\synths].size > 0) {
				self[\synthView]
				.setSynth(self[\currentSection][\synths][index]);
				self[\currentSection][\currentSynth]
				= self[\currentSection][\synths][index];
			};
		};
	});
	self[\addSynthButton] = GMButton()
	.maxHeight_(128)
	.svg_(~gmDef.getIcon(\add))
	.action_({ self[\gmDefSelectorView].visible_(true); });
	self[\synthMenu].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\addSynthButton], 1)
		.add(self[\synthSelector], 9)
	);
	self[\synthMenu].visible_(false);
	// Player / SynthView
	self[\playerView] = ~gmDef.getPlayerView;
	self[\synthView] = ~gmDef.getSynthView;
	// Layout
	self[\window].layout_(self[\overlayLayout]);
	self[\mainView].layout_(
		VLayout()
		.margins_(4)
		.spacing_(4)
		.add(self[\sectionMenu], 1)
		.add(
			HLayout()
			.margins_(0)
			.spacing_(4)
			.add(self[\synthMenu], 1)
			.add(self[\layout], 9),
			9
		)
	);
	self[\layout].add(self[\playerView][\view]);
	self[\layout].add(self[\synthView][\view]);
	self[\window].onClose_({ self.doRemove; });
	self
},
)