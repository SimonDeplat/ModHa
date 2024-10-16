(
setWindow: { |self, window|
	self[\window] = window;
},

setPlayer: { |self, player|
	self[\player] = player;
	// This will disconnect current player if needed,
	// connect new player signals
	// and update displayed datas
	self[\widgets].do({ |w| w.setPlayer(player); });
	// Save / Save As / Load
	self[\saveLoadButtons].setSaveFunction({
		if(self[\window].notNil) {
			if(self[\player].notNil) {
				if(self[\player][\currentFileName].notNil) {
					self[\player].save;
				} {
					self[\window].callTextInput(
						{ |dataName| self[\player].saveAs(dataName) },
						"Select a name :",
						"Ok"
					); }; }; }; });
	self[\saveLoadButtons].setSaveAsFunction({
		if(self[\window].notNil) {
			if(self[\player].notNil) {
				self[\window].callTextInput(
					{ |dataName| self[\player].saveAs(dataName) },
					"Select a name :",
					"Ok"
				); }; }; });
	self[\saveLoadButtons].setLoadFunction({
		if(self[\window].notNil) {
			if(self[\player].notNil) {
				self[\window].callLoader(
					\playerState,
					nil,
					{ |file, dataName| self[\player].load(file, dataName); },
					"Select a preset to load :",
				); }; }; });
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].background_(style.backColor);
	self[\widgets].do({ |w|
		w.setStyles(style, textStyle, widgetStyle); });
	self[\recordButton].style_(style);
	self[\saveLoadButtons].setStyles(style, textStyle, widgetStyle);
},

doRemove: { |self|
	self[\widgets].do({ |w| w.doRemove; });
	self[\saveLoadButtons].doRemove;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

init: { |self|
	self[\player] = nil;
	self[\view] = UserView();
	self[\window] = nil;
	self[\playButton] = ~gmDef.getPlayButton;
	self[\maxCycleSelector] = ~gmDef.getMaxCycleSelector;
	self[\tempoSelector] = ~gmDef.getTempoSelector;
	self[\rythmSelector] = ~gmDef.getRythmSelector;
	self[\freqSelector] = ~gmDef.getFreqSelector;
	self[\scaleSelector] = ~gmDef.getScaleSelector;
	self[\saveLoadButtons] = ~gmDef.getSaveLoadButtons;
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
	// Layout
	self[\view].layout_(
		VLayout()
		.spacing_(15)
		.add(
			HLayout()
			.add(self[\playButton][\view], 1)
			.add(self[\recordButton], 1)
			.add(self[\saveLoadButtons][\view], 3),
			1
		)
		.add(self[\maxCycleSelector][\view], 1)
		.add(self[\tempoSelector][\view], 2)
		.add(self[\rythmSelector][\view], 2)
		.add(self[\freqSelector][\view], 2)
		.add(self[\scaleSelector][\view], 1)
	);
	// WIP, closing view shouldn't remove player implicitely, need to think about it
	//self[\view].onClose_({ player.doRemove; });
	self
},
)