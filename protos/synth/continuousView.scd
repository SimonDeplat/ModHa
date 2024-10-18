(
// This is the continuation of parent's 'setSynthAndParam'
synthAndParam: { |self, synth, param|
	// Reset current connection
	self.disconnectSynth;
	self[\synth] = synth;
	self[\param] = param;

	switch(synth[\type])

	{ \discrete } {
		// Sliders setup
		self.configureSlider(self[\slider], param);
		self[\slider].action_({ |value|
			synth.setParam(param[\symbol], -1, value); });
		self.configureSlider(self[\multiSlider], param);
		self[\multiSlider].action_({ |index, value|
			synth.setParam(param[\symbol], index, value); });
		// Signal function
		self[\paramFunc] = {
			self[\slider].value_(synth[\params][param[\symbol]]; );
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
		// Show/hide widgets
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
	}

	{ \continuous } {
		// Slider setup
		self.configureSlider(self[\slider], param);
		self[\slider].action_({ |value|
			synth.setParam(param[\symbol], -1, value); });
		// Signal function
		self[\paramFunc] = {
			self[\slider].value_(synth[\params][param[\symbol]]; );
		};
		// Show/hide widgets
		self[\switch].visible_(false);
		self[\zoomButton].visible_(false);
		self[\stackLayout].index_(0);
	}

	{ \input } {
		// Slider setup
		self.configureSlider(self[\slider], param);
		self[\slider].action_({ |value|
			synth.setParam(param[\symbol], -1, value); });
		// Signal function
		self[\paramFunc] = {
			self[\slider].value_(synth[\params][param[\symbol]]; );
		};
		// Show/hide widgets
		self[\switch].visible_(false);
		self[\zoomButton].visible_(false);
		self[\stackLayout].index_(0);
	}

	{ \effect } {
		// Slider setup
		self.configureSlider(self[\slider], param);
		self[\slider].action_({ |value|
			synth.setParam(param[\symbol], -1, value); });
		// Signal function
		self[\paramFunc] = {
			self[\slider].value_(synth[\params][param[\symbol]]; );
		};
		// Show/hide widgets
		self[\switch].visible_(false);
		self[\zoomButton].visible_(false);
		self[\stackLayout].index_(0);
	};

	synth.addSignal(param[\symbol], self[\paramFunc]);
	self[\paramFunc].value;
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(self[\param][\symbol], self[\paramFunc]);
		self[\synth] = nil;
		self[\param] = nil;
		self[\slider].action_({});
		self[\multiSlider].action_({});
	};
},

setPlayer: { |self, player|
	self.disconnectPlayer;
	self[\player] = player;
	self[\beatFunc] = {
		var beat = 0;
		var trackSize = 8;
		if(self[\synth].notNil)
		{ trackSize = self[\synth][\track].size; };
		beat = player[\actualBeat]%trackSize;
		self[\multiSlider].beat_(beat);
	};
	self[\highlightsFunc] = {
		self[\multiSlider].highlights_(player[\highlights]);
	};
	self[\beatFunc].value;
	self[\highlightsFunc].value;
	self[\player].addSignal(\beat, self[\beatFunc]);
	self[\player].addSignal(\highlights, self[\highlightsFunc]);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\beat, self[\beatFunc]);
		self[\player].rmSignal(\highlight, self[\highlightsFunc]);
		self[\player] = nil;
		self[\beatFunc] = nil;
		self[\highlightsFunc] = nil;
	};
},

setStyles: { |self, style, smallStyle, widgetStyle|
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

init: { |self|
	// Init paramViewParent
	self.initParent;
	// Variables
	self[\type] = \continuous;
	self[\param] = nil;
	self[\synth] = nil;
	self[\player] = nil;
	// Views
	self[\stackLayout] = StackLayout();
	self[\slider] = GMFaderSlider();
	self[\multiSlider] = GMFaderMultiSlider()
	.displayHighlights_(true)
	.actionMode_(\index)
	.displayValues_(false);
	self[\stackLayout].add(self[\slider]);
	self[\stackLayout].add(self[\multiSlider]);
	self[\paramContainer].layout_(self[\stackLayout]);
	self.addZoomButton;
	self[\switch] = GMButton();
	self.addMenuItem(self[\switch]);
	self
},
).parent_(~gmDef[\paramViewParent])