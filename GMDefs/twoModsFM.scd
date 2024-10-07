(
var idDict = (
	name: "TwoModsFM",
	symbol: \mhFMSynth,
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
			type: \discrete,
			symbol: \modFreqMul1,
			default: 1,
			values: [5, 4, 3, 2, 1, 0.5, 0.25],
			text: "mod1 freq*",
			texts: ["x5", "x4", "x3", "x2", "-", "/2", "/4"],
		),

		(
			type: \continuous,
			symbol: \modIndex1,
			default: 1,
			min: 0,
			max: 10,
			scale: \lin,
			text: "mod1 Mod#",
		),

		(
			type: \discrete,
			symbol: \modFreqMul2,
			default: 1,
			values: [5, 4, 3, 2, 1, 0.5, 0.25],
			text: "mod2 freq*",
			texts: ["x5", "x4", "x3", "x2", "-", "/2", "/4"],
		),

		(
			type: \continuous,
			symbol: \modIndex2,
			default: 0,
			min: 0,
			max: 10,
			scale: \lin,
			text: "mod2 Mod#",
		),

		(
			type: \continuous,
			symbol: \detuneHz,
			default: 0,
			min: 0,
			max: 32,
			scale: \lin,
			text: "detuneHz",
		),

		(
			type: \continuous,
			symbol: \detuneDur,
			default: 0.05,
			min: 0.001,
			max: 1,
			scale: \exp,
			text: "detuneDur",
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 0.25,
			values: [0.0625, 0.125, 0.25, 0.5, 1, 2, 4, 8],
			text: "freq mul.",
			texts: ["/16", "/8", "/4", "/2", "-", "x2", "x4", "x8"],
		),
	]
);

SynthDef(\mhFMSynth, {
	|out = 0, amp = 0.25, freq = 440, freqMul = 1,
	detuneHz = 10, detuneDur = 0.1,
	modFreqMul1 = 1, modIndex1 = 1,
	modFreqMul2 = 1, modIndex2 = 1|

	var carrier;
	var mod, mod1, mod2;
	var env, envGen;

	env = Env.newClear(9);

	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	freq = freq * freqMul;

	mod1 = freq * modFreqMul1;
	mod1 = mod1
	+ (Rand(detuneHz.neg, detuneHz).dup
		* Line.ar(1.0, 0.0, detuneDur));
	mod1 = SinOsc.ar(mod1, mul: modIndex1);

	mod2 = freq * modFreqMul2;
	mod2 = mod2
	+ (Rand(detuneHz.neg, detuneHz).dup
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