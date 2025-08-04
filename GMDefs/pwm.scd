(
var idDict = (
	name: "PWM",
	symbol: \mhPWM,
	category: \electro,
	type: \discrete,
	tunable: true,
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
			default: 0.75,
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
			symbol: \pulseWidth,
			default: 0.5,
			min: 0.005,
			max: 0.25,
			scale: \exp,
			text: "pulseWidth",
			modSteps: [0.1, 0.01],
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.trunc(0.1);
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \continuous,
			symbol: \modWidth,
			default: 0,
			min: 0,
			max: 0.5,
			scale: \exp,
			text: "modWidth",
			modSteps: [0.1, 0.01],
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.trunc(0.1);
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \timeTempo,
			symbol: \modRate,
			default: 1,
			text: "modRate",
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

SynthDef(\mhPWM, { |out = 0, amp = 0.5,
	freq = 440, freqMul = 1,
	pulseWidth = 0.5,
	modWidth = 0, modRate = 0,
	spread = 1|

	var snd, mod, env, envGen;

	env = Env.newClear(9);
	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	modWidth = min(
		modWidth,
		(0.5 - pulseWidth)
	);

	modWidth = min(
		modWidth,
		pulseWidth
	);

	modWidth = modWidth + pulseWidth;

	mod = SinOsc.kr(
		modRate,
		mul: modWidth
	);

	snd = Pulse.ar(
		freq * freqMul * [spread.reciprocal, spread],
		mod,
		amp
	);

	snd = snd * envGen;

	Out.ar(out, snd);
}).add;

idDict
)