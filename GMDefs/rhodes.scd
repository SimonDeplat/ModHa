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
			displayFunction: { |value|
				value = value - 1;
				value = value * 100;
				case
				{ value < 1 } { value = value.trunc(0.01); }
				{ value < 10 } { value = value.trunc(0.1); }
				{ value = value.asInteger };
				value = value.asString ++ "%";
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