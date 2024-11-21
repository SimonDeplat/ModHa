(
var idDict = (
	name: "BassSaw",
	symbol: \mhBassSaw,
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
				[0, 0.9, 0.25, 0],
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
			symbol: \cutoffFreq,
			default: 300,
			min: 55,
			max: 14080,
			scale: \exp,
			text: "cutoffFreq",
			polarity: \uni,
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
			symbol: \distort,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "dist",
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

SynthDef(\mhBassSaw, {
	|out = 0, amp = 0.5, freq = 440, freqMul = 1,
	cutoffFreq = 220, spread = 0.0, rq = 1, distort = 0|

	var snd, env, envGen;

	env = Env.newClear(9);
	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	snd = Saw.ar(freq / 4 * freqMul * [spread.reciprocal, spread]);
	snd = RLPF.ar(LPF.ar(snd, cutoffFreq), cutoffFreq, rq);

	snd = (1 - distort * snd) + (distort * snd.distort * 2);
	snd = snd * envGen;
	snd = snd * amp * 1.5;

	Out.ar(out, snd);
}).add;

idDict
)