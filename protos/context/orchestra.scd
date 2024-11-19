(
//    PLAYER RELATED    //
setPlayer: { |self, player|
	if(self[\player].isNil) {
		self[\player] = player;
		self[\playerView].setPlayer(player);
		self[\synthView].setPlayer(player);
		self[\sticky].setPlayer(player);
		self[\sections].do({ |section|
			section[\synth].do({ |synth| synth.setPlayer(player); });
		});
	} {
		"ModHa: Orchestra: player reassignment unsupported".warn;
	};
},

selectPlayer: { |self|
	if(self[\blockSectionChange].not) {
		if(self[\playerHasFocus].not) {
			self[\synthMenu].visible_(false);
			self[\layout].index_(0);
			self[\sectionSelector].state_(0);
			self[\currentSection] = nil;
			self[\currentSynth] = nil;
			self[\playerHasFocus] = true;
		};
	};
},

//    SECTION RELATED    //
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
	self[\playerHasFocus] = false;
	self[\currentSection] = self[\sections][index];
	if(self[\currentSection][\currentSynth].notNil) {
		self[\currentSynth] = self[\currentSection][\currentSynth];
		self[\synthView].setSynth(self[\currentSection][\currentSynth]);
	} {
		self[\currentSynth] = nil;
		self[\synthView].disconnectSynth;
	};
	self[\sectionSelector].state_(index + 1);
	self.updateSynthSelector;
	self[\synthMenu].visible_(true);
	self[\layout].index_(1);
},

selectNextSection: { |self|
	if(self[\blockSectionChange].not) {
		if(self[\playerHasFocus]) {
			if(self[\sections].size > 0)
			{ self.selectSection(0); };
		} {
			if(self[\sections].size > 0) {
				var index = self[\sections].indexOf(self[\currentSection]);
				index.postln;
				if(index == (self[\sections].size - 1))
				{ index = 0; }
				{ index = index + 1 };
				self.selectSection(index);
			};
		};
	};
},

askNewSection: { |self|
	self[\blockSectionChange] = true;
	self.doTextInput(
		"Please select a section name:",
		"Section",
		{ |name| self.addSection(name); }
	);
	self[\escFunc] = {
		self[\overlay].visible_(false);
		self[\textInputview].removeAll;
		self[\textInputview].remove;
		self[\textInputview] = nil;
		self[\blockSectionChange] = false;
		self[\escFunc] = self[\defaultEscFunc];
	};
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

//    SYNTH RELATED    //
addSynth: { |self, synthData|
	var synth = ~gmDef.getSynth(synthData[\name].asSymbol);
	self.getUniqueName(synth);
	if(self[\player].notNil)
	{ synth.setPlayer(self[\player]); };
	self[\synthView].connectSynth(synth);
	self[\currentSection][\synths].add(synth);
	self[\synthRMfuncs][synth[\id]] = { self.removeSynth(synth); };
	synth.addSignal(\remove, self[\synthRMfuncs][synth[\id]]);
	// Set synth as current selection
	self[\currentSection][\currentSynth] = synth;
	self[\currentSynth] = synth;
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
				if(section[\currentSynth].notNil) {
					self[\currentSynth] = section[\currentSynth];
					self[\synthView].setSynth(section[\currentSynth]);
				} {
					self[\currentSynth] = nil;
					self[\synthView].disconnectSynth;
				};
				self.updateSynthSelector;
			};
		};
	});
	// Remove stored signal function
	self[\synthRMfuncs].removeAt(synth[\id]);
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
		self[\sections].do({ |section|
			if(nameCollision.not) {
				section[\synths].do({ |synth|
					if(nameCollision.not) {
						if(synth[\name] == currentName)
						{ nameCollision = true; };
					};
				});
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

askNewSynth: { |self|
	self[\gmDefSelectorView].visible_(true);
	self[\blockSectionChange] = true;
	self[\escFunc] = {
		self[\gmDefSelectorView].visible_(false);
		self[\blockSectionChange] = false;
		self[\escFunc] = self[\defaultEscFunc];
	};
},

//    MISC    //
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
		self[\textInputview] = nil;
		self[\blockSectionChange] = false;
		self[\escFunc] = self[\defaultEscFunc];
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
		self[\textInputview] = nil;
		self[\blockSectionChange] = false;
		self[\escFunc] = self[\defaultEscFunc];
	})
	// Force focus when displayed:
	.focusLostAction_({
		textInput.focus(true);
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
		self[\textInputview] = nil;
		self[\blockSectionChange] = false;
		self[\retFunc] = self[\defaultRetFunc];
		self[\escFunc] = self[\defaultEscFunc];
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
	self[\textInputview] = view;
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
	self[\currentSynth] = nil;
	self[\synthRMfuncs] = ();
	self[\playerHasFocus] = true;
	self[\textInputView] = nil;
	// Prevents user from changing UI
	// with keyboard when he shouldn't
	self[\blockSectionChange] = false;
	self[\defaultRetFunc] = {
		if(self[\player].notNil) {
			self[\player].toggle;
		};
	};
	self[\retFunc] = self[\defaultRetFunc];
	self[\defaultEscFunc] = {};
	self[\escFunc] = self[\defaultEscFunc];
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
		self[\blockSectionChange] = false;
		self[\escFunc] = self[\defaultEscFunc];
	});
	self[\gmDefSelectorView] = UserView();
	self[\gmDefSelectorLabel] = GMTextView()
	.string_("Please select a synth:")
	.maxHeight_(64);
	self[\gmDefSelectorCloseButton] = GMCloseButton()
	.maxHeight_(64)
	.action_({
		self[\gmDefSelectorView].visible_(false);
		self[\blockSectionChange] = false;
		self[\escFunc] = self[\defaultEscFunc];
	});
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
		if(index == 0)
		{ self.selectPlayer; }
		{ self.selectSection(index - 1); };
	});
	self[\addSectionButton] = GMButton()
	.maxWidth_(128)
	.svg_(~gmDef.getIcon(\add))
	.action_({ self.askNewSection; });
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
				self[\currentSynth] = self[\currentSection][\currentSynth];
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
	// Sticky
	self[\sticky] = ~gmDef.getSticky;
	self[\stickyVisible] = false;
	self[\sticky][\view].visible_(self[\stickyVisible]);
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
		.add(self[\sticky][\view], 1)
	);
	self[\layout].add(self[\playerView][\view]);
	self[\layout].add(self[\synthView][\view]);
	// Keybord commands
	self[\window].view.keyDownAction_({ |view, char, mod, unicode, keycode, key|
		// Note: TAB command is consumed by children,
		// so unusable for now (needs heavy algorithm).
		//mod.postln;
		//unicode.postln;
		switch(unicode)
		{ 109 } { // m: mute/unmute current synth
			if(self[\currentSynth].notNil) {
				if(self[\currentSynth].hasAmpParam) {
					self[\currentSynth].setMuted(
						self[\currentSynth][\muted].not
					);
				};
			};
		}
		{ 112 } { // p: focus player
			self.selectPlayer;
		}
		{ 113 } { // q: show/hide sticky
			self[\stickyVisible] = self[\stickyVisible].not;
			self[\sticky][\view].visible_(self[\stickyVisible]);
		}
		{ 9 } { // CTRL + TAB: select next section
			self.selectNextSection;
		}
		{ 43 } { // +
			if(mod == 2097152) {
				// +: add synths to current section
				// or add section if not section
				if(self[\sections].size == 0) {
					self.askNewSection;
				} {
					if(self[\currentSection].notNil)
					{ self.askNewSynth; };
				};
			};
			if(mod == 2359296) { // CTRL + '+': add new section
				self.askNewSection;
			};
		}
		{ 127 } { // SUPPR: remove current synth
			if(self[\currentSynth].notNil)
			{ self[\currentSynth].doRemove; };
		}
		{ 17 } { // CTRL + q: quit
			self[\window].close;
		}
		{ 13 } { // RET: depends on context, defaut toggle player's routine
			self[\retFunc].value;
		}
		{ 27 } { // ESC: depends on context, default does nothing
			self[\escFunc].value;
		};
	});
	// Misc
	self[\window].onClose_({ self.doRemove; });
	self
},
)