(
setBeat: { |self, beat|
	[
		\continuousViews,
		\envViews,
		\selectorViews,
		\slider2Views,
	].do({ |symbol|
		self[symbol].do({ |view|
			if(view[\active])
			{ view.setBeat(beat); };
		});
	});
},

setHighlights: { |self, highlights|
	self[\continuousViews].do({ |view|
		view.setHighlights(highlights); });
},

displayBeat: { |self, beat|
	self[\displayedBeat] = beat;
	self[\envViews].do({ |view|
		view.displayBeat(beat); });
	self[\selectorViews].do({ |view|
		view.displayBeat(beat); });
	self[\slider2Views].do({ |view|
		view.displayBeat(beat); });
},

unhideAll: { |self|
	var widgets = List(0);
	self[\hiddenWidgets].do({ |widget, index|
		widgets.add(widget); });
	widgets.do({ |widget| widget.unhide(false); });
	widgets.clear;
	self[\hiddenWidgets].clear;
	self[\hiddenWidgets] = List(0);
},

setViewsActivity: { |self, rule|
	self[\continuousViews].do({ |view, index|
		if(index >= rule[\nContinuous])
		{ view.setInactive; };
	});
	self[\selectorViews].do({ |view, index|
		if(index >= rule[\nDiscrete])
		{ view.setInactive; };
	});
	self[\envViews].do({ |view, index|
		if(index >= rule[\nEnv])
		{ view.setInactive; };
	});
	self[\slider2Views].do({ |view, index|
		if(index >= rule[\nSlider2])
		{ view.setInactive; };
	});
},

// This will construct a dictionary to ease synth view
// reassignment
// and ensure the param manager
// has enough of each view (selector, env, etc)
// to display the synth,

adaptToSynth: { |self, synth, player|
	// /!\ for now paired params are only continuous,
	// so the algo is implicitely looking for those
	// param types only...
	var currentIndex =  0;
	var doneParams = List(0);
	var paramRule = (
		nContinuous: 0,
		nDiscrete: 0,
		nEnv: 0,
		nSlider2: 0,
		params: List(0),
	);

	synth[\data][\params]
	.do({ |param|
		switch(param[\type])

		{ \discrete } {
			paramRule[\params].add([
				\discrete,
				param,
				currentIndex
			]);
			currentIndex = currentIndex + 1;
			paramRule[\nDiscrete] = paramRule[\nDiscrete] + 1;
		}

		{ \env } {
			paramRule[\params].add([
				\env,
				param,
				currentIndex
			]);
			currentIndex = currentIndex + 1;
			paramRule[\nEnv] = paramRule[\nEnv] + 1;
		}

		{ \continuous } {
			if(doneParams.includes(param[\symbol]).not) {
				var hasPair = false;
				var pairedParam = nil;
				if(param.includesKey(\pair)) {
					synth[\data][\params].do({ |otherParam|
						if(otherParam[\symbol] == param[\pair]) {
							pairedParam = otherParam;
							hasPair = true;
						};
					});
				};

				if(hasPair) {
					var pair = [pairedParam, param];
					if(param[\axis] == \x)
					{ pair = [param, pairedParam]; };
					paramRule[\params].add([
						\slider2,
						pair,
						currentIndex
					]);
					paramRule[\nSlider2] = paramRule[\nSlider2] + 1;
					doneParams.add(param[\pair]);
				} {
					paramRule[\params].add([
						\continuous,
						param,
						currentIndex
					]);
					paramRule[\nContinuous] = paramRule[\nContinuous] + 1;
				};
				currentIndex = currentIndex + 1;
			};
		};
	});

	while { (self[\continuousViews].size < paramRule[\nContinuous]) } {
		var view = ~gmDef.getContinuousView;
		self[\continuousViews].add(view);
		view[\synthView] = self[\synthView];
		view[\manager] = self;
		if(player.notNil)
		{ view.setHighlights(player[\highlights]); };
		if(self[\style].notNil)
		{ view.setStyles(self[\style], self[\smallStyle]); };
	};
	while { (self[\slider2Views].size < paramRule[\nSlider2]) } {
		var view = ~gmDef.getSlider2View;
		self[\slider2Views].add(view);
		view[\synthView] = self[\synthView];
		view[\manager] = self;
		if(self[\style].notNil)
		{ view.setStyles(self[\style], self[\smallStyle]); };
	};
	while { (self[\selectorViews].size < paramRule[\nDiscrete]) } {
		var view = ~gmDef.getSelectorView;
		self[\selectorViews].add(view);
		view[\synthView] = self[\synthView];
		view[\manager] = self;
		if(self[\player].notNil)
		{ view.setPlayer(self[\player]); };
		if(self[\style].notNil)
		{ view.setStyles(self[\style], self[\smallStyle]); };
	};
	while { (self[\envViews].size < paramRule[\nEnv]) } {
		var view = ~gmDef.getEnvView;
		self[\envViews].add(view);
		view[\synthView] = self[\synthView];
		view[\manager] = self;
		if(self[\player].notNil)
		{ view.setPlayer(self[\player]); };
		if(self[\style].notNil)
		{ view.setStyles(self[\style], self[\smallStyle]); };
	};

	self[\synthView].setParamRule(synth, paramRule);

	// Clear collections
	doneParams.clear;
	// Do not clear paramRule,
	// it is passed as a pointer
},

setSynth: { |self, synth|
	var continuousIndex = 0;
	var discreteIndex = 0;
	var envIndex = 0;
	var slider2Index = 0;

	// Fetch the param rule
	var paramRule = self[\synthView].getParamRule(synth);

	// Set unnecessary views as inactive:
	self.setViewsActivity(paramRule);

	// Reset views list
	self[\orderedViews].clear;

	// /!\ Should factorize this next block /!\
	// - but less readability ?

	// Iterate through params to setup adequate views
	paramRule[\params].do({ |rule|
		switch(rule[0])

		{ \continuous } {
			self[\continuousViews][continuousIndex]
			.setSynthAndParam(
				synth,
				rule[1],
				rule[2]
			);
			self[\orderedViews].add(
				self[\continuousViews][continuousIndex]);

			// Hide view if it was previously hidden
			if(self[\hiddenViews].includes(rule[1][\symbol])) {
				// Erase duplicata
				self[\hiddenViews].remove(rule[1][\symbol]);
				self[\continuousViews][continuousIndex].hide(false);
			};

			continuousIndex = continuousIndex + 1;
		}

		{ \discrete } {
			self[\selectorViews][discreteIndex]
			.setSynthAndParam(
				synth,
				rule[1],
				rule[2]
			);
			self[\orderedViews].add(
				self[\selectorViews][discreteIndex]);

			// Hide view if it was previously hidden
			if(self[\hiddenViews].includes(rule[1][\symbol])) {
				// Erase duplicata
				self[\hiddenViews].remove(rule[1][\symbol]);
				self[\selectorViews][discreteIndex].hide(false);
			};

			discreteIndex = discreteIndex + 1;
		}

		{ \env } {
			self[\envViews][envIndex]
			.setSynthAndParam(
				synth,
				rule[1],
				rule[2]
			);
			self[\orderedViews].add(
				self[\envViews][envIndex]);

			// Hide view if it was previously hidden
			if(self[\hiddenViews].includes(rule[1][\symbol])) {
				// Erase duplicata
				self[\hiddenViews].remove(rule[1][\symbol]);
				self[\envViews][envIndex].hide(false);
			};

			envIndex = envIndex + 1;
		}

		{ \slider2 } {
			self[\slider2Views][slider2Index]
			.setSynthAndParams(
				synth,
				rule[1][0],
				rule[1][1],
				rule[2]
			);
			self[\orderedViews].add(
				self[\slider2Views][slider2Index]);

			// Hide view if it was previously hidden
			if(self[\hiddenViews].includes(rule[1][0][\symbol])) {
				// Erase duplicata
				self[\hiddenViews].remove(rule[1][0][\symbol]);
				self[\slider2Views][slider2Index].hide(false);
			};

			slider2Index = slider2Index + 1;
		};
	});

	// Update layout
	self.updateLayout;
},

zoom: { |self, view|
	self[\zoomView].layout.destroy;
	self[\zoomView].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(view[\view]);
	);
	self[\stackLayout].index_(1);
	self[\synthView].setZoomState(view);
},

dezoom: { |self|
	self[\stackLayout].index_(0);
	self[\synthView].setZoomState(nil);
},

// /!\ FIX ME: Rework this to be triggered
// by synth's \nBeats uiFunc
notifyOutOfBounds: { |self|
	self[\synthView].notifyOutOfBounds;
},

setPlayer: { |self, player|
	self[\player] = player;
	self[\envViews].do({ |view|
		view.setPlayer(player); });
	self[\selectorViews].do({ |view|
		view.setPlayer(player); });
	self[\slider2Views].do({ |view|
		view.setPlayer(player); });
},

// Allows communication between envViews and synthView
setTimeScale: { |self, symbol, timeScale|
	self[\synthView].setTimeScale(symbol, timeScale);
},
getTimeScale: { |self, symbol|
	self[\synthView].getTimeScale(symbol)
},

updateLayout: { |self|
	self.autoLayout(9);
},

autoLayout: { |self, prefStretch = 9|
	var currentIndex = 0;
	var views = List(0);
	var stretches = List(0);
	var nLayouts = 0;
	var targetStretch;
	var currentStretch = 0;
	var layouts = List(0);
	var currentLayout = 0;
	var layout =
	VLayout()
	.margins_(0)
	.spacing_(4);

	self[\orderedViews].do({ |view|
		if(view[\hidden].not) {
			views.add(view);
			view[\index] = currentIndex;
			currentIndex = currentIndex + 1;

			switch(view[\type])

			{ \continuous } {
				if(self[\synthView][\synth][\type] == \discrete)
				{ stretches.add(3); }
				{ stretches.add(1); };
			}

			{ \selector } {
				stretches.add(1);
			}

			{ \env } {
				stretches.add(3);
			}

			{ \slider2 } {
				stretches.add(3);
			}
		};
	});

	currentIndex = 0;

	nLayouts = stretches.sum / prefStretch;

	if((nLayouts%1) < 0.5)
	{ nLayouts = nLayouts.trunc(1.0).asInteger; }
	{ nLayouts = nLayouts.roundUp.asInteger; };
	nLayouts = max(
		nLayouts,
		1
	);

	nLayouts.do({ |index|
		var subLayout = HLayout()
		.margins_(0)
		.spacing_(0);
		layouts.add(subLayout);
		layout.add(subLayout);
	});

	targetStretch = stretches.sum / nLayouts;
	targetStretch = targetStretch.roundUp;

	// Distribution inside layout could be optimized
	// to distribute stretches more evenly,
	// but this will do for now

	stretches.do({ |stretch, index|
		layouts[currentLayout].add(
			views[index][\view],
			stretch
		);
		views[index][\layout] = layouts[currentLayout];
		views[index][\layoutIndex] = currentIndex;

		currentStretch = currentStretch + stretch;

		if(currentStretch >= targetStretch) {
			currentLayout = currentLayout + 1;
			currentIndex = 0;
			currentStretch = currentStretch - targetStretch;
		} {
			currentIndex = currentIndex + 1;
		};
	});

	self[\paramView].layout.destroy;
	self[\paramView].layout_(layout);

	stretches.clear;
	views.clear;
},

setStyles: { |self, style, smallStyle|
	self[\style] = style;
	self[\smallStyle] = smallStyle;
	self[\continuousViews].do({ |view|
		view.setStyles(style, smallStyle); });
	self[\selectorViews].do({ |view|
		view.setStyles(style, smallStyle); });
	self[\envViews].do({ |view|
		view.setStyles(style, smallStyle); });
	self[\slider2Views].do({ |view|
		view.setStyles(style, smallStyle); });
},

init: { |self|
	self[\view] = UserView()
	.acceptsMouseOver_(true);
	self[\stackLayout] = UserView();
	self[\paramView] = UserView()
	.acceptsMouseOver_(true)
	.layout_(HLayout());
	self[\zoomView] = UserView()
	.layout_(HLayout());
	self[\continuousViews] = List(0);
	self[\selectorViews] = List(0);
	self[\envViews] = List(0);
	self[\slider2Views] = List(0);
	self[\hiddenWidgets] =  List(0);
	self[\displayedBeat] = -1;
	self[\orderedViews] = List(0);
	self[\player] = nil;
	self[\style] = nil;
	self[\smallStyle] = nil;

	self[\stackLayout] = StackLayout();
	self[\stackLayout].add(self[\paramView]);
	self[\stackLayout].add(self[\zoomView]);

	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\stackLayout], 1)
	);
},
)