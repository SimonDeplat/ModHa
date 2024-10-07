(
var idDict = (
	name: "Invasion",
	symbol: \mhInvasion,
	category: \drone,
	type: \continuous,
	tunable: true,
	dependencies: nil,
	numChannels: 2,

	params: [
		(

			type: \continuous,
			symbol: \amp,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			polarity: \uni,
			pair: \rlpFreq,
			axis: \y,
			helpersNumber: 3,
			helperSubdivisions: 1,
			helpersStyle: \dot,
		),

		(
			type: \continuous,
			symbol: \rlpFreq,
			default: 200,
			min: 100,
			max: 20000,
			scale: \exp,
			text: "RLP freq",
			polarity: \uni,

			pair: \amp,
			axis: \x,
			helpersNumber: 2,
			helperSubdivisions: 3,
			helpersStyle: \dot,
			displayFunction: { |value|
				value.asInteger
			},
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
			default: 1,
			values: [8, 4, 2, 1],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-"],
		),
	],
);

SynthDef(\mhInvasion, {
	|out = 0, freq = 440, freqMul = 1,
	amp = 0, rlpFreq = 200, spread = 1|

	var snd = RLPF.ar(
		Pulse.ar([freq / 2, freq / 4] * freqMul * [spread.reciprocal, spread],
			0.5,
			amp * 0.5
		),
		rlpFreq,
		0.05,
		amp * 0.5
	);
	snd = Limiter.ar(snd, amp);
	Out.ar(out, snd);
}).add;

idDict
)