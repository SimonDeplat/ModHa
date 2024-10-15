(
setWindow: { |self, window| self[\window] = window; },

setPlayer: { |self, player|
	if(self[\player].isNil) {
		// WIP: need to implement signals
		// Store signal functions within variables
		// and execute them instead of emitting signal,
		// which is lazy and inappropriate
		self[\player] = player;

		// DIAPASON
		player.addSignal(
			\diapason, {
				self[\freqSlider]
				.min_(player[\diapason])
				.max_(player[\diapason] * 2);
			};
		);
		player.emitSignal(\diapason);

		// FREQ
		self[\freqSlider].action_({ |value|
			player.setFreq(value);
		});
		self[\freqSelector].action_({ |index|
			player.setFreq(
				((Scale.at(\chromatic).ratios ++ [2]) * player[\diapason])[index]
			);
		});
		player.addSignal(
			\freq, {
				var selectorIndex = -1;
				self[\freqSlider].value_(player[\freq]);
				((Scale.at(\chromatic).ratios ++ [2]) * player[\diapason])
				.do({ |note, index|
					if(note.asInteger == player[\freq].asInteger)
					{ selectorIndex = index; };
				});
				if(selectorIndex > -1)
				{ self[\freqSelector].state_(selectorIndex); }
				{ self[\freqSelector].desindex; };
			};
		);
		player.emitSignal(\freq);

		// SCALE
		self[\scaleSelector].action_({ |index|
			player.setScale(
				[
					\minor, \ionian, \major, \dorian,
					\phrygian, \lydian, \mixolydian
				][index]
			);
		});
		player.addSignal(
			\scale, {
				var detectIndex = [
					\minor, \ionian, \major, \dorian,
					\phrygian, \lydian, \mixolydian
				].indexOfEqual(player[\scale]);
				if(detectIndex.isNil)
				{ self[\scaleSelector].desindex }
				{ self[\scaleSelector].state_(detectIndex); };
			};
		);
		player.emitSignal(\scale);

		// TEMPO
		self[\tempoSlider].action_({ |value|
			player.setTempo(value.asInteger);
		});
		self[\tempoSelector].action_({ |index|
			player.setTempo(
				[
					40, 60, 80 , 100,
					120, 140, 160
				][index]
			);
		});
		player.addSignal(
			\tempo, {
				var selectorIndex = -1;
				self[\tempoSlider].value_(player[\tempo]);
				[
					40, 60, 80 , 100,
					120, 140, 160
				].do({ |tempo, index|
					if(tempo == player[\tempo])
					{ selectorIndex = index; };
				});
				if(selectorIndex > -1)
				{ self[\tempoSelector].state_(selectorIndex); }
				{ self[\tempoSelector].desindex; };
			};
		);
		player.emitSignal(\tempo);

		// RYTHM
		self[\divSelector].action_({ |index|
			player.setRythm([
				[
					1, 2, 3, 4,
					5, 6, 7, 8
				][index],
				player[\rythm][1]
			]);
		});
		self[\subdivSelector].action_({ |index|
			player.setRythm([
				player[\rythm][0],
				[
					1, 2, 3, 4,
					5, 6, 7, 8
				][index]
			]);
		});
		player.addSignal(
			\rythm, {
				var detectIndex;
				detectIndex = [
					1, 2, 3, 4,
					5, 6, 7, 8
				].indexOfEqual(player[\rythm][0]);
				if(detectIndex.isNil)
				{ self[\divSelector].desindex; }
				{ self[\divSelector].state_(detectIndex); };
				detectIndex = [
					1, 2, 3, 4,
					5, 6, 7, 8
				].indexOfEqual(player[\rythm][1]);
				if(detectIndex.isNil)
				{ self[\subdivSelector].desindex; }
				{ self[\subdivSelector].state_(detectIndex); };
			};
		);
		player.emitSignal(\rythm);

		// ROUTINE
		self[\maxCycleSelector].action_({ |index|
			player.setMaxCycle([1, 2, 4, 8, 16, inf][index]);
		});
		player.addSignal(
			\rythm, {
				var detectIndex = [1, 2, 4, 8, 16, inf].indexOfEqual(player[\maxCycle]);
				if(detectIndex.isNil)
				{ self[\maxCycleSelector].desindex; }
				{ self[\maxCycleSelector].state_(detectIndex); };
			};
		);
		player.emitSignal(\maxCycle);

		self[\playButton]
		.action_({ |isPlaying|
			if(isPlaying)
			{ player.doPlay; }
			{ player.doStop; };
		});
	} {
		"ModHa: playerView: player reassignment unsupported yet".warn;
	};
},

init: { |self|
	// Variables
	var saveButton, saveAsButton, loadButton;

	self[\player] = nil;
	
	self[\view] = UserView();

	self[\window] = nil;

	self[\style] = GMStyle();
	self[\smallStyle] = self[\style]
	.deepCopy
	.borderSize_(1)
	.secondBorderSize_(2)
	.thirdBorderSize_(0);

	self[\playButton] = GMPlayButton()
	.maxWidth_(192);
	
	self[\recordButton] = GMRecordButton()
	.maxWidth_(192);

	self[\maxCycleSelector] = GMMultiButton()
	.states_(["1", "2", "4", "8", "16", "inf"])
	.state_(5);

	self[\freqSlider] = GMSymbolSlider()
	.scale_(\exp)
	.orientation_(\horizontal)
	.fontRatio_(0.7);
	
	self[\freqSelector] = GMMultiButton()
	.fontRatio_(0.5)
	.states_([
		"A", "Bb", "B", "C", "Db", "D",
		"Eb", "E", "F", "F#", "G", "Ab", "A"
	]);

	self[\scaleSelector] = GMMultiButton()
	.fontRatio_(0.5)
	.states_([
		"Minor", "Locrian", "Major", "Dorian",
		"Phrygian", "Lydian", "Mixolydian"
	]);

	self[\tempoSlider] = GMSymbolSlider()
	.min_(20)
	.max_(200)
	.orientation_(\horizontal)
	.fontRatio_(0.5)
	.displayFunction_({ |value| value.asInteger });

	self[\tempoSelector] = GMMultiButton()
	.fontRatio_(0.5)
	.states_([
		"40", "60", "80", "100",
		"120", "140", "160"
	]);

	self[\divSelector] = GMMultiButton()
	.states_([
		"1", "2", "3", "4",
		"5", "6", "7", "8"]);

	self[\subdivSelector] = GMMultiButton()
	.states_([
		"1", "2", "3", "4",
		"5", "6", "7", "8"]);

	// SAVE WIDGETS: WORKING BUT UGLY
	saveButton = GMFeedbackButton()
	.style_(~gmDef[\defaultProperties][\textStyle])
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
	.style_(~gmDef[\defaultProperties][\textStyle])
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
	.style_(~gmDef[\defaultProperties][\textStyle])
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

	// Init

	// WIP, view shouldn't remove player implicitely
	//self[\view].onClose_({ player.doRemove; });

	// Layout
	self[\view].layout_(
		VLayout()
		.spacing_(15)
		.add(
			HLayout()
			.add(self[\playButton])
			.add(self[\recordButton])

			.add(
				HLayout()
				.spacing_(0)
				.margins_(0)
				.add(saveButton)
				.add(saveAsButton)
				.add(loadButton)
			),
			1
		)

		.add(
			HLayout()
			.spacing_(0)
			.margins_(0)
			.add(
				GMTextView()
				.displayFrame_(true)
				.style_(
					~gmDef[\defaultProperties][\textStyle])
				.string_("Cycles")
				.fontRatio_(0.25)
				.maxWidth_(192),
				1
			)
			.add(self[\maxCycleSelector], 9),
			1
		)

		.add(
			HLayout()
			.spacing_(0)
			.margins_(0)
			.add(
				GMTextView()
				.displayFrame_(true)
				.style_(
					~gmDef[\defaultProperties][\textStyle])
				.string_("BPM :")
				.fontRatio_(0.125)
				.maxWidth_(192),
				1
			)
			.add(
				VLayout()
				.spacing_(0)
				.margins_(0)
				.add(self[\tempoSlider])
				.add(self[\tempoSelector]),
				9
			),
			2
		)

		.add(
			HLayout()
			.spacing_(0)
			.margins_(0)
			.add(
				GMTextView()
				.displayFrame_(true)
				.style_(
					~gmDef[\defaultProperties][\textStyle])
				.string_("Rythm :")
				.fontRatio_(0.125)
				.maxWidth_(192),
				1
			)
			.add(
				VLayout()
				.add(self[\divSelector])
				.add(self[\subdivSelector]),
				9
			),
			2
		)

		.add(
			HLayout()
			.spacing_(0)
			.margins_(0)
			.add(
				GMTextView()
				.displayFrame_(true)
				.style_(
					~gmDef[\defaultProperties][\textStyle])
				.string_("Freq :")
				.fontRatio_(0.125)
				.maxWidth_(192),
				1
			)
			.add(
				VLayout()
				.spacing_(0)
				.margins_(0)
				.add(self[\freqSlider])
				.add(self[\freqSelector]),
				9
			),
			2
		)

		.add(
			HLayout()
			.spacing_(0)
			.margins_(0)
			.add(
				GMTextView()
				.displayFrame_(true)
				.style_(
					~gmDef[\defaultProperties][\textStyle])
				.string_("Scale :")
				.fontRatio_(0.25)
				.maxWidth_(192),
				1
			)
			.add(self[\scaleSelector], 9),
			1
		)
	);

	self[\view].background_(
		~gmDef[\defaultProperties][\style].backColor);

	self
},
)