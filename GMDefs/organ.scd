// https://github.com/SCLOrkHub/SCLOrkSynths/blob/master/SynthDefs/organ/organTonewheel4.scd
// Authors: Mitchell Sigman, Nick Collins, Bruno Ruviaro, Josh Mitchell
// Modified by Dindo.
(
var idDict = (
	name: "OrganTW",
	symbol: \mhOrganTW,
	category: \keyboard,
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
			default: 0.6,
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
			symbol: \lfoRate,
			default: 1,
			min: 0.0625,
			max: 32,
			scale: \exp,
			text: "lfoRate",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				value = value.trunc(0.001);
				value = value.asString ++ "hz";
				value
			},
		),

		(
			type: \continuous,
			symbol: \lfoDepth,
			default: 0,
			min: 0,
			max: 1,
			scale: 8,
			text: "lfoDepth",
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
			symbol: \cutoff,
			default: 300,
			min: 55,
			max: 14080,
			scale: \exp,
			text: "cutoff",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				if(value == 0) { value = "";
				} {
					value = value.asInteger;
					value = value.asString ++ "hz";
				};
			},
		),

		(
			type: \continuous,
			symbol: \rq,
			default: 1,
			min: 0.1,
			max: 1,
			scale: \exp,
			text: "rq",
			polarity: \uni,
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
			default: 0.5,
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),
	]
);

SynthDef(\mhOrganTW,{ |out = 0, amp = 0.1,
	freq = 440, freqMul = 1, spread = 1,
	lfoRate = 4.85, lfoDepth = 0.1,
	cutoff = 5000, rq = 0.25|
	var snd, pulse, pulse2, lfo, env, envGen;
	freq = freq * freqMul * [spread.reciprocal, spread];
	lfo = LFTri.kr(
		lfoRate * [1, 1.01],
		Rand(0, 2.0)!2
	).range(1 / (1 + lfoDepth), (1 + lfoDepth));
	pulse = Pulse.ar(
		freq * lfo,
		[0.5, 0.51]
	);
	pulse2 = Pulse.ar(
		(freq * 3) * lfo,
		[0.5, 0.51]
	);
	snd = Mix.ar([pulse, pulse2]);
	snd = BLowPass4.ar(snd, cutoff, rq);
	snd = BPeakEQ.ar(snd, 500, 1.0, 3);
	env = Env.newClear(9);
	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);
	snd = snd * envGen * amp * 0.5;
	snd = Limiter.ar(snd, amp);
	Out.ar(out, snd);
}).add;

idDict
)