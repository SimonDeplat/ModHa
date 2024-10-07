(
var idDict = (
	name: "Pulsar",
	symbol: \mhPulsar,
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
			default: 0.4,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \formantRatio,
			default: 1,
			min: 0.125,
			max: 32,
			scale: \exp,
			text: "formantRatio",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \overlap,
			default: 1,
			min: 0,
			max: 2,
			scale: \lin,
			text: "overlap",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \whiteAmount,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "whiteAmount",
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

SynthDef(\mhPulsar, {
	|out = 0, amp = 0.25, freq = 440, freqMul = 1,
	formantRatio = 2, overlap = 1,
	spread = 0, whiteAmount = 0|

	var snd, fund, formant;
	var env, envGen;

	env = Env.newClear(9);
	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);


	envGen = envGen * PinkNoise.ar(1!2).range(0.1, 1).lag(0.02) ; // Noise Envelopping

	freq = freq * freqMul;

	fund = GrainSin.ar(
		numChannels: 2,
		trigger: Impulse.ar(freq),
		dur: 1 / freq,
		freq: freq * [spread.reciprocal, spread] + // Detune
		(whiteAmount * (WhiteNoise.ar(freq).lag(0.01))), // Noise Modulator
		mul: amp
	);

	formant = GrainSin.ar(
		numChannels: 1,
		trigger: Impulse.ar(freq + Rand(-3,3)),
		dur: overlap / freq,
		freq: formantRatio * freq * [spread.reciprocal, spread] + // Detune
		(whiteAmount * (WhiteNoise.ar(freq).lag(0.01))), // Noise Modulator
		mul: amp
	);

	snd = Mix.ar([fund, formant]);
	snd = snd * envGen;

	snd = LeakDC.ar(snd);

	Out.ar(out, snd) // Out

}).add;

idDict
)