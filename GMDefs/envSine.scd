(
var idDict = (
	name: "EnvSine",
	symbol: \mhEnvSine,
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
				[0, 1, 0],
				[0.001, 0.4],
				[0, 0]
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
			symbol: \spread,
			default: 1.0,
			min: 1.0,
			max: 1.5,
			scale: 8,
			text: "spread",
			polarity: \uni,
			displayFunction: { |value|
				value = value - 1;
				value = value * 100;
				value = value.trunc(0.01);
				value = value.asString;
				value = value ++ "%";
				value
			}
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 1,
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),
	]
);

SynthDef(\mhEnvSine, { |out = 0, freq = 440,
	freqMul = 1, amp = 0.8, spread = 1.0|

	var env = Env.newClear(9);

	var envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	var snd = SinOsc.ar(
		[freq * freqMul * spread, freq * freqMul / spread],
		mul: amp
	);
	snd = snd * envGen / 2;

	Out.ar(out, snd);
}).add;

idDict
)