(
setStyles: { |self, style, smallStyle|
	self[\switch].style_(smallStyle);
	self[\hideButton].style_(smallStyle);
	self[\zoomButton].style_(smallStyle);
	self[\title].style_(smallStyle);
	self[\slider].style_(style);
	self[\multiSlider].style_(style);
},

zoom: { |self|
	self[\hideButton].visible_(false);
	self[\multiSlider].displayValues_(true);
	self[\zoomButton]
	.svg_(~gmDef.getIcon(\zoomIn))
	.action_({ self.dezoom; });
	self[\manager].zoom(self);
},

dezoom: { |self|
	self[\hideButton].visible_(true);
	self[\multiSlider].displayValues_(false);
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

setBeat: { |self, beat|
	self[\multiSlider].beat_(beat);
},

setHighlights: { |self, highlights|
	self[\multiSlider].highlights_(highlights);
},

configureSlider: { |self, slider, param|
	slider.min_(param[\min]);
	slider.max_(param[\max]);
	slider.scale_(param[\scale]);
	if(param.includesKey(\polarity))
	{ slider.polarity_(param[\polarity]); };
	if(param.includesKey(\helpersNumber))
	{ slider.helpersNumber_(param[\helpersNumber]); };
	if(param.includesKey(\helpersSubdivisons))
	{ slider.helpersSubdivisions_(param[\helpersSubdivisons]); };
	if(param.includesKey(\helpersStyle))
	{ slider.helpersStyle_(param[\helpersStyle]); };
	if(param.includesKey(\displayFunction))
	{ slider.displayFunction_(param[\displayFunction]); }
	{ slider.displayFunction_(nil); };
},

// This is the continuation of parents 'setSynthAndParam'
synthAndParam: { |self, synth, param|

	// Slider setup
	self[\slider]
	.action_({ |value|
		synth.setParam(param[\symbol], -1, value); });

	self.configureSlider(
		self[\slider],
		param
	);

	switch(synth[\type])

	{ \discrete } {
		// Show widgets
		self[\zoomButton].visible_(true);

		// Switch setup
		self[\switch].visible_(true);
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

		// MultiSlider setup
		self[\multiSlider]
		.action_({ |index, value|
			synth.setParam(param[\symbol], index, value); });
		self.configureSlider(
			self[\multiSlider],
			param
		);

		// UI Func setup
		self[\uiFunc] = {
			self[\slider].value_(
				synth[\params][param[\symbol]]; );
			self[\multiSlider].values_(
				Array.fill(
					synth[\track].size, { |i|
						synth[\track][i][param[\symbol]]; });
			);

			if(synth[\paramsModes][param[\symbol]] == \value) {
				self[\stackLayout].index_(0);
				self[\switch]
				.svg_(~gmDef.getIcon(\slider));
			} {
				self[\stackLayout].index_(1);
				self[\switch]
				.svg_(~gmDef.getIcon(\multiSlider));
			};
		};
	}

	{ \continuous } {
		// Hide unwanted widgets
		self[\switch].visible_(false);
		self[\zoomButton].visible_(false);
		self[\stackLayout].index_(0);

		// UI Func setup
		self[\uiFunc] = {
			self[\slider].value_(
				synth[\params][param[\symbol]]; );
		};
	}

	{ \input } {
		// Hide unwanted widgets
		self[\switch].visible_(false);
		self[\zoomButton].visible_(false);
		self[\stackLayout].index_(0);

		// UI Func setup
		self[\uiFunc] = {
			self[\slider].value_(
				synth[\params][param[\symbol]]; );
		};
	}

	{ \effect } {
		// Hide unwanted widgets
		self[\switch].visible_(false);
		self[\zoomButton].visible_(false);
		self[\stackLayout].index_(0);

		// UI Func setup
		self[\uiFunc] = {
			self[\slider].value_(
				synth[\params][param[\symbol]]; );
		};
	};

	// Synchronize UI
	synth.addUINotification(
		param[\symbol],
		self[\uiFunc]
	);

	self[\uiFunc].value;
},

// This is the continuation of parents 'initParent'
init: { |self|
	self[\stackLayout] = StackLayout();
	self[\slider] = GMFaderSlider();
	self[\multiSlider] = GMFaderMultiSlider()
	.displayHighlights_(true)
	.actionMode_(\index)
	.displayValues_(false);

	self[\type] = \continuous;

	self[\stackLayout].add(self[\slider]);
	self[\stackLayout].add(self[\multiSlider]);
	self[\paramContainer].layout_(self[\stackLayout]);

	self.addZoomButton;

	self[\switch] = GMButton();
	self.addMenuItem(self[\switch]);
},
).parent_(~gmDef[\paramViewParent])