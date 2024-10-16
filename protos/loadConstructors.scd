(
// Exploiting polymorphism
// Parent 'class' must have an 'init' function
var getInstance = { |parent|
	var instance = ();
	instance.parent_(~gmDef[parent]);
	instance.init;
	instance
};

// Synths
~gmDef[\getMaster] = { getInstance.value(\master) };

// Top Level Views
~gmDef[\getMainWindow] = { getInstance.value(\mainWindow) };
~gmDef[\getSticky] = { getInstance.value(\sticky) };
~gmDef[\getSaveLoadButtons] = { getInstance.value(\saveLoadButtons) };

// Player
~gmDef[\getPlayer] = { getInstance.value(\player) };
~gmDef[\getPlayerView] = { getInstance.value(\playerView) };
~gmDef[\getPlayButton] = { getInstance.value(\playButton) };
~gmDef[\getMaxCycleSelector] = { getInstance.value(\maxCycleSelector) };
~gmDef[\getTempoSelector] = { getInstance.value(\tempoSelector) };
~gmDef[\getRythmSelector] = { getInstance.value(\rythmSelector) };
~gmDef[\getFreqSelector] = { getInstance.value(\freqSelector) };
~gmDef[\getScaleSelector] = { getInstance.value(\scaleSelector) };

// Synth View
~gmDef[\getSynthView] = { getInstance.value(\synthView) };
~gmDef[\getSequencerView] = { getInstance.value(\sequencerView) };
~gmDef[\getPianoRollView] = { getInstance.value(\pianoRollView) };
~gmDef[\getParamManager] = { getInstance.value(\paramManager) };
~gmDef[\getOutView] = { getInstance.value(\outView) };
// Params
~gmDef[\getContinuousView] = { getInstance.value(\continuousView) };
~gmDef[\getSelectorView] = { getInstance.value(\selectorView) };
~gmDef[\getEnvView] = { getInstance.value(\envView) };
~gmDef[\getSlider2View] = { getInstance.value(\slider2View) };
~gmDef[\getInputView] = { getInstance.value(\inputView) };
)