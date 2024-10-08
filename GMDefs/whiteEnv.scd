(
var idDict = (
	name: "WhiteEnv",
	symbol: \mhWhiteEnv,
	category: \drumkit,
	type: \discrete,
	tunable: false,
	dependencies: nil,
	numChannels: 2,

	params: [
		(
			type: \env,
			symbol: \env,
			maxSize: 9,
			default: Env(
				[0, 1, 0],
				[0.001, 0.05],
				[0, -8]
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
			symbol: \startFreq,
			default: 18000,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "startFreq",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \endFreq,
			default: 18000,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "endFreq",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \rq,
			default: 0.25,
			min: 0.1,
			max: 1,
			scale: \exp,
			text: "rq",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \slideDur,
			default: 0.25,
			min: 0,
			max: 2,
			scale: \exp,
			text: "slideDur",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \lfoRate,
			default: 1,
			min: 0.5,
			max: 64,
			scale: \exp,
			text: "lfoRate",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \lfoAmount,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "lfoAmount",
			polarity: \uni,
		),
	]
);

SynthDef(\mhWhiteEnv, { |out = 0, amp = 0.25,
	startFreq = 15000, endFreq = 12000, rq = 0.5, slideDur = 0.1,
	lfoRate = 1, lfoAmount = 0|

	var snd, env, envGen;

	env = Env.newClear(9);
	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	snd = WhiteNoise.ar();

	snd = BPF.ar(
		snd,
		XLine.kr(startFreq, endFreq, slideDur),
		rq
	);

	snd = snd * (1 - (SinOsc.kr(lfoRate, mul: 0.5, add: 0.5) * lfoAmount));
	snd = snd * envGen;
	snd = snd * amp;
	snd = snd!2;

	Out.ar(out, snd)
}).add;

idDict
)