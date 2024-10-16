(
setWindow: { |self, window| self[\window] = window; },

setPlayer: { |self, player|
	self[\player] = player;
	// This will disconnect current player if needed,
	// connect new player signals
	// and update displayed datas
	self[\widgets].do({ |w| w.setPlayer(player); });
},

setStyles: { |self, style, textStyle|
	self[\view].background_(style.backColor);
	self[\widgets].do({ |w|
		w.setStyles(style, textStyle); });
	self[\recordButton].style_(style);
},

doRemove: { |self|
	self[\widgets].do({ |w| w.doRemove; });
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	var saveButton, saveAsButton, loadButton;

	self[\player] = nil;
	self[\view] = UserView();
	self[\window] = nil;
	self[\playButton] = ~gmDef.getPlayButton;
	self[\maxCycleSelector] = ~gmDef.getMaxCycleSelector;
	self[\tempoSelector] = ~gmDef.getTempoSelector;
	self[\rythmSelector] = ~gmDef.getRythmSelector;
	self[\freqSelector] = ~gmDef.getFreqSelector;
	self[\scaleSelector] = ~gmDef.getScaleSelector;
	// Allows to control every widgets at once,
	// exploiting polymorphism:
	self[\widgets] = [
		self[\playButton],
		self[\maxCycleSelector],
		self[\tempoSelector],
		self[\rythmSelector],
		self[\freqSelector],
		self[\scaleSelector],
	];
	// Record button stays independant for now
	self[\recordButton] = GMRecordButton()
	.maxWidth_(192);

	// SAVE WIDGETS: WORKING BUT UGLY
	// -> whole block needs to be an independant class
	saveButton = GMFeedbackButton()
	.svg_(~gmDef.getIcon(\save))
	.maxWidth_(96)
	.action_({
		if(self[\window].notNil) {
			if(self[\player].notNil) {
				if(self[\player][\currentFileName].notNil) {
					self[\player].save;
				} {
					self[\window].callTextInput(
						{ |dataName| self[\player].saveAs(dataName) },
						"Select a name :",
						"Ok"
					);
				};
			};
		};
	});

	saveAsButton = GMButton()
	.svg_(~gmDef.getIcon(\saveAs))
	.maxWidth_(96)
	.action_({
		if(self[\window].notNil) {
			if(self[\player].notNil) {
				self[\window].callTextInput(
					{ |dataName| self[\player].saveAs(dataName) },
					"Select a name :",
					"Ok"
				);
			};
		};
	});

	loadButton = GMButton()
	.svg_(~gmDef.getIcon(\load))
	.maxWidth_(96)
	.action_({
		if(self[\window].notNil) {
			if(self[\player].notNil) {
				self[\window].callLoader(
					\playerState,
					nil,
					{ |file, dataName| self[\player].load(file, dataName); },
					"Select a preset to load :",
				);
			};
		};
	});

	// WIP, view shouldn't remove player implicitely,
	// needs to think about it
	//self[\view].onClose_({ player.doRemove; });

	// Layout
	self[\view].layout_(
		VLayout()
		.spacing_(15)
		.add(
			HLayout()
			.add(self[\playButton][\view], 1)
			.add(self[\recordButton], 1)
			.add(
				HLayout()
				.spacing_(0)
				.margins_(0)
				.add(saveButton)
				.add(saveAsButton)
				.add(loadButton),
				3
			),
			1
		)
		.add(self[\maxCycleSelector][\view], 1)
		.add(self[\tempoSelector][\view], 2)
		.add(self[\rythmSelector][\view], 2)
		.add(self[\freqSelector][\view], 2)
		.add(self[\scaleSelector][\view], 1)
	);
	self
},
)