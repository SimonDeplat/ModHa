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