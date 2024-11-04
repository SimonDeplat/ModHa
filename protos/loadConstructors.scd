(
// Exploiting polymorphism
// Parent 'class' must have an 'init' function
var getInstance = { |parent|
	var instance = ();
	instance.parent_(~gmDef[parent]);
	instance.init;
	instance
};

[
	// Contexts
	[\getMainWindow, \mainWindow, "/protos/mainWindow.scd"],
	[\getSingleView, \singleView, "/protos/context/singleView.scd"],

	// Misc
	[\getSaveLoadButtons, \saveLoadButtons, "/protos/misc/saveLoadButtons.scd"],

	// Synths
	[\getMaster, \master, "/protos/master.scd"],

	// Player
	[\getPlayer, \player, "/protos/player/player.scd"],
	[\getPlayerView, \playerView, "/protos/player/playerView.scd"],
	[\getMiniPlayerView, \miniPlayerView, "/protos/player/miniPlayerView.scd"],
	[\getPlayButton, \playButton, "/protos/player/playButton.scd"],
	[\getMaxCycleSelector, \maxCycleSelector, "/protos/player/maxCycleSelector.scd"],
	[\getMaxCycleSwitch, \maxCycleSwitch, "/protos/player/maxCycleSwitch.scd"],
	[\getTempoSelector, \tempoSelector, "/protos/player/tempoSelector.scd"],
	[\getTempoSlider, \tempoSlider, "/protos/player/tempoSlider.scd"],
	[\getRythmSelector, \rythmSelector, "/protos/player/rythmSelector.scd"],
	[\getFreqSelector, \freqSelector, "/protos/player/freqSelector.scd"],
	[\getFreqSwitch, \freqSwitch, "/protos/player/freqSwitch.scd"],
	[\getScaleSelector, \scaleSelector, "/protos/player/scaleSelector.scd"],
	[\getScaleSwitch, \scaleSwitch, "/protos/player/scaleSwitch.scd"],
	[\getCycleView, \cycleView, "/protos/player/cycleView.scd"],
	[\getSticky, \sticky, "/protos/sticky.scd"],

	// Synth View
	[\getSynthView, \synthView, "/protos/synth/synthView.scd"],
	[\getSequencerView, \sequencerView, "/protos/synth/sequencerView.scd"],
	[\getPianoRollView, \pianoRollView, "/protos/synth/pianoRollView.scd"],
	[\getParamManager, \paramManager, "/protos/synth/paramManager.scd"],
	[\getOutView, \outView, "/protos/synth/outView.scd"],
	[\getBeatSelector, \beatSelector, "/protos/synth/beatSelector.scd"],
	
	// Param View
	[\getContinuousView, \continuousView, "/protos/synth/continuousView.scd"],
	[\getSelectorView, \selectorView, "/protos/synth/selectorView.scd"],
	[\getEnvView, \envView, "/protos/synth/envView.scd"],
	[\getSlider2View, \slider2View, "/protos/synth/slider2View.scd"],
	[\getInputView, \inputView, "/protos/synth/inputView.scd"],

	// This will postpone constructor creation
	// until they're instanced for the first time:
].do({ |array|
	~gmDef[array[0]] = {
		~gmDef[array[1]] = this.executeFile(~gmDef[\folder] ++ array[2]);
		~gmDef[array[0]] = { getInstance.value(array[1]); };
		getInstance.value(array[1])
	};
});

)