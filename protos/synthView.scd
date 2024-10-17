(
showWidgets: List(0),

hideView: { |self, view, label|
	var style = GMStyle();
	var widget;
	if(self[\smallStyle].notNil)
	{ style = self[\smallStyle]; };
	widget = UserView()
	.maxWidth_(64 * 3)
	.layout_(
		HLayout()
		.spacing_(0)
		.margins_(0)
		.add(
			GMTextView()
			.fontRatio_(0.4)
			.displayFrame_(true)
			.string_(label)
			.style_(style),
			2
		)
		.add(
			GMButton()
			.svg_(~gmDef.getIcon(\arrowTop))
			.style_(style)
			.action_({
				self[\showWidgets].remove(widget);
				view.unhide;
				widget.removeAll;
				widget.remove;
				self.showView;
			}),
			1
		)
	);

	self[\showWidgets].add(widget);
	self[\hiddenViewsMenu].layout.add(widget);

	self[\hiddenViewsCount] = self[\hiddenViewsCount] + 1;
	if(self[\hiddenViewsCount] == 1)
	{ self[\hiddenViewsMenu].visible_(true); };
},

resetShowWidgets: { |self|
	self[\showWidgets].do({ |widget|
		widget.removeAll;
		widget.remove;
	});
	self[\hiddenViewsCount] = 0;
	self[\hiddenViewsMenu].visible_(false);
},

showView: { |self|
	self[\hiddenViewsCount] = self[\hiddenViewsCount] - 1;
	if(self[\hiddenViewsCount] == 0)
	{ self[\hiddenViewsMenu].visible_(false); };
},

addMenuItem: { |self, item, stretch = 1|
	self[\menu].layout.insert(item, 0, stretch);
},

// This is triggered when displayed beat
// happens to be larger than actual score size
// Needs a rework (see paramManager & env/selector)
notifyOutOfBounds: { |self|
	if(self[\uiStates][self[\synthIndex]][\displayedBeat] == -1) {
		self[\uiStates][self[\synthIndex]]
		[\displayedBeat] = -1;
		self[\beatSelector][\view].desindex;
	};
},

setPlayer: { |self, player|
	self[\player] = player;
	player[\synthViews].add(self);
	self[\paramManager].setPlayer(player);
	if(self[\pianoRoll].notNil)
	{ self[\pianoRoll][\player] = player; };
	player.addSignal(
		\highlights,
		{ self.setHighlights(player[\highlights]); }
	);
	self.setHighlights(player[\highlights]);
	player.addSignal(
		\vHighlights,
		{ self.setVHighlights(player[\vHighlights]); }
	);
	self.setVHighlights(player[\vHighlights]);
	player.addSignal(
		\beat,
		{ self.setBeat(player[\actualBeat]); }
	);
	self.setBeat(player[\actualBeat]);
},

setWindow: { |self, window|
	self[\window] = window;
},

setBeat: { |self, beat|
	self[\currentBeat] = beat;
	if(self[\synth].notNil
		and: { self[\synth][\type] == \discrete })
	{ self[\synthBeat] = beat%self[\synth][\nBeats]; }
	{ self[\synthBeat] = beat; };

	self[\paramManager].setBeat(self[\synthBeat]);

	if(self[\sequencer].notNil)
	{ self[\sequencer].setBeat(self[\synthBeat]); };
	if(self[\pianoRoll].notNil)
	{ self[\pianoRoll].setBeat(self[\synthBeat]); };
},

setHighlights: { |self, highlights|
	self[\paramManager].setHighlights(highlights);
	if(self[\sequencer].notNil)
	{ self[\sequencer].setHighlights(highlights); };
	if(self[\pianoRoll].notNil)
	{ self[\pianoRoll].setHighlights(highlights); };
	if(self[\beatSelector].notNil)
	{ self[\beatSelector].setBeat(
		self[\beatSelector][\view].states.size); };
},

setVHighlights: { |self, vHighlights|
	if(self[\pianoRoll].notNil)
	{ self[\pianoRoll].setVHighlights(vHighlights); };
},

// Allows envViews to store retrieve their time scale
// (i.e. their zoom level)
setTimeScale: { |self, symbol, timeScale|
	if(self[\uiStates][self[\synthIndex]][\timeScale].isNil)
	{ self[\uiStates][self[\synthIndex]][\timeScale] = (); };
	self[\uiStates][self[\synthIndex]]
	[\timeScale][symbol] = timeScale;
},

getTimeScale: { |self, symbol|
	self[\uiStates][self[\synthIndex]][\timeScale][symbol]
},

displayBeat: { |self, beat|
	self[\displayedBeat] = beat;
	self[\paramManager].displayBeat(beat);
},

setStyles: { |self, style, smallStyle|
	var backgroundColor = Color(
		style.backColor.red * 0.75,
		style.backColor.green * 0.75,
		style.backColor.blue * 0.75
	);

	self[\style] = style;
	self[\smallStyle] = smallStyle;
	self[\paramManager].setStyles(style, smallStyle);
	if(self[\sequencer].notNil)
	{ self[\sequencer].setStyles(style, smallStyle); };
	if(self[\pianoRoll].notNil)
	{ self[\pianoRoll].setStyles(style, smallStyle); };
	if(self[\beatContainer].notNil)
	{ self[\beatContainer].style_(style); };

	self[\muteButton].style_(smallStyle);
	self[\saveButton].style_(smallStyle);
	self[\saveAsButton].style_(smallStyle);
	self[\loadButton].style_(smallStyle);
	self[\playButton].style_(smallStyle);
	self[\outButton].style_(smallStyle);
	self[\outLabel].style_(smallStyle);

	self[\mainView].background_(backgroundColor);
	self[\curtainView].background_(backgroundColor);
	self[\outView][\view].background_(backgroundColor);
},

addBeatSelector: { |self|
	self[\beatSelector] = (
		view: GMMultiButton()
		.allowRetrigger_(true)
		.action_({ |index|
			if(index ==
				self[\uiStates][self[\synthIndex]][\displayedBeat]) {
				self[\uiStates]
				[self[\synthIndex]][\displayedBeat]
				= -1;
				self[\beatSelector][\view].desindex;
			} {
				self[\uiStates]
				[self[\synthIndex]][\displayedBeat]
				= index;
			};
			self.displayBeat(
				self[\uiStates]
				[self[\synthIndex]][\displayedBeat]
			);
		}),
		uiFunc: {
			var currentState =
			self[\beatSelector][\view].state;
			// This will reset selector's state
			self[\beatSelector]
			.setNBeat(self[\synth][\track].size);
			// so set it back
			if(currentState.isNil) {
				self[\beatSelector]
				[\view].desindex;
			} {
				self[\beatSelector]
				[\view].state_(currentState);
			};
		},
		synth: nil,
		disconnect: { |selector|
			if(selector[\synth].notNil) {
				selector[\synth].rmUINotification(
					\nBeats,
					selector[\uiFunc]
				);
				selector[\synth] = nil;
			};
		},
		connect: { |selector, synth|
			selector.disconnect;
			selector[\synth] = synth;
			synth.addSignal(
				\nBeats,
				selector[\uiFunc]
			);
			selector[\uiFunc].value;
		},
		setNBeat: { |selector, beat|
			if(self[\player].notNil) {
				selector[\view].states_(
					Array.fill(beat, { |i|
						(
							string: "",
							color: Color(
								1, 1, 1,
								self[\player]
								[\highlights][i%beat]
							),
							fontColor: Color.black,
						)
					});
				);
			} {
				selector[\view].states_(
					Array.fill(beat, { "" });
				);
			};
		},
	);

	if(self[\player].notNil)
	{ self[\beatSelector].setNBeat(self[\player][\nBeats]); };
	if(self[\style].notNil)
	{ self[\beatSelector][\view].style_(self[\style]); };

	self[\beatSelectorContainer]
	.layout.add(self[\beatSelector][\view]);
},

playSynth: { |self|
	if(self[\synth].notNil
		and: { self[\synth][\type] == \discrete }) {
		self[\synth].playAt(
			max(
				0,
				self[\displayedBeat]
			);
		);
	};
},

createSaveMenu: { |self|
	self[\saveView] = UserView()
	.maxWidth_(64 * 3)
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
	);

	self[\saveButton] = GMFeedbackButton()
	.maxWidth_(64)
	.svg_(~gmDef.getIcon(\save))
	.action_({
		if(
			self[\uiStates][self[\synthIndex]]
			[\file].notNil
		) {
			self.save;
		} {
			if(self[\window].notNil) {
				self[\window].callTextInput(
					{ |dataName| self.saveAs(dataName) },
					"Select a name :",
					"Ok"
				);
			};
		};
	});
	self[\saveAsButton] = GMButton()
	.maxWidth_(64)
	.svg_(~gmDef.getIcon(\saveAs))
	.action_({
		if(self[\window].notNil) {
			self[\window].callTextInput(
				{ |dataName| self.saveAs(dataName) },
				"Select a name :",
				"Ok"
			);
		};
	});
	self[\loadButton] = GMButton()
	.maxWidth_(64)
	.svg_(~gmDef.getIcon(\load))
	.action_({
		if(self[\window].notNil) {
			self[\window].callLoader(
				\synth,
				self[\synth][\name],
				{ |file, dataName| self.load(file, dataName); },
				"Select a preset to load :"
			);
		};
	});

	self[\saveView].layout.add(self[\saveButton], 1);
	self[\saveView].layout.add(self[\saveAsButton], 1);
	self[\saveView].layout.add(self[\loadButton], 1);
	self.addMenuItem(self[\saveView], 3);
},

// /!\ FIX ME: SAVE & LOAD SHOULD BE IN SYNTH
save: { |self|
	var file = File(
		self[\uiStates][self[\synthIndex]]
		[\file].standardizePath, "w");

	var data = self[\synth].getSaveData(
		self[\uiStates][self[\synthIndex]]
		[\dataName]
	);

	file.write(data.asCompileString);
	file.close;
	data.clear;
},

saveAs: { |self, dataName|
	self[\uiStates][self[\synthIndex]]
	[\file] =
	~gmDef[\userFolder]
	++ "presets/synths/"
	++ self[\synth][\name]
	++ "_"
	++ ~gmDef.getUID
	++ ".gmdef_synth";

	self[\uiStates][self[\synthIndex]]
	[\dataName] = dataName;

	self.save;
},

load: { |self, file, dataName|
	var data = this.executeFile(file);

	self[\synth].loadData(data);

	self[\uiStates][self[\synthIndex]]
	[\file] = file;

	self[\uiStates][self[\synthIndex]]
	[\dataName] = dataName;

	data.clear;
},

setZoomState: { |self, view|
	self[\uiStates][self[\synthIndex]][\zoom] = view;
},

// This is used to remember synths params
// (see paramManager)
setParamRule: { |self, synth, rule|
	self[\uiStates][self[\connectedSynths].indexOf(synth)][\paramRule]
	= rule;
},
getParamRule: { |self, synth|
	self[\uiStates][self[\connectedSynths].indexOf(synth)][\paramRule]
},

resetCurrentSynth: { |self|
	// Dezoom current view
	if(self[\uiStates][self[\synthIndex]][\zoom].notNil) {
		var view = self[\uiStates][self[\synthIndex]][\zoom];
		view.dezoom;
		// Dezooming purges zoomState, reassign it manually
		self.setZoomState(view);
	};

	// Store hidden views
	self[\uiStates][self[\synthIndex]][\hiddenViews].clear;
	self[\uiStates][self[\synthIndex]][\hiddenViews] =
	self[\paramManager][\hiddenViews].deepCopy;
	self[\paramManager].unhideAll;
	self.resetShowWidgets;

	// Reset UI mute function
	self[\synth].rmUINotification(
		\mute,
		self[\uiMuteFunction]
	);
	self[\synth].rmUINotification(
		\out,
		self[\outUIFunction]
	);
	self[\synth].rmUINotification(
		\input,
		self[\inputView][\updateChannelIndex]
	);
},

displayOutView: { |self|
	self[\outView].updateOuts;
	self[\view].layout.index_(2);
},

hideRythmUI: { |self|
	if(self[\sequencer].notNil) {
		self[\sequencer].disconnect;
		self[\sequencerContainer].visible_(false); };

	if(self[\pianoRoll].notNil) {
		self[\pianoRoll].disconnect;
		self[\pianoRollContainer].visible_(false); };

	if(self[\beatSelector].notNil) {
		self[\beatSelector].disconnect;
		self[\beatSelectorContainer].visible_(false); };

	self[\playButton].visible_(false);
},

/*
[\uiStates] is a dictionary that holds
persistent datas about synths,
so they can be set in the correct state
when selected :
- [\displayedBeat] : currently displayed beat
- [\zoom] : zoom status
- [\file] : current file
- [\dataName] : current file data name
- [\hiddenViews] : current hidden views
*/

connectSynth: { |self, synth|
	var synthIndex = self[\connectedSynths].size;
	self[\uiStates].add(());
	self[\connectedSynths].add(synth);

	// We're passing the player in case highlights needs to be set
	// to new views
	self[\paramManager].adaptToSynth(synth, self[\player]);

	switch(synth[\type])

	// Discrete setup
	{ \discrete } {
		self[\uiStates][synthIndex][\displayedBeat] = -1;
		self[\uiStates][synthIndex][\zoom] = nil;
		self[\uiStates][synthIndex][\file] = nil;
		self[\uiStates][synthIndex][\dataName] = nil;
		self[\uiStates][synthIndex][\hiddenViews] = List(0);

		// Sequencer setup
		if(self[\sequencer].isNil) {
			self[\sequencer] = ~gmDef.getSequencerView;
			self[\sequencerContainer].layout.add(
				self[\sequencer][\view]; );
			if(self[\player].notNil) {
				self[\sequencer].setHighlights(
					self[\player][\highlights]); };
			if(self[\style].notNil)
			{ self[\sequencer].setStyle(self[\style]); };
		};

		// Piano Roll setup
		if(synth[\tunable] and: { self[\pianoRoll].isNil }) {
			self[\pianoRoll] = ~gmDef.getPianoRollView;
			self[\pianoRollContainer].layout.add(
				self[\pianoRoll][\view]; );
			if(self[\player].notNil) {
				self[\pianoRoll].setHighlights(
					self[\player][\highlights]);
				self[\pianoRoll].setVHighlights(
					self[\player][\vHighlights]);
			};
			if(self[\style].notNil)
			{ self[\pianoRoll].setStyle(self[\style]); };
		};

		// Beat Selector setup
		if(self[\beatSelector].isNil)
		{ self.addBeatSelector; };

		// TimeScales management;
		synth[\data][\params].do({ |param|
			if(param[\type] == \env) {
				if(self[\uiStates][synthIndex]
					[\timeScale].isNil)
				{ self[\uiStates][synthIndex]
					[\timeScale] = (); };

				if(param.includesKey(\timeScale)) {
					self[\uiStates][synthIndex]
					[\timeScale][param[\symbol]]
					= param[\timeScale];
				} {
					self[\uiStates][synthIndex]
					[\timeScale][param[\symbol]] = 1;
				};
			};
		});
	}

	{ \continuous } {
		self[\uiStates][synthIndex][\zoom] = nil;
		self[\uiStates][synthIndex][\file] = nil;
		self[\uiStates][synthIndex][\dataName] = nil;
		self[\uiStates][synthIndex][\hiddenViews] = List(0);
	}

	{ \effect } {
		self[\uiStates][synthIndex][\zoom] = nil;
		self[\uiStates][synthIndex][\file] = nil;
		self[\uiStates][synthIndex][\dataName] = nil;
		self[\uiStates][synthIndex][\hiddenViews] = List(0);
	}

	{ \input } {
		// Should we disable hide view on inputs ?
		// Should it be a GMDef param setting ?
		self[\uiStates][synthIndex][\hiddenViews] = List(0);
	};
},

setSynth: { |self, synth|
	// Draw the curtain
	self[\view].layout.index_(1);

	// Connect synth if needed
	if(self[\connectedSynths].includes(synth).not)
	{ self.connectSynth(synth); };

	// Reset current synth state
	if(self[\synth].notNil)
	{ self.resetCurrentSynth; };

	self[\synth] = synth;
	// Assign an index to the synth so it can be
	// uniquely identified and used to
	// retrieve datas in lists (mainly current UI state)
	self[\synthIndex]
	= self[\connectedSynths].indexOfEqual(synth);
	self[\title].string_(synth[\name]);

	// Pass hidden views to the manager
	self[\paramManager][\hiddenViews].clear;
	self[\paramManager][\hiddenViews] =
	self[\uiStates][self[\synthIndex]][\hiddenViews].deepCopy;
	self[\paramManager].setSynth(synth);

	// Specialization
	switch(synth[\type])

	{ \discrete } {

		// Sequencer setup
		self[\sequencer].setSynth(synth);
		self[\sequencerContainer].visible_(true);

		// Piano Roll setup
		if(synth[\tunable]) {
			self[\pianoRoll].setSynth(synth);
			self[\pianoRollContainer].visible_(true);
		} {
			if(self[\pianoRoll].notNil) {
				self[\pianoRoll].disconnect;
				self[\pianoRollContainer].visible_(false);
			};
		};

		// Beat Selector setup
		self[\beatSelector].connect(synth);
		if(self[\uiStates][self[\synthIndex]][\displayedBeat] == -1)
		{ self[\beatSelector][\view].desindex; }
		{ self[\beatSelector][\view].state_(
			self[\uiStates][self[\synthIndex]][\displayedBeat]); };
		self[\beatSelectorContainer].visible_(true);

		// Call setBeat to reset views display
		self.setBeat(self[\currentBeat]);

		// Show buttons
		self[\playButton].visible_(true);
		self[\muteButton].visible_(true);
		self[\inputView][\view].visible_(false);
		// Connect mute function
		self[\synth].addSignal(
			\mute,
			self[\uiMuteFunction]
		);
		self[\uiMuteFunction].value;
		self[\saveView].visible_(true);
	}

	{ \continuous } {
		if(synth[\hasAmpParam]) {
			self[\muteButton].visible_(true);
			// Connect mute function
			self[\synth].addSignal(
				\mute,
				self[\uiMuteFunction]
			);
			self[\uiMuteFunction].value;
		} {
			self[\muteButton].visible_(false);
		};

		// hide unneeded views
		self.hideRythmUI;
		self[\inputView][\view].visible_(false);
		self[\saveView].visible_(true);
	}

	{ \effect } {
		if(synth[\hasAmpParam]) {
			self[\muteButton].visible_(true);
			// Connect mute function
			self[\synth].addSignal(
				\mute,
				self[\uiMuteFunction]
			);
				self[\uiMuteFunction].value;
		} {
			self[\muteButton].visible_(false);
		};
		// hide unneeded views
		self.hideRythmUI;
		self[\inputView][\view].visible_(false);
		self[\saveView].visible_(true);
	}

	{ \input } {
		self[\inputView].setSynth(self[\synth]);
		if(synth[\hasAmpParam]) {
			self[\muteButton].visible_(true);
			// Connect mute function
			self[\synth].addSignal(
				\mute,
				self[\uiMuteFunction]
			);
			self[\uiMuteFunction].value;
		} {
			self[\muteButton].visible_(false);
		};
		// Connect channel update UI
		self[\synth].addSignal(
			\input,
			self[\inputView][\updateChannelIndex]
		);
		self[\inputView][\updateChannelIndex].value;
		self.hideRythmUI;
		self[\inputView][\view].visible_(true);
		self[\saveView].visible_(false);
	};

	// Zoom if a view was previously zoomed
	if(self[\uiStates][self[\synthIndex]][\zoom].notNil)
	{ self[\uiStates][self[\synthIndex]][\zoom].zoom; };

	// Update beat display if needed
	if(self[\uiStates][self[\synthIndex]]
		.includesKey(\displayedBeat)) {
		self[\paramManager].displayBeat(
			self[\uiStates][self[\synthIndex]][\displayedBeat]);
		if(self[\uiStates][self[\synthIndex]][\displayedBeat] == -1)
		{ self[\beatSelector].desindex; }
		{ self[\beatSelector].state_(
			self[\uiStates][self[\synthIndex]][\displayedBeat]); };
		self[\displayedBeat] =
		self[\uiStates][self[\synthIndex]][\displayedBeat];
	};

	// Update out label
	self[\synth].addSignal(
		\out,
		self[\outUIFunction]
	);
	self[\outUIFunction].value;

	// Show view again
	self[\view].layout.index_(0);
},

// Triggered by self[\view].onClose
doRemove: { |self|
	self[\connectedSynths].do({ |synth|
		synth.doRemove; });
	self[\connectedSynth].clear;
	self[\view].removeAll;
},

init: { |self|
	var outLayout = HLayout()
	.margins_(0)
	.spacing_(0);

	// We'll have a curtain hiding
	// everything while views are rearranged
	self[\view] = UserView()
	.acceptsMouseOver_(true)
	.layout_(StackLayout())
	.onClose_({ self.doRemove; });
	self[\mainView] = UserView()
	.acceptsMouseOver_(true);
	self[\curtainView] = UserView();
	self[\menu] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(4)
	)
	.maxHeight_(64);
	self[\title] = GMTextView()
	.maxHeight_(64);

	self[\inputView] = ~gmDef.getInputView;
	self[\outView] = ~gmDef.getOutView;

	self[\zoomLayout] = StackLayout();
	self[\zoomView] = UserView();
	self[\normalView] = UserView()
	.acceptsMouseOver_(true);

	self[\hiddenViewsCount] = 0;
	self[\hiddenViewsMenu] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
	)
	.maxHeight_(48)
	.visible_(false);

	self[\pianoRollContainer] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
	)
	.visible_(false);
	self[\paramManager] = ~gmDef.getParamManager;
	self[\sequencerContainer] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
	)
	.visible_(false);
	self[\beatSelectorContainer] = UserView().layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
	)
	.maxHeight_(64)
	.visible_(false);

	self[\connectedSynths] = List(0);
	self[\uiStates] = List(0);
	self[\currentBeat] = 0;
	self[\displayedBeat] = -1;

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

	self.setStyles(
		~gmDef[\defaultProperties][\style],
		~gmDef[\defaultProperties][\textStyle]
	);
},
)