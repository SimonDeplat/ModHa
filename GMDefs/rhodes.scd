// TO DO : ORIGINAL AUTHOR CREDIT

(
var idDict = (
	name: "Rhodes",
	symbol: \mhRhodes,
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
			symbol: \modIndex,
			default: 0.2,
			min: 0.0625,
			max: 16,
			scale: \exp,
			text: "mod#",
			polarity: \uni,
			helpersNumber: 2,
			helperSubdivisions: 9,
			helpersStyle: \dot,
			displayHelpers: true,
		),

		(
			type: \continuous,
			symbol: \mix,
			default: 0.2,
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
			type: \continuous,
			symbol: \lfoSpeed,
			default: 1,
			min: 0.0625,
			max: 32,
			scale: \exp,
			text: "lfoSpeed",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				value = value.asString ++ "hz";
				value
			},
		),

		(
			type: \continuous,
			symbol: \lfoDepth,
			default: 0.1,
			min: 0,
			max: 1,
			scale: \lin,
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
			symbol: \spread,
			default: 1,
			min: 0.5,
			max: 2,
			scale: \exp,
			text: "spread",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: true,
			helpersRatio: 0.05,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 0,
			// Mod Steps
			modStep: 1.01,
			modStepOperator: \mul,
			modStep2: 1.001,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				var sign = "";
				if(value < 1) {
					value = value.reciprocal;
					sign = "-";
				};
				value = value - 1;
				value = value * 100;
				case
				{ value < 1 } {
					value = value.trunc(0.01);
					if((value%1) == 0)
					{ value = value.asInteger; };
				}
				{ value < 10 } { value = value.trunc(0.1); }
				{ value = value.asInteger };
				value = sign ++ value.asString ++ "%";
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

SynthDef(\mhRhodes, { |out = 0, amp = 0.1, freq = 440, freqMul = 1,
	modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.1,
	spread = 1|

	var env1, env2, env3, env4;
	var osc1, osc2, osc3, osc4, snd;
	var env, envGen;

	env = Env.newClear(9);

	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	freq = freq * freqMul * [spread.reciprocal, spread];

	osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex;
	osc3 = SinOsc.ar(freq, osc4) * 3;
	osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * 2;
	osc1 = SinOsc.ar(freq, osc2);

	snd = Mix.ar([osc3 * (1 - mix), osc1 * mix]);
	snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);
	snd = snd * envGen;
	snd = snd * amp * 0.25;

	Out.ar(out, snd);
}).add;

idDict
)