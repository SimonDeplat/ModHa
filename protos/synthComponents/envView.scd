(
// This is the continuation of parents 'setSynthAndParam'
synthAndParam: { |self, synth, param|
	self.disconnectSynth;
	self[\synth] = synth;
	self[\param] = param;
	
	switch(synth[\type])

	{ \discrete } {
		// EnvView setup
		self[\envView]
		.action_({ |value|
			if(self[\mode] == \value) {
				synth.setParam(
					param[\symbol],
					-1,
					value
				);
			} {
				synth.setParam(
					param[\symbol],
					self[\currentBeat],
					value
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
				self[\envView].env_(
					synth[\params][param[\symbol]];);
				self[\beatDisplay].string_("-");
			} {
				if(self[\player].notNil) {
					if(self[\frozen].not)
					{ self.getTrackEnv(self[\player][\actualBeat]); }
					{ self.getTrackEnv(self[\currentBeat]); };
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
		// Copy Paste setup
		self[\copyButton].action_({
			if(self[\mode] == \value)
			{ ~gmDef.copyEnv(synth[\params][param[\symbol]]); }
			{ ~gmDef.copyEnv(synth[\track][self[\currentBeat]]
				[param[\symbol]]); };
		});
		self[\pasteButton]
		.action_({
			var env = ~gmDef.pasteEnv;
			if(env.notNil) {
				// Shrink env if needed
				if(env.levels.size > param[\maxSize]) {
					env = Env(
						env.levels.copyRange(
							0, param[\maxSize] - 1),
						env.times.copyRange(
							0, param[\maxSize] - 2),
						env.curve.copyRange(
							0, param[\maxSize] - 2)
					);
				};
				if(self[\mode] == \value) {
					synth.setParam(
						param[\symbol],
						-1,
						env
					);
				} {
					synth.setParam(
						param[\symbol],
						self[\currentBeat],
						env
					); };
			};
		});
	}

	{ \continuous } {
		self[\envView].action_({ |value|
			synth.setParam(param[\symbol], -1, value); });
		self[\paramFunc] = {
			self[\envView].env_(synth[\params][param[\symbol]]; );
		};
		self[\switch].visible_(false);
	}

	{ \input } {
		self[\envView].action_({ |value|
			synth.setParam(param[\symbol], -1, value); });
		self[\paramFunc] = {
			self[\envView].env_(synth[\params][param[\symbol]]; );
		};
		self[\switch].visible_(false);
	}

	{ \effect } {
		self[\envView].action_({ |value|
			synth.setParam(param[\symbol], -1, value); });
		self[\paramFunc] = {
			self[\envView].env_(synth[\params][param[\symbol]]; );
		};
		self[\switch].visible_(false);
	};

	// Time Scale sync
	self.setTimeScale(
		self[\manager].getTimeScale(param[\symbol]),
		false
	);

	// Last level is zero if param == \env
	// /!\ FIX ME: should be in gmDef
	if(param[\symbol] == \env)
	{ self[\envView].lastLevelIsZero_(true) }
	{ self[\envView].lastLevelIsZero_(false) };

	synth.addSignal(param[\symbol], self[\paramFunc]);
	self[\paramFunc].value;
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(self[\param][\symbol], self[\paramFunc]);
		self[\synth] = nil;
		self[\param] = nil;
		self[\envView].action_({});
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
		) { self.getTrackEnv(player[\actualBeat]); };
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
						{ self.getTrackEnv(self[\player][\actualBeat]); };
					};
				} {
					self[\currentBeat] = beat%self[\synth][\track].size;
					if(self[\mode] == \track) {
						self[\frozen] = true;
						self.getTrackEnv(self[\currentBeat]);
					};
				};
			};
		};
},

// Shouldn't be called if \player or \synth is nil
getTrackEnv: { |self, beat|
	beat = beat%self[\synth][\track].size;
	self[\envView].env_(
		self[\synth][\track][beat][self[\param][\symbol]];
	);
	self[\beatDisplay].string_(beat.asString);
},

zoom: { |self|
	self[\hideButton].visible_(false);
	self[\zoomButton]
	.svg_(~gmDef.getIcon(\zoomIn))
	.action_({ self.dezoom; });
	self[\manager].zoom(self);
},

dezoom: { |self|
	self[\hideButton].visible_(true);
	// Reinsert the view at its original location
	self[\layout].insert(
		self[\view],
		self[\layoutIndex],
		self[\stretch]
	);
	self[\zoomButton]
	.svg_(~gmDef.getIcon(\zoomOut))
	.action_({ self.zoom; });
	self[\manager].dezoom;
},

setTimeScale: { |self, timeScale, update = true|
	if(update) {
		self[\manager].setTimeScale(
			self[\symbol], timeScale); };
	self[\envView].timeScale_(timeScale);
	self[\scaleSlider].value_(timeScale);
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\switch].style_(smallStyle);
	self[\hideButton].style_(smallStyle);
	self[\zoomButton].style_(smallStyle);
	self[\copyButton].style_(smallStyle);
	self[\pasteButton].style_(smallStyle);
	self[\beatDisplay].style_(smallStyle);
	self[\title].style_(smallStyle);
	self[\envView].style_(style);
	self[\glassIcon].style_(smallStyle);
	self[\scaleSlider].style_(smallStyle);
},

init: { |self|
	var switchLayout = HLayout()
	.margins_(0)
	.spacing_(0);
	var copyPasteLayout = HLayout()
	.spacing_(0)
	.margins_(0);
	var timeScaleLayout = HLayout()
	.spacing_(0)
	.margins_(0);
	// Init paramViewParent
	self.initParent;
	// Variables
	self[\type] = \env;
	self[\param] = nil;
	self[\synth] = nil;
	self[\player] = nil;
	self[\frozen] = false;
	self[\mode] = \value;
	self[\currentBeat] = 0;
	// Views
	self[\envView] = GMCurveEnvView();
	self[\glassIcon] = GMButton()
	.svg_(~gmDef.getIcon(\glass));
	self[\scaleSlider] = GMFaderSlider()
	.displayValue_(false)
	.orientation_(\horizontal)
	.min_(0.05)
	.max_(5.0)
	.action_({ |value| self.setTimeScale(value); });
	timeScaleLayout.add(self[\glassIcon], 1);
	timeScaleLayout.add(self[\scaleSlider], 9);
	self.addZoomButton;
	self[\beatDisplay] = GMTextView()
	.displayFrame_(true);
	self[\switch] = GMButton()
	.svg_(~gmDef.getIcon(\slider));
	switchLayout.add(self[\beatDisplay], 1);
	switchLayout.add(self[\switch], 1);
	self[\copyButton] = GMFeedbackButton()
	.svg_(~gmDef.getIcon(\copy));
	self[\pasteButton] = GMFeedbackButton()
	.svg_(~gmDef.getIcon(\paste));
	copyPasteLayout
	.add(self[\copyButton])
	.add(self[\pasteButton]);
	self.addMenuItem(switchLayout, 2);
	self.addMenuItem(copyPasteLayout, 2);
	self[\paramContainer].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\envView], 8)
		.add(timeScaleLayout, 2)
	);
	self
},
).parent_(~gmDef[\paramViewParent])