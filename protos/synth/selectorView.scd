(
// This is the continuation of parents 'setSynthAndParam'
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
			// Check if mode has changed
			var currentMode = self[\mode];
			self[\mode] = synth[\paramsModes][param[\symbol]];
			if(self[\mode] != currentMode) {
				if(self[\mode] == \value) {
					if(self[\frozen])
					{ self[\frozen] = false; };
					self[\switch]
					.svg_(~gmDef.getIcon(\slider));
				} {
					self[\switch]
					.svg_(~gmDef.getIcon(\multiSlider));
				};
			};
			if(self[\mode] == \value) {
				self[\selector].state_(
					param[\values].detectIndex({ |value|
						value == synth[\params][param[\symbol]] });
				);
				self[\beatDisplay].string_("-");
			} {
				if(self[\player].notNil) {
					if(self[\frozen].not)
					{ self.getTrackValue(self[\player][\actualBeat]); }
					{ self.getTrackValue(self[\currentBeat]); };
				};
			};
		};
		// Switch setup
		self[\switch].visible_(true);
		self[\switch].action_({
			var mode = synth[\paramsModes][param[\symbol]];
			if(mode == \value) {
				mode = \track;
				if(self[\player].notNil) {
					self[\currentBeat] = self[\manager][\displayedBeat];
					if(self[\currentBeat] == -1)
					{ self[\frozen] = false; }
					{ self[\frozen] = true; };
				};
			} {
				mode = \value;
			};
			synth.setMode(param[\symbol], mode);
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
	self.disconnectPlayer;
	self[\player] = player;
	self[\beatFunc] = {
		if(self[\synth].notNil
			and: { (
				(self[\synth][\type] == \discrete)
				and: { (self[\mode] == \track)
					and: { self[\frozen].not }
				}
			) }
		) { self.getTrackValue(player[\actualBeat]); };
	};
	self[\beatFunc].value;
	self[\player].addSignal(\beat, self[\beatFunc]);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\beat, self[\beatFunc]);
		self[\player] = nil;
		self[\beatFunc] = nil;
	};
},

displayBeat: { |self, beat|
	self[\currentBeat] = beat;
	if(self[\synth].notNil
		and: { self[\synth][\type] == \discrete }) {
			if(self[\player].notNil) {
				if(beat == -1) {
					if(self[\frozen]) {
						self[\frozen] = false;
						if(self[\mode] == \track)
						{ self.getTrackValue(self[\player][\actualBeat]); };
					};
				} {
					self[\currentBeat] = beat%self[\synth][\track].size;
					if(self[\mode] == \track) {
						self[\frozen] = true;
						self.getTrackValue(self[\currentBeat]);
					};
				};
			};
		};
},

// Shouldn't be called if \player or \synth is nil
getTrackValue: { |self, beat|
	beat = beat%self[\synth][\track].size;
	self[\selector].state_(
		self[\param][\values].detectIndex({ |value|
			value == self[\synth][\track][beat][self[\param][\symbol]];
		});
	);
	self[\beatDisplay].string_(beat.asString);
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\switch].style_(smallStyle);
	self[\hideButton].style_(smallStyle);
	self[\beatDisplay].style_(smallStyle);
	self[\title].style_(smallStyle);
	self[\selector].style_(style);
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