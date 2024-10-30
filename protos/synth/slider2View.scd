(
// This is NOT the continuation of parents 'setSynthAndParam':
// This one differs from other views because it manipulates
// two params instead of one
setSynthAndParams: { |self, synth, xParam, yParam, index = nil|
	self.disconnect;
	self[\synth] = synth;
	self[\xParam] = xParam;
	self[\yParam] = yParam;
	
	self.setTitles(xParam[\text], yParam[\text]);
	self[\preferredIndex] = index;
	self[\index] = index;

	self[\active] = true;
	self[\view].visible_(true);

	self.configureSlider(xParam, yParam);
	switch(synth[\type])

	{ \discrete } {
		// Slider setup
		self[\slider]
		.action_({ |xValue, yValue|
			if(self[\mode] == \value) {
				synth.setParam(
					xParam[\symbol],
					-1,
					xValue
				);
				synth.setParam(
					yParam[\symbol],
					-1,
					yValue
				);
			} {
				synth.setParam(
					xParam[\symbol],
					self[\selectedBeat],
					xValue
				);
				synth.setParam(
					yParam[\symbol],
					self[\selectedBeat],
					yValue
				);
			};
		});
		// Signal function
		self[\paramFunc] = {
			// Check if mode has changed
			var currentMode = self[\mode];
			self[\mode] = synth[\paramsModes][xParam[\symbol]];
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
				self[\slider].values_([
					synth[\params][xParam[\symbol]],
					synth[\params][yParam[\symbol]]
				]);
				self[\beatDisplay].string_("-");
			} {
				if(self[\player].notNil) {
					if(self[\frozen].not)
					{ self.getTrackValues(self[\player][\actualBeat]); }
					{ self.getTrackValues(self[\selectedBeat]); };
				};
			};
		};
		// Switch setup
		self[\switch].visible_(true);
		self[\switch].action_({
			var mode = synth[\paramsModes][xParam[\symbol]];
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
			synth.setMode(xParam[\symbol], mode);
		});
	}

	{ \continuous } {
		// Slider setup
		self[\slider]
		.action_({ |xValue, yValue|
			synth.setParam(xParam[\symbol], -1, xValue);
			synth.setParam(yParam[\symbol], -1, yValue);
		});
		// Signal function
		self[\paramFunc] = {
			self[\slider].values_([
				synth[\params][xParam[\symbol]],
				synth[\params][yParam[\symbol]]
			]);
		};
		// Show/hide widgets
		self[\switchLayout].visible_(false);
	}

	{ \input } {
		// Slider setup
		self[\slider]
		.action_({ |xValue, yValue|
			synth.setParam(xParam[\symbol], -1, xValue);
			synth.setParam(yParam[\symbol], -1, yValue);
		});
		// Signal function
		self[\paramFunc] = {
			self[\slider].values_([
				synth[\params][xParam[\symbol]],
				synth[\params][yParam[\symbol]]
			]);
		};
		// Show/hide widgets
		self[\switchLayout].visible_(false);
	}

	{ \effect } {
		// Slider setup
		self[\slider]
		.action_({ |xValue, yValue|
			synth.setParam(xParam[\symbol], -1, xValue);
			synth.setParam(yParam[\symbol], -1, yValue);
		});
		// Signal function
		self[\paramFunc] = {
			self[\slider].values_([
				synth[\params][xParam[\symbol]],
				synth[\params][yParam[\symbol]]
			]);
		};
		// Show/hide widgets
		self[\switchLayout].visible_(false);
	};
	
	synth.addSignal(xParam[\symbol], self[\paramFunc]);
	synth.addSignal(yParam[\symbol], self[\paramFunc]);
	self[\paramFunc].value;
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(self[\xParam][\symbol], self[\paramFunc]);
		self[\synth].rmSignal(self[\yParam][\symbol], self[\paramFunc]);
		self[\synth] = nil;
		self[\xParam] = nil;
		self[\yParam] = nil;
		self[\slider].action_({});
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
		) { self.getTrackValues(player[\actualBeat]); };
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

setSelectedBeat: { |self, beat|
	self[\selectedBeat] = beat;
	if(self[\synth].notNil
		and: { self[\synth][\type] == \discrete }) {
			if(self[\player].notNil) {
				if(beat == -1) {
					if(self[\frozen]) {
						self[\frozen] = false;
						if(self[\mode] == \track)
						{ self.getTrackValues(self[\player][\actualBeat]); };
					};
				} {
					self[\selectedBeat] = beat%self[\synth][\track].size;
					if(self[\mode] == \track) {
						self[\frozen] = true;
						self.getTrackValues(self[\selectedBeat]);
					};
				};
			};
		};
},

// Shouldn't be called if \player or \synth is nil
getTrackValues: { |self, beat|
	beat = beat%self[\synth][\track].size;
	self[\slider].values_([
		self[\synth][\track][beat][self[\xParam][\symbol]],
		self[\synth][\track][beat][self[\yParam][\symbol]]
	]);
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

configureSlider: { |self, xParam, yParam|
	self[\slider].min_([xParam[\min], yParam[\min]]);
	self[\slider].max_([xParam[\max], yParam[\max]]);
	self[\slider].scales_([xParam[\scale], yParam[\scale]]);

	// /!\ TODO -> gmDefDecoder now centralizes this
	// -> but should it ? -> yes I think
	/*	if(param.includesKey(\polarity))
	{ self[\slider].polarity_(param[\polarity]); };
	if(param.includesKey(\helpersNumber))
	{ self[\slider].helpersNumber_(param[\helpersNumber]); };
	if(param.includesKey(\helpersSubdivisons))
	{ self[\slider].helpersSubdivisions_(param[\helpersSubdivisons]); };
	if(param.includesKey(\helpersStyle))
	{ self[\slider].helpersStyle_(param[\helpersStyle]); };
	if(param.includesKey(\displayFunction)) {
	self[\slider].displayFunction_(param[\displayFunction]);
	} {
	self[\slider].displayFunction_(nil);
	};*/
},

setTitles: { |self, xTitle, yTitle|
	self[\xTitle].string_(xTitle);
	self[\yTitle].string_(yTitle);
	self[\title].string_(xTitle ++ "/" ++ yTitle);
},

setStyles: { |self, style, smallStyle, widgetStyle|
	self[\switch].style_(widgetStyle);
	self[\hideButton].style_(widgetStyle);
	self[\zoomButton].style_(widgetStyle);
	self[\beatDisplay].style_(widgetStyle);
	self[\xTitle].style_(smallStyle);
	self[\yTitle].style_(smallStyle);
	self[\slider].style_(style);
},

init: { |self|
	var dummyView = UserView();
	// Init paramViewParent
	self.initParent;
	// Variables
	self[\type] = \slider2;
	self[\xParam] = nil;
	self[\yParam] = nil;
	self[\synth] = nil;
	self[\player] = nil;
	self[\channel] = 0;
	self[\frozen] = false;
	self[\mode] = \value;
	self[\selectedBeat] = -1;
	// Views
	self[\xTitle] = GMTextView()
	.orientation_(\top)
	.displayFrame_(true);
	self[\yTitle] = GMTextView()
	.displayFrame_(true);
	self[\slider] = GMSymbol2DSlider()
	.onResize_({
		self[\xTitle].maxWidth_(self[\yTitle].bounds.height);
		dummyView.maxWidth_(self[\yTitle].bounds.height);
	});
	self.addZoomButton;
	self[\switchLayout] = UserView().layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
	);
	self[\beatDisplay] = GMTextView()
	.displayFrame_(true);
	self[\switch] = GMButton()
	.svg_(~gmDef.getIcon(\slider));
	self[\switchLayout].layout.add(self[\beatDisplay], 1);
	self[\switchLayout].layout.add(self[\switch], 1);
	self.addMenuItem(self[\switchLayout], 2);
	self.hideTitle;
	self[\paramContainer].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(
			HLayout()
			.margins_(0)
			.spacing_(0)
			.add(
				VLayout()
				.margins_(0)
				.spacing_(0)
				.add(dummyView, 1)
				.add(self[\xTitle], 9),
				1
			)
			.add(
				VLayout()
				.margins_(0)
				.spacing_(0)
				.add(self[\yTitle], 1)
				.add(self[\slider], 9),
				9
			)
		)
	);
	self
},
).parent_(~gmDef[\paramViewParent])