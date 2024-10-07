// TO DO : ORIGINAL AUTHOR CREDIT

(
var idDict = (
	name: "Kick808",
	symbol: \mhKick808,
	category: \drumKit,
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
				[0, 0.9, 0],
				[0.005, 1],
				[0, 8, 0]
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
			default: 110,
			min: 55,
			max: 1760,
			scale: \exp,
			text: "startFreq",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \endFreq,
			default: 55,
			min: 55,
			max: 1760,
			scale: \exp,
			text: "endFreq",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \ringTime,
			default: 10,
			min: 0.05,
			max: 20,
			scale: \exp,
			text: "ringTime",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \distort,
			default: 0.75,
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
	]
);

SynthDef(\mhKick808, { |out = 0, amp = 1, startFreq = 110, endFreq = 55,
	ringTime = 10, distort = 0, spread = 1|

	var snd, env, envGen;

	env = Env.newClear(9);
	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	snd = Ringz.ar(
		Impulse.ar(0), // single impulse
		XLine.ar(
			startFreq * [spread.reciprocal, spread],
			endFreq * [spread.reciprocal, spread],
			0.1
		),
		ringTime
	);

	snd = Mix.ar([
		(1.0 - distort) * snd,
		distort * snd.distort * 2
	]);

	snd = snd * amp * 0.4;
	snd = snd * envGen;
	Out.ar(out, snd);
}).add;

idDict
)