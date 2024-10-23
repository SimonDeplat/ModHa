(
setPlayer: { |self, player|
	if(self[\player].isNil) {
		// Player View creation
		var playerView = ~gmDef.getPlayerView;
		playerView.setPlayer(player);
		playerView.setStyles(
			~gmDef[\style],
			~gmDef[\textStyle],
			~gmDef[\widgetStyle]
		);
		self[\mainLayout].insert(playerView[\view], 0);
		self[\topMenuActions].insert(0, { self[\mainLayout].index_(0); });
		self[\topMenuStates].insert(0, "Player");
		self[\topMenu].states_(self[\topMenuStates]);
		playerView.setWindow(self);
		// Misc
		self[\player] = player;
		self[\synthViews].do({ |view| view.setPlayer(player); });
		self.focusPlayer;
	} {
		"ModHa: MainWindow: Player reassignment not supported".warn;
	};
},

// /!\ Work In progress
setAsMonoGrid: { |self, grid|
	var synthView = ~gmDef.getSynthView;
	var synthLists = List(0);
	var synthNames = List(0);
	var synthIndices = List(0);
	var currentRack = 0;
	var leftMenu = GMMultiButton()
	.fontRatio_(0.1)
	.maxWidth_(64)
	.orientation_(\vertical)
	.direction_(\top)
	.action_({ |index|
		synthIndices[currentRack] = index;
		synthView.setSynth(synthLists[currentRack][index]);
	});
	var sticky = ~gmDef.getSticky;
	if(self[\player].notNil) {
		synthView.setPlayer(self[\player]);
		sticky.setPlayer(self[\player]);
	};
	synthView.setWindow(self);
	grid.do({ |row, rowIndex|
		self[\topMenuStates].add(row[0]);
		self[\topMenuActions].add({
			currentRack = rowIndex;
			synthView.setSynth(
				synthLists[currentRack]
				[synthIndices[currentRack]]
			);
			leftMenu.states_(synthNames[currentRack]);
			leftMenu.state_(synthIndices[currentRack]);
			self[\mainLayout].index_(1);
		});
		synthLists.add(List(0));
		synthNames.add(List(0));
		synthIndices.add(0);
		(row.size - 1).do({ |index|
			var synth = ~gmDef.getSynth(row[index + 1]);
			// This feels odd, should they be referenced ?
			if(self[\player].notNil)
			{ synth.setPlayer(self[\player]); };
			synthView.connectSynth(synth);
			synthLists[rowIndex].add(synth);
			synthNames[rowIndex].add(synth[\name]);
		});
	});
	self[\topMenu].states_(self[\topMenuStates]);
	self[\mainLayout].add(
		UserView()
		.layout_(
			VLayout()
			.margins_(0)
			.spacing_(0)
			.add(
				UserView().layout_(
					HLayout()
					.margins_(0)
					.spacing_(0)
					.add(leftMenu, 1)
					.add(synthView[\view], 9)
				),
				9
			)
			.add(sticky[\view], 1)
		)
	);
},

focusPlayer: { |self|
	if(self[\player].notNil) {
		self[\mainLayout].index_(0);
		self[\topMenu].state_(0);
	};
},

callLoader: { |self, rule, symbol, action, msg = ""|
		var files, states;
		self[\loaderTitle].string_(msg);
		files = ~gmDef.getFilesFor(rule, symbol);
		states = files.collect({ |i| i[0] });
		self[\loaderSelector]
		.states_(states)
		.action_({ |index|
			action.value(files[index][1], files[index][0]);
			self[\loader].visible_(false);
			files.clear;
		})
		.desindex;
		self[\loader].visible_(true);
},

callTextInput: { |self, action, msg = "", buttonMsg = ""|
	self[\textTitle].string_(msg);
	self[\textField]
	.string_("")
	.focus(true);
	self[\textInputButton]
	.string_(buttonMsg)
	.action_({
		action.value(self[\textField].string);
		self[\textInput].visible_(false);
	});
	self[\textInput].visible_(true);
},

doFront: { |self| self[\window].front; },
doClose: { |self| self[\window].close; },

init: { |self|
	// Window / Layouts / Main View
	self[\window] = Window("ModHa",
		Rect(
			Window.screenBounds.width * 0.1,
			Window.screenBounds.height * 0.1,
			Window.screenBounds.width * 0.8,
			Window.screenBounds.height * 0.8
		);
	)
	.acceptsMouseOver_(true);
	self[\overlayLayout] = StackLayout()
	.mode_(\stackAll);
	self[\mainView] = UserView()
	.acceptsMouseOver_(true);
	self[\mainLayout] = StackLayout();
	self[\stickyLayout] = VLayout()
	.margins_(0)
	.spacing_(0);
	// Top Menu
	self[\topMenuStates] = List(0);
	self[\topMenu] = GMMultiButton()
	.maxHeight_(96)
	.states_(self[\topMenuStates])
	.action_({ |index| self[\topMenuActions][index].value; });
	self[\topMenuActions] = List(0);
	// Loader
	self[\loader] = UserView()
	.background_(Color(0.5, 0.5, 0.5));
	self[\loaderTitle] = GMTextView()
	.maxHeight_(96)
	.fontRatio_(0.4);
	self[\loaderCloseButton] = GMCloseButton()
	.maxWidth_(96)
	.maxHeight_(96)
	.action_({ self[\loader].visible_(false); });
	self[\loaderSelector] = GMGridButton();
	self[\loader].layout_(
		VLayout()
		.add(
			HLayout()
			.add(self[\loaderTitle], 9)
			.add(self[\loaderCloseButton], 1),
			1
		)
		.add(self[\loaderSelector], 9)
	);
	self[\loader].visible_(false);
	// Text Input
	self[\textInput] = UserView()
	.background_(Color(0.5, 0.5, 0.5));
	self[\textTitle] = GMTextView()
	.maxHeight_(96)
	.fontRatio_(0.4);
	self[\textCloseButton] = GMCloseButton()
	.maxWidth_(96)
	.maxHeight_(96)
	.action_({ self[\textInput].visible_(false); });
	self[\textField] = TextField()
	.align_(\center);
	self[\textInputButton] = GMButton()
	.string_("")
	.maxWidth_(192)
	.maxHeight_(96);
	self[\textInput].layout_(
		VLayout()
		.add(
			HLayout()
			.add(self[\textTitle], 9)
			.add(self[\textCloseButton], 1),
			1
		)
		.add(
			VLayout()
			.add(self[\textField])
			.add(
				HLayout()
				.add(self[\textInputButton])
			),
			9
		)
	);
	self[\textInput].visible_(false);
	// Layout construction
	self[\mainView].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\topMenu], 1)
		.add(self[\mainLayout], 9)
	);
	self[\overlayLayout]
	.add(self[\loader])
	.add(self[\textInput])
	.add(self[\mainView]);
	self[\window].layout_(self[\overlayLayout]);
	// Placeholders
	self[\player] = nil;
	self[\synthViews] = List(0);
};
)