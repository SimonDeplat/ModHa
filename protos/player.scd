(
var getPlayer = { |decoder|
	var saveButton, saveAsButton, loadButton;

	var player = (
		view: UserView(),
		clock: TempoClock(),
		routine: nil,
		isPlaying: false,
		doPlay: { |self|
			self[\routine] = Routine({
				var actualTime = 0;

				self[\currentBeat] = 0;
				self[\currentCycle] = 0;
				self[\isPlaying] = true;

				loop {
					// Play here
					if(self[\score].size > 0) {
						s.listSendBundle(
							s.latency,
							self[\score].deepCopy
						);
					};

					// Update views
					actualTime = self[\currentBeat];
					{
						if(self[\isPlaying]) {
							self[\synthViews].do({ |view|
								view.setBeat(actualTime); });
						};
					}.defer(s.latency);

					// FIX SPECIAL CASE WHEN CHANGING RYTHM
					// ON LAST TIME ?
					// Update 'current' time
					self[\currentBeat] = self[\currentBeat] + 1;
					if(self[\currentBeat] == self[\nBeats]) {
						self[\currentBeat] = 0;
						self[\currentCycle] = self[\currentCycle] + 1;
						// Stop if max cycle reached
						if(self[\currentCycle] >= self[\maxCycle])
						{ self.doStop(false); };
					};
					// Fetch next score
					self.fetchScore;

					(1 / self[\rythm][1]).wait;

				};
			}).play(self[\clock]);
		},
		doStop: { |self, manual = true|
			if(self[\isPlaying]) {

				// Mute continuous synths
				if(self[\muteContinuous]) {
					self[\continuousSynths].do({ |synth|
						if(synth[\hasAmpParam])
						{ synth.setMuted(true); };
					});
				};

				self[\isPlaying] = false;
				self[\score].clear;
				self[\currentBeat] = 0;
				self[\currentCycle] = 0;
				// Fetch starting score
				self.fetchScore;
				// Update views
				self[\synthViews].do({ |view|
					view.setBeat(self[\currentBeat]); });

				if(manual.not)
				{ self[\playButton].toggleDisplay; };
				// Stopping routine needs to be last,
				// because if doStop is called from within it,
				// doStop evaluation will stop when the routine stops
				self[\routine].stop;
			};
		},
		currentBeat: 0,
		currentCycle: 0,
		maxCycle: inf,
		nBeats: 16,
		discreteSynths: List(0),
		continuousSynths: List(0),
		score: List(0),
		fetchScore: { |self|
			self[\score].clear;
			self[\discreteSynths].do({ |synth|
				var notes = synth.getScoreAt(self[\currentBeat]);
				if(notes.notNil) {
					notes.do({ |note|
						self[\score].add(note);
					});
				};
			});
		},
		notifyMsgChange: { |self, oldMsgs, newMsgs|
			if(oldMsgs.notNil) {
				oldMsgs.do({ |msg|
					self[\score].removeAt(
						self[\score].indexOfEqual(msg);
					);
				});
			};

			if(newMsgs.notNil) {
				newMsgs.do({ |msg|
					self[\score].add(msg);
				});
			};
		},

		// BUTTONS
		playButton: GMPlayButton()
		.maxWidth_(192)
		.action_({ |isPlaying|
			if(isPlaying)
			{ player.doPlay; }
			{ player.doStop; };
		}),
		recordButton: GMRecordButton()
		.maxWidth_(192),
		maxCyclesSelector: GMMultiButton()
		.states_(["1", "2", "4", "8", "16", "inf"])
		.state_(5)
		.action_({ |index|
			player[\maxCycle] =
			[1, 2, 4, 8, 16, inf][index];
		}),

		// DIAPASON RELATED
		diapason: 440,
		setDiapason: { |self, freq|
			var ratio = freq / self[\diapason];
			self[\diapason] = freq;
			self.setFreq(self[\freq] * ratio);
			self[\chromaticNotes] =
			(Scale.at(\chromatic).ratios ++ [2]) * freq;
		},
		chromaticNotes: nil,

		// FREQ RELATED
		freq: 440,
		setFreq: { |self, freq|
			var selectorIndex = -1;

			// Update continuous synths
			self[\continuousSynths].do({ |synth|
				synth.setFreq(freq); });
			self[\effectSynths].do({ |synth|
				synth.setFreq(freq); });

			self[\freq] = freq;
			player.updateScale;
			self[\freqSlider].value_(freq);
			self[\chromaticNotes].do({ |note, index|
				if(note.asInteger == freq.asInteger)
				{ selectorIndex = index; };
			});
			if(selectorIndex > -1)
			{ self[\freqSelector].state_(selectorIndex); }
			{ self[\freqSelector].desindex; };
		},
		freqSlider: GMSymbolSlider()
		.scale_(\exp)
		.orientation_(\horizontal)
		.fontRatio_(0.7)
		.action_({ |value| player.setFreq(value); }),
		freqSelector: GMMultiButton()
		.fontRatio_(0.5)
		.states_([
			"A", "Bb", "B", "C", "Db", "D",
			"Eb", "E", "F", "F#", "G", "Ab", "A"
		])
		.action_({ |index|
			player.setFreq(player[\chromaticNotes][index]);
		}),

		// SCALE RELATED
		scale: \minor,
		scaleFreqs: nil,
		setScale: { |self, scaleSymbol|
			var detectIndex;
			self[\scale] = scaleSymbol;
			player.updateScale;
			detectIndex = [
				\minor, \ionian, \major, \dorian,
				\phrygian, \lydian, \mixolydian
			].indexOfEqual(scaleSymbol);
			if(detectIndex.isNil)
			{ self[\scaleSelector].desindex }
			{ self[\scaleSelector].state_(detectIndex); };
		},
		updateScale: { |self|
			self[\scaleFreqs] =
			Scale.at(self[\scale]).ratios * self[\freq];

			if(self[\isPlaying])
			{ self.fetchScore; };

			self.updateVHighlights;
		},
		scaleSelector: GMMultiButton()
		.fontRatio_(0.5)
		.states_([
			"Minor", "Locrian", "Major", "Dorian",
			"Phrygian", "Lydian", "Mixolydian"
		])
		.action_({ |index|
			player.setScale([
				\minor, \ionian, \major, \dorian,
				\phrygian, \lydian, \mixolydian][index]);
		}),
		getFreqAtIndex: { |self, index|
			var freqMul = 1;
			while { index > (self[\scaleFreqs].size - 1) } {
				index = index - self[\scaleFreqs].size;
				freqMul = freqMul * 2;
			};
			while { index < 0 } {
				index = index + self[\scaleFreqs].size;
				freqMul = freqMul / 2;
			};
			self[\scaleFreqs][index] * freqMul
		},

		// TEMPO RELATED
		tempo: 60,
		setTempo: { |self, tempo|
			var detectIndex;
			tempo = tempo.asInteger;
			// /!\ Tempo should be applied to every synth
			self[\effectSynths].do({ |synth|
				synth.setTempo(tempo); });
			self[\tempo] = tempo;
			self[\clock].tempo_(tempo / 60);
			self[\tempoSlider].value_(tempo);
			detectIndex = [
				40, 60, 80 , 100,
				120, 140, 160
			].indexOfEqual(tempo);
			if(detectIndex.isNil)
			{ self[\tempoSelector].desindex; }
			{ self[\tempoSelector].state_(detectIndex;) };
		},
		tempoSlider: GMSymbolSlider()
		.min_(20)
		.max_(200)
		.orientation_(\horizontal)
		.fontRatio_(0.5)
		.displayFunction_({ |value| value.asInteger })
		.action_({ |value| player.setTempo(value); }),
		tempoSelector: GMMultiButton()
		.fontRatio_(0.5)
		.states_([
			"40", "60", "80", "100",
			"120", "140", "160"
		])
		.action_({ |index|
			player.setTempo([
				40, 60, 80, 100,
				120, 140, 160][index]);
		}),

		// RYTHM RELATED
		rythm: [4, 4],
		setRythm: { |self, pair|
			var detectIndex;

			self[\rythm] = pair;
			self[\nBeats] = pair[0] * pair[1];
			if(self[\currentBeat] >= self[\nBeats]) {
				self[\currentBeat] = 0;
				if(self[\isPlaying])
				{ self.fetchScore; };
			};

			// Update views
			self[\discreteSynths].do({ |synth|
				synth.setMaxBeat(self[\nBeats]); });

			// Update both rythm selector states
			[\divSelector, \subdivSelector].do({ |symbol, index|
				detectIndex = [
					1, 2, 3, 4,
					5, 6, 7, 8
				].indexOfEqual(pair[index]);
				if(detectIndex.isNil)
				{ self[symbol].desindex; }
				{ self[symbol].state_(detectIndex); };
			});

			// Update highlights
			self.updateHighlights;
		},
		divSelector: GMMultiButton()
		.states_([
			"1", "2", "3", "4",
			"5", "6", "7", "8"])
		.action_({ |index|
			player.setRythm([
				[
					1, 2, 3, 4,
					5, 6, 7, 8
				][index],
				player[\rythm][1]
			]);
		}),
		subdivSelector: GMMultiButton()
		.states_([
			"1", "2", "3", "4",
			"5", "6", "7", "8"])
		.action_({ |index|
			player.setRythm([
				player[\rythm][0],
				[
					1, 2, 3, 4,
					5, 6, 7, 8
				][index]
			]);
		}),

		highlights: nil,
		updateHighlights: { |self|
			var highlights;
			var filler;

			switch(self[\rythm][1])
			{ 1 } { filler = []; }
			{ 2 } { filler = [0]; }
			{ 3 } { filler = [0, 0.333]; }
			{ 4 } { filler = [0, 0.333, 0]; }
			{ 5 } { filler = [0, 0, 0.333, 0]; }
			{ 6 } { filler = [0, 0.333, 0, 0.333, 0]; }
			{ 7 } { filler = [0, 0, 0, 0.333, 0, 0]; }
			{ 8 } { filler = [0, 0, 0, 0.333, 0, 0, 0]; };

			switch(self[\rythm][0])
			{ 1 } { highlights = [0.9] ++ filler; }
			{ 2 } {
				highlights =
				[0.9] ++ filler
				++ [0.666] ++ filler;
			}
			{ 3 } {
				highlights =
				[0.9] ++ filler
				++ [0.666] ++ filler
				++ [0.666] ++ filler;
			}
			{ 4 } {
				highlights =
				[0.9] ++ filler
				++ [0.5] ++ filler
				++ [0.75] ++ filler
				++ [0.5] ++ filler;
			}
			{ 5 } {
				highlights =
				[0.9] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler
				++ [0.75] ++ filler
				++ [0.5] ++ filler;
			}
			{ 6 } {
				highlights =
				[0.9] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler
				++ [0.75] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler;
			}
			{ 7 } {
				highlights =
				[0.9] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler
				++ [0.75] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler;
			}
			{ 8 } {
				highlights =
				[0.9] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler
				++ [0.75] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler
				++ [0.5] ++ filler;
			};

			self[\highlights] = highlights;
			self[\synthViews].do({ |view|
				view.setHighlights(highlights); });
		},
		vHighlights: [],
		updateVHighlights: { |self|
			if(self[\vHighlights].size
				!= self[\scaleFreqs].size) {
				switch(self[\scaleFreqs].size)
				{ 5 } {
					self[\vHighlights] = [
						0.666, 0, 0, 0.333, 0] }
				{ 7 } {
					self[\vHighlights] = [
						0.666, 0, 0.333, 0, 0.333, 0, 0] };
				self[\synthViews].do({ |view|
					view.setVHighlights(self[\vHighlights]); });
			};
		},

		// GROUPS AND MASTERS
		createGroups: { |self|
			self[\playerGroup] = Group.new(
				~gmDef[\server].defaultGroupID,
				\addToHead
			);
			self[\inputGroup] = Group.new(
				self[\playerGroup].nodeID,
				\addToTail
			);
			self[\discreteGroup] = Group.new(
				self[\playerGroup].nodeID,
				\addToTail
			);
			self[\continuousGroup] = Group.new(
				self[\playerGroup].nodeID,
				\addToTail
			);
			self[\effectGroup] = Group.new(
				self[\playerGroup].nodeID,
				\addToTail
			);
			self[\masterGroup] = Group.new(
				self[\playerGroup].nodeID,
				\addToTail
			);
		},
		masters: List(0),
		loadMasters: { |self|
			// Only supports stereo :
			var numOut =
			~gmDef[\server].options.numOutputBusChannels;
			numOut = numOut - (numOut % 2);
			numOut = numOut / 2;
			numOut = numOut.asInteger;
			numOut.do({ |index|
				var master = ~gmDef.getMaster;
				master.setOut(index * 2);
				master.setGroup(self[\masterGroup]);
				if(numOut > 1)
				{ master[\name] = "Master " ++ (index + 1); }
				{ master[\name] = "Master"; };
				self[\masters].add(master);
			});

			self[\defaultOut] = self[\masters][0];
		},

		// EFFECTS
		effects: List(0),
		addEffect: { |self, effect|
			self[\effects].add(effect);
		},

		// MISC
		muteContinuous: true,

		// PLAYER DATA
		currentFile: nil,
		currentDataName: nil,
		save: { |self|
			var file = File(
				self[\currentFileName].standardizePath, "w");

			var data = ();
			data[\name] = self[\currentDataName];
			data[\nBeats] = self[\nBeats];
			data[\diapason] = self[\diapason];
			data[\freq] = self[\freq];
			data[\scale] = self[\scale];
			data[\tempo] = self[\tempo];
			data[\rythm] = self[\rythm];

			file.write(data.asCompileString);
			file.close;
			data.clear;
		},
		saveAs: { |self, dataName|
			var fileName =
			decoder[\folder]
			++ "/presets/playerState/"
			++ dataName
			++ "_" ++ decoder.getUID
			++ ".gmdef_playerState";

			self[\currentFileName] = fileName;
			self[\currentDataName] = dataName;

			self.save;
		},
		load: { |self, file, dataName|
			var data = this.executeFile(file);

			self.setDiapason(data[\diapason]);
			self.setFreq(data[\freq]);
			self.setScale(data[\scale]);
			self.setTempo(data[\tempo]);
			self.setRythm(data[\rythm]);

			data.clear;
			if(self[\currentFileName] != file) {
				self[\currentFileName] = file;
				self[\currentDataName] = dataName;
			};
		},
		synthViews: List(0),

		doRemove: { |self|
			self[\masters].do({ |master|
				master.doRemove;
			});
		},
	);

	////////////////
	//    INIT    //
	////////////////

	player[\view].onClose_({
		player.doRemove;
	});

	// SYNTH RELATED
	player.createGroups;
	player.loadMasters;

	// FREQ INIT
	player[\freqSlider]
	.min_(player[\diapason])
	.max_(player[\diapason] * 2);

	// INITS
	player.setDiapason(440);
	player.setFreq(player[\freq]);
	player.setScale(player[\scale]);
	player.setTempo(player[\tempo]);
	player.setRythm(player[\rythm]);

	player.updateHighlights;
	player.updateVHighlights;

	player[\style] = GMStyle();

	player[\smallStyle] = player[\style]
	.deepCopy
	.borderSize_(1)
	.secondBorderSize_(2)
	.thirdBorderSize_(0);

	saveButton = GMFeedbackButton()
	.style_(decoder[\defaultProperties][\textStyle])
	.svg_(decoder.getIcon(\save))
	.maxWidth_(96)
	.action_({
		if(player[\currentFileName].notNil) {
			player.save;
		} {
			decoder.callTextInput(
				{ |dataName| player.saveAs(dataName) },
				"Select a name :"
			);
		};
	});

	saveAsButton = GMButton()
	.style_(decoder[\defaultProperties][\textStyle])
	.svg_(decoder.getIcon(\saveAs))
	.maxWidth_(96)
	.action_({
		decoder.callTextInput(
			{ |dataName| player.saveAs(dataName) },
			"Select a name :"
		);
	});

	loadButton = GMButton()
	.style_(decoder[\defaultProperties][\textStyle])
	.svg_(decoder.getIcon(\load))
	.maxWidth_(96)
	.action_({
		decoder.callLoader(
			\playerState,
			nil,
			{ |file, dataName| player.load(file, dataName); },
			"Select a preset to load :"
		);
	});

	// VIEW LAYOUT
	player[\view].layout_(
		VLayout()
		.spacing_(15)
		.add(
			HLayout()
			.add(player[\playButton])
			.add(player[\recordButton])

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
					decoder[\defaultProperties][\textStyle])
				.string_("Cycles")
				.fontRatio_(0.25)
				.maxWidth_(192),
				1
			)
			.add(player[\maxCyclesSelector], 9),
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
					decoder[\defaultProperties][\textStyle])
				.string_("BPM :")
				.fontRatio_(0.125)
				.maxWidth_(192),
				1
			)
			.add(
				VLayout()
				.spacing_(0)
				.margins_(0)
				.add(player[\tempoSlider])
				.add(player[\tempoSelector]),
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
					decoder[\defaultProperties][\textStyle])
				.string_("Rythm :")
				.fontRatio_(0.125)
				.maxWidth_(192),
				1
			)
			.add(
				VLayout()
				.add(player[\divSelector])
				.add(player[\subdivSelector]),
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
					decoder[\defaultProperties][\textStyle])
				.string_("Freq :")
				.fontRatio_(0.125)
				.maxWidth_(192),
				1
			)
			.add(
				VLayout()
				.spacing_(0)
				.margins_(0)
				.add(player[\freqSlider])
				.add(player[\freqSelector]),
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
					decoder[\defaultProperties][\textStyle])
				.string_("Scale :")
				.fontRatio_(0.25)
				.maxWidth_(192),
				1
			)
			.add(player[\scaleSelector], 9),
			1
		)

	);

	player[\view].background_(
		decoder[\defaultProperties][\style].backColor);

	player
};

getPlayer
)