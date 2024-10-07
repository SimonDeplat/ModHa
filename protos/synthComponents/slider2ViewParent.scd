(
player: nil,
setPlayer: { |self, player|
	self[\player] = player;
	// FIX ME: ACTUAL BEAT CALCULATION
	self.setBeat(player[\currentBeat]);
},

setStyles: { |self, style, smallStyle|
	self[\switch].style_(smallStyle);
	self[\hideButton].style_(smallStyle);
	self[\zoomButton].style_(smallStyle);
	self[\beatDisplay].style_(smallStyle);
	self[\xTitle].style_(smallStyle);
	self[\yTitle].style_(smallStyle);
	self[\slider].style_(style);
},

setTitles: { |self, xTitle, yTitle|
	self[\xTitle].string_(xTitle);
	self[\yTitle].string_(yTitle);
	self[\title].string_(xTitle ++ "/" ++ yTitle);
},

frozen: false,
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

mode: \value,
currentBeat: 0,
setBeat: { |self, beat|
	if((self[\mode] == \track)
		and: { self[\frozen].not }) {
		self[\currentBeat] = beat;
		self[\uiFunc].value;
	};
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

symbols: nil,
disconnect: { |self|
	if(self[\symbols].notNil) {
		if(self[\synth].notNil
			and: { self[\uiFunc].notNil }) {
			self[\synth].rmUINotification(
				self[\symbols][0],
				self[\uiFunc]
			);
			self[\synth].rmUINotification(
				self[\symbols][1],
				self[\uiFunc]
			);
			self[\uiFunc] = nil;
		};
	};
	self[\symbols] = nil;
	self[\synth] = nil;
},

configureSlider: { |self, xParam, yParam|
	self[\slider].min_([xParam[\min], yParam[\min]]);
	self[\slider].max_([xParam[\max], yParam[\max]]);
	self[\slider].scales_([xParam[\scale], yParam[\scale]]);

	// /!\ TODO
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

// This one differs from other views because it manipulates
// two params instead of one
setSynthAndParams: { |self, synth, xParam, yParam, index = nil|
	// 'Parent init'
	self.disconnect;
	self[\synth] = synth;

	// This is used to identify the view
	// (for example when storing hidden status)
	self[\symbol] = xParam[\symbol];
	self[\symbols] = [xParam[\symbol], yParam[\symbol]];

	self.setTitles(xParam[\text], yParam[\text]);
	self[\preferredIndex] = index;
	self[\index] = index;

	self[\active] = true;
	self[\view].visible_(true);

	// Init

	// Slider setup
	self.configureSlider(xParam, yParam);

	switch(synth[\type])

	{ \discrete } {
		// Slider action setup
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
					self[\currentBeat],
					xValue
				);
				synth.setParam(
					yParam[\symbol],
					self[\currentBeat],
					yValue
				);
			};
		});

		// Switch setup
		self[\switchLayout].visible_(true);
		self[\switch].action_({
			var mode = synth[\paramsModes][xParam[\symbol]];
			if(mode == \value)
			{ mode = \track }
			{ mode = \value };
			synth.setMode(
				xParam[\symbol],
				mode
			);
			synth.setMode(
				yParam[\symbol],
				mode
			);
		});

		// /!\ This could be optimized, for now
		// uiFunc is triggered twice every time

		// UI Func setup
		self[\uiFunc] = {
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

			self[\mode] = synth[\paramsModes][xParam[\symbol]];

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
				self[\slider].values_([
					synth[\params][xParam[\symbol]],
					synth[\params][yParam[\symbol]]
				]);
				self[\beatDisplay].string_("-");
			} {
				self[\slider].values_([
					synth[\track]
					[self[\currentBeat]][xParam[\symbol]],
					synth[\track]
					[self[\currentBeat]][yParam[\symbol]]
				]);
				self[\beatDisplay].string_(
					self[\currentBeat].asString);
			};
		};
	}

	{ \continuous } {
		// Cachez ce sein que je ne saurai voir
		self[\switchLayout].visible_(false);

		self[\slider]
		.action_({ |xValue, yValue|
			synth.setParam(xParam[\symbol], -1, xValue);
			synth.setParam(yParam[\symbol], -1, yValue);
		});

		// UI Func setup
		self[\uiFunc] = {
			self[\slider].values_([
				synth[\params][xParam[\symbol]],
				synth[\params][yParam[\symbol]]
			]);
		};
	}

	{ \input } {
		// Cachez ce sein que je ne saurai voir
		self[\switchLayout].visible_(false);
		self[\slider]
		.action_({ |xValue, yValue|
			synth.setParam(xParam[\symbol], -1, xValue);
			synth.setParam(yParam[\symbol], -1, yValue);
		});
		// UI Func setup
		self[\uiFunc] = {
			self[\slider].values_([
				synth[\params][xParam[\symbol]],
				synth[\params][yParam[\symbol]]
			]);
		};
	}

	{ \effect } {
		// Cachez ce sein que je ne saurai voir
		self[\switchLayout].visible_(false);

		self[\slider]
		.action_({ |xValue, yValue|
			synth.setParam(xParam[\symbol], -1, xValue);
			synth.setParam(yParam[\symbol], -1, yValue);
		});
		// UI Func setup
		self[\uiFunc] = {
			self[\slider].values_([
				synth[\params][xParam[\symbol]],
				synth[\params][yParam[\symbol]]
			]);
		};
	};
	
	// Synchronize UI
	synth.addUINotification(
		xParam[\symbol],
		self[\uiFunc]
	);
	synth.addUINotification(
		yParam[\symbol],
		self[\uiFunc]
	);

	self[\uiFunc].value;
},

// This is the continuation of initParent
init: { |self|
	var dummyView = UserView();
	self.hideTitle;

	self[\xTitle] = GMTextView()
	.orientation_(\top)
	.displayFrame_(true);
	self[\yTitle] = GMTextView()
	.displayFrame_(true);
	self[\slider] = GMSymbol2DSlider();
	self[\slider].onResize_({
		self[\xTitle].maxWidth_(self[\yTitle].bounds.height);
		dummyView.maxWidth_(self[\yTitle].bounds.height);
	});

	self[\type] = \slider2;

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
},
).parent_(~gmDef[\paramViewParent])