// I'm not the original author. If you are, you can contact me at s.deplat[a]ik.me
// Original : Nathan Ho aka Snappizz
// http://sccode.org/1-51l

(
var idDict = (
	name: "Kalimba",
	symbol: \mhKalimba,
	category: \keyboard,
	type: \discrete,
	tunable: true,
	pianoRollRange: [-3, 4],
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
			symbol: \rel,
			default: 1,
			min: 0.0625,
			max: 8,
			scale: \exp,
			text: "rel",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				if(value < 0.1) {
					value = value * 1000;
					value = value.asInteger;
					value = value.asString ++ "ms";
				} {
					value = value.trunc(0.01);
					value = value.asString ++ "s";
				};
				value
			},
		),

		(
			type: \continuous,
			symbol: \mix,
			default: 0.1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "mix",
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
			type: \discrete,
			symbol: \freqMul,
			default: 0.5,
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),
	]
);

//Kalimba based on bank of ressonators
SynthDef(\mhKalimba, { |out = 0, amp = 0.1, freq = 440, freqMul = 1,
	mix = 0.1, rel = 2.0|

	var snd;

	// Basic tone is a SinOsc
	snd = SinOsc.ar(freq * freqMul) *
	EnvGen.kr(
		Env.perc(
			0.005,
			rel,
			1,
			-8
		),
		doneAction: Done.freeSelf
	);

	// The "clicking" sounds are modeled with a bank of resonators excited by enveloped pink noise
	snd = (snd * (1 - mix)) +
	(DynKlank.ar(`[
		// the resonant frequencies are randomized a little to add variation
		// there are two high resonant freqs and one quiet "bass" freq to give it some depth
		[
			240 * ExpRand(0.9, 1.1),
			2020 * ExpRand(0.9, 1.1),
			3151 * ExpRand(0.9, 1.1)
		],
		[-7, 0, 3].dbamp,
		[0.8, 0.05, 0.07]
	], PinkNoise.ar *
	EnvGen.kr(
		Env.perc(
			0.001,
			0.01
		)
	))
	* mix * 0.333);

snd = snd * amp * 0.75;
snd = snd!2;

Out.ar(out, snd);
}).add;

idDict
)