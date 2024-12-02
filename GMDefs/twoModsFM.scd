(
var idDict = (
	name: "TwoModsFM",
	symbol: \mhFMSynth,
	category: \electro,
	type: \discrete,
	tunable: true,
	pianoRollRange: [-3, 4],
	dependencies: nil,
	numChannels: 2,

	params: [
		(
			type: \env,
			symbol: \env,
			maxSize: 9,
			default: Env(
				[0, 0.9, 0.05, 0],
				[0.001, 0.25, 1],
				[0, -4, 0]
			),
			min: 0,
			max: 1,
			text: "env",
			timeScale: 2.0,
		),

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
			symbol: \modIndex1,
			default: 1,
			min: 0,
			max: 10,
			scale: \lin,
			polarity: \uni,
			text: "mod1 Mod#",
			pair: \modFreqMul1,
			axis: \x,
			helpersNumber: 2,
			helperSubdivisions: 9,
			helpersStyle: \dot,
			displayHelpers: true,
		),

		(
			type: \continuous,
			symbol: \modFreqMul1,
			min: 0.125,
			max: 8,
			default: 1,
			scale: \exp,
			text: "mod1 freq*",
			polarity: \uni,
			pair: \modIndex1,
			axis: \y,
			helpersNumber: 2,
			helperSubdivisions: 5,
			helpersStyle: \dot,
			displayHelpers: true,
		),

		(
			type: \continuous,
			symbol: \modIndex2,
			default: 0,
			min: 0,
			max: 10,
			scale: \lin,
			text: "mod2 Mod#",
			polarity: \uni,
			pair: \modFreqMul2,
			axis: \x,
			helpersNumber: 2,
			helperSubdivisions: 9,
			helpersStyle: \dot,
			displayHelpers: true,
		),

		(
			type: \continuous,
			symbol: \modFreqMul2,
			min: 0.125,
			max: 8,
			default: 1,
			scale: \exp,
			text: "mod2 freq*",
			polarity: \uni,
			pair: \modIndex2,
			axis: \y,
			helpersNumber: 2,
			helperSubdivisions: 5,
			helpersStyle: \dot,
			displayHelpers: true,
		),

		(
			type: \continuous,
			symbol: \detuneHz,
			default: 0,
			min: 0,
			max: 32,
			scale: \lin,
			text: "detuneHz",
			// DisplayFunc
			displayFunction: { |value|
				if(value == 0) { value = "";
				} {
					value = value.trunc(0.01);
					value = value.asString ++ "hz";
				};
			},
		),

		(
			type: \continuous,
			symbol: \detuneDur,
			default: 0.05,
			min: 0,
			max: 1,
			scale: \exp,
			expMin: 0.001,
			text: "detuneDur",
			// DisplayFunc
			displayFunction: { |value|
				if(value < 0.1) {
					if(value == 0) {
						value = "";
					} {
						value = value * 1000;
						value = value.asInteger;
						value = value.asString ++ "ms";
					};
				} {
					value = value.trunc(0.01);
					value = value.asString ++ "s";
				};
				value
			},
		),

				(
			type: \continuous,
			symbol: \spread,
			default: 1,
			min: 1,
			max: 2,
			scale: 8,
			text: "spread",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: true,
			helpersRatio: 0.05,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 1,
			// Mod Steps
			modStep: 1.01,
			modStepOperator: \mul,
			modStep2: 1.001,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				value = value - 1;
				value = value * 100;
				if(value < 10) {
					value = value.trunc(0.01);
				} {
					value = value.asInteger;
				};
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 0.25,
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),
	]
);

SynthDef(\mhFMSynth, {
	|out = 0, amp = 0.25, freq = 220, freqMul = 1,
	detuneHz = 10, detuneDur = 0.1,
	modFreqMul1 = 1, modIndex1 = 1,
	modFreqMul2 = 1, modIndex2 = 1,
	spread = 1|

	var carrier;
	var mod, mod1, mod2;
	var env, envGen;

	env = Env.newClear(9);

	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	freq = freq * freqMul * [spread.reciprocal, spread];

	mod1 = freq * modFreqMul1;
	mod1 = mod1
	+ (Rand(detuneHz.neg, detuneHz)
		* Line.ar(1.0, 0.0, detuneDur));
	mod1 = SinOsc.ar(mod1, mul: modIndex1);

	mod2 = freq * modFreqMul2;
	mod2 = mod2
	+ (Rand(detuneHz.neg, detuneHz)
		* Line.ar(1.0, 0.0, detuneDur));
	mod2 = SinOsc.ar(mod2, mul: modIndex2);

	mod = mod1 + mod2;

	carrier = SinOsc.ar(freq * mod, mul: amp);
	carrier = carrier * envGen;
	carrier = LeakDC.ar(carrier);

	Out.ar(out, carrier);
}).add;

idDict
)