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
					self[\selectedBeat],
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
					{ self.getTrackEnv(self[\selectedBeat]); };
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
		// Copy Paste setup
		self[\copyButton].action_({
			if(self[\mode] == \value) {
				~gmDef.doCopy(
					\env,
					synth[\params][param[\symbol]]);
			} {
				~gmDef.doCopy(
					\env,
					synth[\track][self[\selectedBeat]][param[\symbol]]);
			};
		});
		self[\pasteButton]
		.action_({
			var env = ~gmDef.doPaste(\env);
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
						self[\selectedBeat],
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
	self[\synthRMFunction] = { self.disconnectSynth; };
	self[\synth].addSignal(\remove, self[\synthRMFunction]);
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(self[\param][\symbol], self[\paramFunc]);
		self[\synth].rmSignal(\remove, self[\synthRMFunction]);
		self[\envView].action_({});
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
					self[\selectedBeat] = beat%self[\synth][\track].size;
					if(self[\mode] == \track) {
						self[\frozen] = true;
						self.getTrackEnv(self[\selectedBeat]);
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
			self[\param][\symbol], timeScale); };
	self[\envView].timeScale_(timeScale);
	self[\scaleSlider].value_(timeScale);
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\switch].style_(widgetStyle);
	self[\hideButton].style_(widgetStyle);
	self[\zoomButton].style_(widgetStyle);
	self[\copyButton].style_(widgetStyle);
	self[\pasteButton].style_(widgetStyle);
	self[\beatDisplay].style_(widgetStyle);
	self[\title].style_(smallStyle);
	self[\envView].style_(style);
	self[\glassIcon].style_(widgetStyle);
	self[\scaleSlider].style_(smallStyle);
},

doRemove: { |self|
	self.disconnectSynth;
	self.disconnectPlayer;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
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
	self[\selectedBeat] = -1;
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