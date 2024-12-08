(
// This is the continuation of parents 'setSynthAndParam'
synthAndParam: { |self, synth, param|
	self.disconnectSynth;
	self[\synth] = synth;
	self[\param] = param;
	self[\selector]
	.states_(param[\texts]);
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
				self[\selectedBeat],
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
				{ self.getTrackValue(self[\selectedBeat]); };
			};
		};
	};
	// Switch setup
	self[\switch].action_({
		var mode = synth[\paramsModes][param[\symbol]];
		if(mode == \value) {
			mode = \track;
			if(self[\player].notNil) {
				self[\selectedBeat] = self[\manager][\selectedBeat];
				if(self[\selectedBeat] == -1)
				{ self[\frozen] = false; }
				{ self[\frozen] = true; };
			};
		} {
			mode = \value;
		};
		synth.setMode(param[\symbol], mode);
	});
	synth.addSignal(param[\symbol], self[\paramFunc]);
	self[\paramFunc].value;
	self[\synthRMFunction] = { self.disconnectSynth; };
	self[\synth].addSignal(\remove, self[\synthRMFunction]);
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(self[\param][\symbol], self[\paramFunc]);
		self[\synth].rmSignal(\remove, self[\synthRMFunction]);
		self[\selector].action_({});
		self[\synth] = nil;
		self[\param] = nil;
		self[\synthRMFunction] = nil;
	};
},

setPlayer: { |self, player|
	self.disconnectPlayer;
	self[\player] = player;
	self[\beatFunc] = {
		if(self[\synth].notNil
			and: {
				(self[\mode] == \track)
				and: { self[\frozen].not }
			}
		) { self.getTrackValue(player[\actualBeat]); };
	};
	self[\beatFunc].value;
	self[\player].addSignal(\beat, self[\beatFunc]);
	self[\playerRMFunction] = { self.disconnectPlayer; };
	self[\player].addSignal(\remove, self[\playerRMFunction]);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\beat, self[\beatFunc]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\player] = nil;
		self[\beatFunc] = nil;
		self[\playerRMFunction] = nil;
	};
},

setSelectedBeat: { |self, beat|
	self[\selectedBeat] = beat;
	if(self[\synth].notNil) {
		if(self[\player].notNil) {
			if(beat == -1) {
				if(self[\frozen]) {
					self[\frozen] = false;
					if(self[\mode] == \track)
					{ self.getTrackValue(self[\player][\actualBeat]); };
				};
			} {
				self[\selectedBeat] = beat%self[\synth][\track].size;
				if(self[\mode] == \track) {
					self[\frozen] = true;
					self.getTrackValue(self[\selectedBeat]);
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
	self[\switch].style_(widgetStyle);
	self[\hideButton].style_(widgetStyle);
	self[\beatDisplay].style_(widgetStyle);
	self[\title].style_(smallStyle);
	self[\selector].style_(style);
},

doRemove: { |self|
	self.disconnectSynth;
	self.disconnectPlayer;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
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
	self[\selectedBeat] = -1;
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
	self
},
).parent_(~gmDef[\paramViewParent])