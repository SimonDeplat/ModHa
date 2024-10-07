(
var idDict = (
	name: "PercSine",
	symbol: \mhPercSine,
	category: \electro,
	type: \discrete,
	tunable: true,
	dependencies: nil,
	numChannels: 2,

	params: [
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
			symbol: \atk,
			default: 0.001,
			min: 0.001,
			max: 1.0,
			scale: \exp,
			text: "atk",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \rel,
			default: 0.4,
			min: 0.05,
			max: 2.0,
			scale: \exp,
			text: "rel",
			polarity: \uni,
			style: \line,
			lineStyle: \full,
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

SynthDef(\mhPercSine, { |out = 0, freq = 440,
	freqMul = 1, amp = 0.8,
	atk = 0.001, rel = 0.05, spread = 1.0|

	var snd = SinOsc.ar(
		[freq * freqMul * spread, freq * freqMul / spread],
		mul: amp
	);
	snd = snd * EnvGen.kr(
		Env.perc(atk, rel),
		doneAction: Done.freeSelf
	);

	snd = snd / 2;

	Out.ar(out, snd);
}).add;

idDict
)