(
var idDict = (
	name: "Kick",
	symbol: \mhKick,
	category: \drumkit,
	type: \discrete,
	tunable: false,
	dependencies: nil,
	numChannels: 2,

	params: [
		(
			type: \continuous,
			symbol: \amp,
			default: 0.8,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: false,
			helpersStyle: \line,
			centerHelpers: false,
			helpersRatio: 0.333,
			helpersNumber: 3,
			helperSubdivisions: 4,
			// Mod Steps
			modStep: 0.01,
			modStepOperator: \add,
			modStep2: 1.1,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.round(1);
				value = value.asInteger;
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \continuous,
			symbol: \freq,
			default: 55,
			min: 20,
			max: 200,
			scale: \exp,
			text: "freq",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),

		(
			type: \continuous,
			symbol: \sustain,
			default: 0.4,
			min: 0.05,
			max: 2,
			scale: \exp,
			text: "sustain",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				value = value.trunc(0.01);
				value = value.asString;
				value = value ++ "s";
				value
			},
		),

		(
			type: \continuous,
			symbol: \beaterNoiseLevel,
			default: 0.01,
			min: 0,
			max: 1,
			scale: \exp,
			expMin: 0.01,
			text: "noise amp",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.round(1);
				value = value.asInteger;
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \continuous,
			symbol: \modIndex,
			default: 1,
			min: 0,
			max: 10,
			scale: \lin,
			polarity: \uni,
			text: "mod#",
			pair: \modFreq,
			axis: \x,
			helpersNumber: 2,
			helperSubdivisions: 9,
			helpersStyle: \dot,
			displayHelpers: true,
		),

		(
			type: \continuous,
			symbol: \modFreq,
			min: 0.125,
			max: 32,
			default: 1,
			scale: \exp,
			text: "modFreq",
			polarity: \uni,
			pair: \modIndex,
			axis: \y,
			helpersNumber: 2,
			helperSubdivisions: 5,
			helpersStyle: \dot,
			displayHelpers: true,
		),
	]
);

SynthDef(\mhKick, { |out = 0, freq = 55, amp = 0.5,
	sustain = 0.4, beaterNoiseLevel = 0.025,
	modFreq = 5, modIndex = 5|

	var pitch_contour, drum_osc, drum_lpf, drum_env;
	var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
	var kick_mix;

	pitch_contour = Line.kr(freq * 2, freq, 0.02);
	drum_osc = PMOsc.ar(pitch_contour,
		modFreq,
		modIndex / 1.3
	);
	drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(
		Env.perc(0.005, sustain),
		1.0,
		doneAction: Done.freeSelf
	);
	beater_source = WhiteNoise.ar(beaterNoiseLevel);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0);

	kick_mix = Mix.ar([drum_env, beater_env]);
	kick_mix = kick_mix * amp * 1.333;
	kick_mix = kick_mix!2;
	Out.ar(out, kick_mix);
}
).add;

idDict
)