(
// This is the continuation of parents 'setSynthAndParam'
// /!\ WIP: CHECK THIS MESS !!!
synthAndParam: { |self, synth, param|
	self.disconnectSynth;
	self[\synth] = synth;
	self[\param] = param;
	self[\selector]
	.states_(param[\texts]);

	switch(synth[\type])

	{ \discrete } {
		// Selector setup
		self[\selector]
		.action_({ |index|
			if(self[\mode] == \value) {
				synth.setParam(
					param[\symbol],
					-1,
					param[\values][index]
				);
			} {
				synth.setParam(
					param[\symbol],
					self[\currentBeat],
					param[\values][index]
				);
			};
		});
		// Signal function
		self[\paramFunc] = {
			var currentMode = self[\mode];
			// Track might have been resized, check
			// that displayed beat is inbounds
			if((synth[\track].size - 1) < self[\currentBeat]) {
				if(self[\frozen]) {
					self[\frozen] = false;
					if(self[\player].notNil)
					{ self[\currentBeat] = self[\player][\currentBeat]; };
					// This could be otpimized, because
					// every env and selector will notify
					// param manager, but once is enough
					// /!\ paramManager should implement an uiFunc
					// that responds to synth's \nBeats instead
					self[\manager].notifyOutOfBounds;
				};
			};
			self[\mode] = synth[\paramsModes][param[\symbol]];
			if(self[\mode] != currentMode) {
				if(self[\mode] == \value) {
					if(self[\frozen])
					{ self[\frozen] = false; };
					self[\switch]
					.svg_(~gmDef.getIcon(\slider));
				} {
					// FIX ME: ACTUAL BEAT CALCULATION
					if(self[\player].notNil)
					{ self[\currentBeat] = self[\player][\currentBeat]; };

					self[\switch]
					.svg_(~gmDef.getIcon(\multiSlider));
				};
			};
			if(self[\mode] == \value) {
				self[\selector].state_(
					param[\values].detectIndex({ |value|
						value == synth[\params][param[\symbol]]
					});
				);
				self[\beatDisplay].string_("-");
			} {
				self[\selector].state_(
					param[\values].detectIndex({ |value|
						value == synth[\track]
						[self[\currentBeat]][param[\symbol]]
					});
				);
				self[\beatDisplay].string_(
					self[\currentBeat].asString);
			};
		};
		// Switch setup
		self[\switchLayout].visible_(true);
		self[\switch].action_({
			var mode = synth[\paramsModes][param[\symbol]];
			if(mode == \value)
			{ mode = \track }
			{ mode = \value };
			synth.setMode(
				param[\symbol],
				mode
			);
		});
	}

	{ \continuous } {
		// Selector setup
		self[\selector].action_({ |index|
			synth.setParam(param[\symbol], -1, param[\values][index]);
		});
		// Signal function
		self[\paramFunc] = {
			self[\selector].state_(
				param[\values].detectIndex({ |value|
					value == synth[\params][param[\symbol]] });
			);
		};
		// Show/Hide widgets
		self[\switchLayout].visible_(false);
	}

	{ \input } {
		// Selector setup
		self[\selector].action_({ |index|
			synth.setParam(param[\symbol], -1, param[\values][index]);
		});
		// Signal function
		self[\paramFunc] = {
			self[\selector].state_(
				param[\values].detectIndex({ |value|
					value == synth[\params][param[\symbol]] });
			);
		};
		// Show/Hide widgets
		self[\switchLayout].visible_(false);
	}

	{ \effect } {
		// Selector setup
		self[\selector].action_({ |index|
			synth.setParam(param[\symbol], -1, param[\values][index]);
		});
		// Signal function
		self[\paramFunc] = {
			self[\selector].state_(
				param[\values].detectIndex({ |value|
					value == synth[\params][param[\symbol]] });
			);
		};
		// Show/Hide widgets
		self[\switchLayout].visible_(false);
	};

	synth.addSignal(param[\symbol], self[\paramFunc]);
	self[\paramFunc].value;
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(self[\param][\symbol], self[\paramFunc]);
		self[\synth] = nil;
		self[\param] = nil;
		self[\selector].action_({});
	};
},

setPlayer: { |self, player|
	self[\player] = player;
	// FIX ME: ACTUAL BEAT CALCULATION
	self.setBeat(player[\currentBeat]);
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\switch].style_(smallStyle);
	self[\hideButton].style_(smallStyle);
	self[\beatDisplay].style_(smallStyle);
	self[\title].style_(smallStyle);
	self[\selector].style_(style);
},

displayBeat: { |self, beat|
	if(beat == -1) {
		self[\frozen] = false;
		// FIX ME: ACTUAL BEAT CALCULATION
		if(self[\player].notNil)
		{ self.setBeat(self[\player][\currentBeat]); };
	} {
		self[\frozen] = true;
		self[\currentBeat] = beat;
		self[\uiFunc].value;
	};
},

setBeat: { |self, beat|
	if((self[\mode] == \track)
		and: { self[\frozen].not }) {
		self[\currentBeat] = beat;
		self[\uiFunc].value;
	};
},

init: { |self|
	// Init paramViewParent
	self.initParent;
	// Variables
	self[\type] = \selector;
	self[\param] = nil;
	self[\synth] = nil;
	self[\player] = nil;
	self[\frozen] = false;
	self[\mode] = \value;
	self[\currentBeat] = 0;
	// Views
	self[\selector] = GMMultiButton()
	.fontRatio_(0.95)
	.orientation_(\vertical);
	self[\paramContainer].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\selector])
	);
	self[\beatDisplay] = GMTextView()
	.displayFrame_(true);
	self[\switch] = GMButton()
	.svg_(~gmDef.getIcon(\slider));
	self[\switchLayout] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\beatDisplay], 1)
		.add(self[\switch], 1)
	);
	self.addMenuItem(self[\switchLayout], 2);
},
).parent_(~gmDef[\paramViewParent])