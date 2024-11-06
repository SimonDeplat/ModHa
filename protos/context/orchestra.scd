(
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
	self[\sectionSelector].state_(index + 1);
	self[\synthMenu].visible_(true);
	self[\layout].index_(1);
},

addSynth: { |self, synthData|
	synthData.postln;
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
	self[\sections].clear;
	self[\playerView].doRemove;
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
	.states_([""]);
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