/*
[\uiStates][synth[\id]
is a dictionary that holds persistent datas about synths,
so they can be set in the correct state when selected :
- [\selectedBeat] : currently displayed beat
- [\zoom] : zoom status
- [\file] : current file
- [\dataName] : current file data name
- [\hiddenViews] : current hidden views
*/

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

setPlayer: { |self, player|
	self[\paramManager].setPlayer(player);
	self[\outView].setPlayer(player);
	if(self[\pianoRoll].notNil)
	{ self[\pianoRoll].setPlayer(player); };
	if(self[\sequencer].notNil)
	{ self[\sequencer].setPlayer(player); };
	if(self[\beatSelector].notNil)
	{ self[\beatSelector].setPlayer(player); };
},

setWindow: { |self, window|
	self[\window] = window;
},

// Allows envViews to store retrieve their time scale
// (i.e. their zoom level)
setTimeScale: { |self, symbol, timeScale|
	if(self[\uiStates][self[\synth][\id]][\timeScale].isNil)
	{ self[\uiStates][self[\synth][\id]][\timeScale] = (); };
	self[\uiStates][self[\synth][\id]][\timeScale][symbol] = timeScale;
},

getTimeScale: { |self, symbol|
	self[\uiStates][self[\synth][\id]][\timeScale][symbol]
},

setSelectedBeat: { |self, beat|
	if(beat == self[\selectedBeat])
	{ beat = -1; };
	self[\selectedBeat] = beat;
	self[\paramManager].setSelectedBeat(beat);
	self[\beatSelector].setSelectedBeat(beat);
},

setStyles: { |self, style, smallStyle, widgetStyle|
	var backgroundColor = Color(
		style.backColor.red * 0.75,
		style.backColor.green * 0.75,
		style.backColor.blue * 0.75
	);

	self[\style] = style;
	self[\smallStyle] = smallStyle;
	self[\paramManager].setStyles(style, smallStyle, widgetStyle);
	if(self[\sequencer].notNil)
	{ self[\sequencer].setStyles(style, smallStyle, widgetStyle); };
	if(self[\pianoRoll].notNil)
	{ self[\pianoRoll].setStyles(style, smallStyle); };
	if(self[\beatSelector].notNil)
	{ self[\beatSelector].setStyles(style, smallStyle, widgetStyle); };

	self[\saveLoadButtons].setStyles(style, smallStyle, widgetStyle);
	self[\removeButton].style_(widgetStyle);
	self[\muteButton].style_(widgetStyle);
	self[\playButton].style_(widgetStyle);
	self[\outButton].style_(widgetStyle);
	self[\outLabel].style_(smallStyle);

	self[\mainView].background_(backgroundColor);
	self[\curtainView].background_(backgroundColor);
	self[\outView][\view].background_(backgroundColor);
},

playSynth: { |self|
	if(self[\synth].notNil
		and: { self[\synth][\type] == \discrete }) {
		self[\synth].playAt(
			max(
				0,
				self[\selectedBeat]
			);
		);
	};
},

// /!\ FIX ME: SAVE & LOAD SHOULD BE IN SYNTH
save: { |self|
	var file = File(
		self[\uiStates][self[\synth][\id]]
		[\file].standardizePath, "w");

	var data = self[\synth].getSaveData(
		self[\uiStates][self[\synth][\id]]
		[\dataName]
	);

	file.write(data.asCompileString);
	file.close;
	data.clear;
},

saveAs: { |self, dataName|
	self[\uiStates][self[\synth][\id]]
	[\file] =
	~gmDef[\userFolder]
	++ "presets/synths/"
	++ self[\synth][\name]
	++ "_"
	++ ~gmDef.getUID
	++ ".gmdef_synth";

	self[\uiStates][self[\synth][\id]]
	[\dataName] = dataName;

	self.save;
},

load: { |self, file, dataName|
	var data = this.executeFile(file);

	self[\synth].loadData(data);

	self[\uiStates][self[\synth][\id]]
	[\file] = file;

	self[\uiStates][self[\synth][\id]]
	[\dataName] = dataName;

	data.clear;
},

setZoomState: { |self, view|
	self[\uiStates][self[\synth][\id]][\zoom] = view;
},

// This is used to remember synths params
// (see paramManager)
// TO DO: UGLY?
setParamRule: { |self, synth, rule|
	self[\uiStates][synth[\id]][\paramRule]
	= rule;
},

getParamRule: { |self, synth|
	self[\uiStates][synth[\id]][\paramRule]
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

// Called when current synth is removed,
// (not switching to a new synth afterwards)
// see connectSynth
clearSynth: { |self|
	// Dezoom if needed
	if(self[\uiStates][self[\synth][\id]][\zoom].notNil)
	{ self[\uiStates][self[\synth][\id]][\zoom].dezoom; };
	// Clear ParamManager
	self[\paramManager].clearSynth;
	// Clear discrete components
	if(self[\synth][\type] == \discrete) {
		self[\sequencer].disconnectSynth;
		self[\sequencerContainer].visible_(false);
		self[\beatSelector].disconnectSynth;
		self[\beatSelectorContainer].visible_(false);
		if(self[\synth][\tunable]) {
			self[\pianoRoll].disconnectSynth;
			self[\pianoRollContainer].visible_(false);
		};
	};
	// Remove uiState
	self[\uiStates].removeAt(self[\synth][\id]);
	// Remove from connected synths
	self[\connectedSynths].remove(self[\synth]);
	// Done
	self[\synth] = nil;
	// Update UI
	self[\outButton].visible_(false);
	self[\outLabel].visible_(false);
	self[\playButton].visible_(false);
	self[\saveLoadButtons][\view].visible_(false);
	self[\removeButton].visible_(false);
	self[\muteButton].visible_(false);
	self[\title].string_("");
},

// Called when transitioning
// from a synth to an other
resetCurrentSynth: { |self|
	// Dezoom current view
	if(self[\uiStates][self[\synth][\id]][\zoom].notNil) {
		var view = self[\uiStates][self[\synth][\id]][\zoom];
		view.dezoom;
		// Dezooming purges zoomState, reassign it manually
		self.setZoomState(view);
	};
	// Store hidden views
	self[\uiStates][self[\synth][\id]][\hiddenViews].clear;
	self[\uiStates][self[\synth][\id]][\hiddenViews] =
	self[\paramManager][\hiddenViews].deepCopy;
	self[\paramManager].unhideAll;
	self.resetShowWidgets;

	// Reset UI mute function
	self[\synth].rmSignal(
		\mute,
		self[\uiMuteFunction]
	);
	self[\synth].rmSignal(
		\out,
		self[\outUIFunction]
	);
	self[\synth].rmSignal(
		\input,
		self[\inputView][\updateChannelIndex]
	);
	self[\synth] = nil;
},

connectSynth: { |self, synth|
	if(self[\connectedSynths].includes(synth).not) {
		var state = ();
		self[\uiStates][synth[\id]] = state;
		self[\connectedSynths].add(synth);
		self[\paramManager].adaptToSynth(synth);
		switch(synth[\type])

		// Discrete setup
		{ \discrete } {
			state[\selectedBeat] = -1;
			state[\zoom] = nil;
			state[\file] = nil;
			state[\dataName] = nil;
			state[\hiddenViews] = List(0);

			// Sequencer setup
			if(self[\sequencer].isNil) {
				self[\sequencer] = ~gmDef.getSequencerView;
				self[\sequencerContainer].layout.add(self[\sequencer][\view]);
				if(self[\player].notNil)
				{ self[\sequencer].setPlayer(self[\player]); };
				if(self[\style].notNil) {
					self[\sequencer].setStyles(
						self[\style],
						self[\textStyle],
						self[\widgetStyle]
					);
				};
			};

			// Piano Roll setup
			if(synth[\tunable] and: { self[\pianoRoll].isNil }) {
				self[\pianoRoll] = ~gmDef.getPianoRollView;
				self[\pianoRollContainer].layout.add(
					self[\pianoRoll][\view]);
				if(self[\player].notNil)
				{ self[\pianoRoll].setPlayer(self[\player]); };
				if(self[\style].notNil) {
					self[\pianoRoll].setStyles(
						self[\style],
						self[\textStyle],
						self[\widgetStyle]
					);
				};
			};
			
			// Beat Selector setup
			if(self[\beatSelector].isNil) {
				self[\beatSelector] = ~gmDef.getBeatSelector;
				self[\beatSelector].setSynthView(self);
				if(self[\player].notNil)
				{ self[\beatSelector].setPlayer(self[\player]); };
				if(self[\style].notNil) {
					self[\beatSelector].setStyles(
						self[\style],
						self[\textStyle],
						self[\widgetStyle]
					);
				};
				self[\beatSelectorContainer].layout.add(
					self[\beatSelector][\view]);
			};

			// TimeScales management;
			synth[\data][\params].do({ |param|
				if(param[\type] == \env) {
					if(state[\timeScale].isNil)
					{ state[\timeScale] = (); };

					if(param.includesKey(\timeScale)) {
						state[\timeScale][param[\symbol]]
						= param[\timeScale];
					} {
						state[\timeScale][param[\symbol]] = 1;
					};
				};
			});
		}

		{ \continuous } {
			state[\zoom] = nil;
			state[\file] = nil;
			state[\dataName] = nil;
			state[\hiddenViews] = List(0);
		}

		{ \effect } {
			state[\zoom] = nil;
			state[\file] = nil;
			state[\dataName] = nil;
			state[\hiddenViews] = List(0);
		}

		{ \input } {
			// Should we disable hide view on inputs ?
			// Should it be a GMDef param setting ?
			state[\hiddenViews] = List(0);
		};

		// Clear associated state when synth is removed
		synth.addSignal(
			\remove,
			{
				// If not current synth:
				if((self[\synth] == synth).not) {
					self[\uiStates].removeAt(synth[\id]);
					self[\connectedSynths].remove(synth);
				} { // Else, more complicated:
					self.clearSynth;
				};
			};
		);
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
	self[\title].string_(synth[\name]);

	// Pass hidden views to the manager
	self[\paramManager][\hiddenViews].clear;
	self[\paramManager][\hiddenViews] =
	self[\uiStates][self[\synth][\id]][\hiddenViews].deepCopy;
	self[\paramManager].setSynth(synth);
	self[\outView].setSynth(synth);

	// Show widgets that might have been
	// hidden after synth clearing
	if(self[\hideRules].includes(\out).not) {
		self[\outButton].visible_(true);
		self[\outLabel].visible_(true);
	};
	if(self[\hideRules].includes(\remove).not) {
		self[\removeButton].visible_(true);
	};
	if(self[\hideRules].includes(\saveLoad).not) {
		self[\saveLoadButtons][\view].visible_(true);
	};

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
				self[\pianoRoll].disconnectSynth;
				self[\pianoRollContainer].visible_(false);
			};
		};

		// Beat Selector setup
		self[\beatSelector].connect(synth);
		if(self[\uiStates][self[\synth][\id]][\selectedBeat] == -1)
		{ self[\beatSelector][\view].desindex; }
		{ self[\beatSelector][\view].state_(
			self[\uiStates][self[\synth][\id]][\selectedBeat]); };
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
	}

	{ \continuous } {
		if(synth[\hasAmpParam]) {
			self[\muteButton].visible_(true);
			// Connect mute function
			self[\synth].addSignal(\mute, self[\uiMuteFunction]);
			self[\uiMuteFunction].value;
		} {
			self[\muteButton].visible_(false);
		};

		// hide unneeded views
		self.hideRythmUI;
		self[\inputView][\view].visible_(false);
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
		self[\saveLoadButtons][\view].visible_(false);
	};

	// Zoom if a view was previously zoomed
	if(self[\uiStates][self[\synth][\id]][\zoom].notNil)
	{ self[\uiStates][self[\synth][\id]][\zoom].zoom; };

	// Update beat display if needed
	if(self[\uiStates][self[\synth][\id]]
		.includesKey(\selectedBeat)) {
		self[\paramManager].displayBeat(
			self[\uiStates][self[\synth][\id]][\selectedBeat]);
		if(self[\uiStates][self[\synth][\id]][\selectedBeat] == -1)
		{ self[\beatSelector].desindex; }
		{ self[\beatSelector].state_(
			self[\uiStates][self[\synth][\id]][\selectedBeat]); };
		self[\selectedBeat] =
		self[\uiStates][self[\synth][\id]][\selectedBeat];
	};

	// Update out label
	self[\synth].addSignal(\out, self[\outUIFunction]);
	self[\outUIFunction].value;

	// Show view again
	self[\view].layout.index_(0);
},

hideRemove: { |self|
	if(self[\hideRules].includes(\remove).not) {
		self[\removeButton].visible_(false);
		self[\hideRules].add(\remove);
	};
},

hideOut: { |self|
	if(self[\hideRules].includes(\out).not) {
		self[\outButton].visible_(false);
		self[\outLabel].visible_(false);
		self[\hideRules].add(\out);
	};
},

hideSaveLoad: { |self|
	if(self[\hideRules].includes(\saveLoad).not) {
		self[\saveLoadButtons][\view].visible_(false);
		self[\hideRules].add(\saveLoad);
	};
},

hideRemove: { |self|
	if(self[\hideRules].includes(\remove).not) {
		self[\removeButton].visible_(false);
		self[\hideRules].add(\remove);
	};
},

doRemove: { |self|
	self[\saveLoadButtons].doRemove;
	self[\hideRules].clear;
	self[\inputView].doRemove;
	self[\paramManager].doRemove;
	if(self[\pianoRoll].notNil)
	{ self[\pianoRoll].doRemove; };
	// TO DO: CHECK THIS:
	self[\uiStates].do({ |state| state.clear; });
	self[\uiStates].clear;
	if(self[\beatSelector].notNil)
	{ self[\beatSelector].doRemove; };
	if(self[\sequencer].notNil)
	{ self[\sequencer].doRemove; };
	self[\connectedSynth].clear;
	self[\outView].doRemove;
	// Views
	self[\view].removeAll;
	self[\view].remove;
	// Self
	self.clear;
},

init: { |self|
	var outLayout = HLayout()
	.margins_(0)
	.spacing_(0);

	// We'll have a curtain hiding
	// everything while views are rearranged
	self[\view] = UserView()
	.acceptsMouseOver_(true)
	.layout_(StackLayout());
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
	self[\hideRules] = List(0);
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
	// Used to remember synth's state
	self[\uiStates] = ();
	self[\currentBeat] = 0;
	self[\selectedBeat] = -1;

	self[\paramManager][\synthView] = self;

	// Remove button
	self[\removeButton] = GMButton()
	.maxWidth_(64)
	.svg_(~gmDef.getIcon(\remove))
	.action_({
		if(self[\synth].notNil)
		{ self[\synth].doRemove; };
	});
	self.addMenuItem(self[\removeButton]);

	// Save / Load UI
	// /!\ TO DO: should call synth methods
	self[\saveLoadButtons] = ~gmDef.getSaveLoadButtons;
	self[\saveLoadButtons].setSaveFunction({
		if(self[\uiStates][self[\synth][\id]][\file].notNil) {
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
	self[\saveLoadButtons].setSaveAsFunction({
		if(self[\window].notNil) {
			self[\window].callTextInput(
				{ |dataName| self.saveAs(dataName) },
				"Select a name :",
				"Ok"
			);
		};
	});
	self[\saveLoadButtons].setLoadFunction({
		if(self[\window].notNil) {
			self[\window].callLoader(
				\synth,
				self[\synth][\name],
				{ |file, dataName| self.load(file, dataName); },
				"Select a preset to load :"
			);
		};
	});
	self[\saveLoadButtons][\view].visible_(false);
	self.addMenuItem(self[\saveLoadButtons][\view]);
	
	// Out
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
		if(self[\synth].notNil)
		{ self[\synth].setMuted(self[\synth][\muted].not); };
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
		~gmDef[\style],
		~gmDef[\textStyle],
		~gmDef[\widgetStyle]
	);
},
)