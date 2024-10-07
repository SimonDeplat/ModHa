({ |decoder, properties = nil|
	var outLayout = HLayout()
	.margins_(0)
	.spacing_(0);

	var self = (
		// We'll have a curtain hiding
		// everything while views are rearranged
		view: UserView()
		.acceptsMouseOver_(true)
		.layout_(StackLayout())
		.onClose_({ self.doRemove; }),
		mainView: UserView()
		.acceptsMouseOver_(true),
		curtainView: UserView(),
		menu: UserView()
		.layout_(
			HLayout()
			.margins_(0)
			.spacing_(4)
		)
		.maxHeight_(64),
		title: GMTextView()
		.maxHeight_(64),

		inputView: ~gmDef.getInputView,
		outView: ~gmDef.getOutView,

		zoomLayout: StackLayout(),
		zoomView: UserView(),
		normalView: UserView()
		.acceptsMouseOver_(true),

		hiddenViewsCount: 0,
		hiddenViewsMenu: UserView()
		.layout_(
			HLayout()
			.margins_(0)
			.spacing_(0)
		)
		.maxHeight_(48)
		.visible_(false),

		pianoRollContainer: UserView()
		.layout_(
			HLayout()
			.margins_(0)
			.spacing_(0)
		)
		.visible_(false),
		paramManager: decoder.getParamManager,
		sequencerContainer: UserView()
		.layout_(
			HLayout()
			.margins_(0)
			.spacing_(0)
		)
		.visible_(false),
		beatSelectorContainer: UserView().layout_(
			HLayout()
			.margins_(0)
			.spacing_(0)
		)
		.maxHeight_(64)
		.visible_(false),

		connectedSynths: List(0),
		uiStates: List(0),
		currentBeat: 0,
		displayedBeat: -1,
	);

	self.parent_(decoder[\synthViewParent]);

	self[\paramManager][\synthView] = self;

	// Save / Load UI
	self.createSaveMenu;

	// OUT
	self[\outButton] = GMButton()
	.maxWidth_(64)
	.svg_(~gmDef.getIcon(\out))
	.action_({ self.displayOutView; });
	self[\outLabel] = GMButton()
	.stringRatio_(0.4)
	.maxWidth_(128)
	.action_({ self.displayOutView; });
	outLayout
	.add(self[\outButton], 1)
	.add(self[\outLabel], 2);
	self.addMenuItem(outLayout, 3);
	self[\outView][\synthView] = self;
	self[\outUIFunction] = {
		var out = self[\synth][\outNode];
		if(out.isNil)
		{ self[\outLabel].string_("Direct Out"); }
		{ self[\outLabel].string_(out[\name]); };
	};

	// Mute button
	self[\muteButton] = GMButton()
	.maxWidth_(64)
	.svg_(~gmDef.getIcon(\audible))
	.action_({
		if(self[\synth].notNil) {
			self[\synth].setMuted(self[\synth][\muted].not);
		};
	});
	self.addMenuItem(self[\muteButton]);
	self[\uiMuteFunction] = {
		if(self[\synth][\muted])
		{ self[\muteButton].svg_(~gmDef.getIcon(\muted)) }
		{ self[\muteButton].svg_(~gmDef.getIcon(\audible)) };
	};

	// Play button
	self[\playButton] = GMFeedbackButton()
	.maxWidth_(64)
	.svg_(~gmDef.getIcon(\note))
	.action_({ self.playSynth; });
	self.addMenuItem(self[\playButton]);

	self[\normalView].layout_(
		HLayout()
		.margins_(0)
		.spacing_(4)

		.add(self[\inputView][\view], 1)
		.add(self[\pianoRollContainer], 3)
		.add(
			VLayout()
			.margins_(0)
			.spacing_(4)
			.add(self[\paramManager][\view], 5)
			.add(self[\sequencerContainer], 1)
			.add(self[\beatSelectorContainer], 1),
			7
		)
	);

	self[\zoomLayout].add(self[\normalView]);
	self[\zoomLayout].add(self[\zoomView]);

	self[\mainView].layout_(
		VLayout()
		.margins_(4)
		.spacing_(4)
		.add(
			HLayout()
			.margins_(0)
			.spacing_(0)
			.add(self[\title], 1)
			.add(self[\menu], 2),
			1
		)
		.add(self[\zoomLayout], 8)
		.add(self[\hiddenViewsMenu], 1)
	);

	self[\view].layout.add(self[\mainView]);
	self[\view].layout.add(self[\curtainView]);
	self[\view].layout.add(self[\outView][\view]);

	self
})