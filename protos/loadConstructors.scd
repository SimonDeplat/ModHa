(
// Exploiting polymorphism
// Parent 'class' must have an 'init' function
var getInstance = { |parent|
	var instance = ();
	instance.parent_(~gmDef[parent]);
	instance.init;
	instance
};

// Logic
~gmDef[\getPlayer] = { getInstance.value(\player) };

// Synths
~gmDef[\getMaster] = { getInstance.value(\master) };

// Top Level Views
~gmDef[\getMainWindow] = { getInstance.value(\mainWindow) };
~gmDef[\getPlayerView] = { getInstance.value(\playerView) };
~gmDef[\getSticky] = { getInstance.value(\sticky) };

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