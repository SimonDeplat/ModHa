(
var idDict = (
	name: "Lizard",
	symbol: \mhLizard,
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
			pair: \sawFreq,
			axis: \y,
			helpersNumber: 3,
			helperSubdivisions: 1,
			helpersStyle: \dot,
		),

		(
			type: \continuous,
			symbol: \sawFreq,
			default: 58.59375,
			min: 58.59375,
			max: 15000,
			scale: \exp,
			text: "saw freq",
			polarity: \uni,

			pair: \amp,
			axis: \x,
			helpersNumber: 2,
			helperSubdivisions: 7,
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
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),
	],
);

SynthDef(\mhLizard, { |out = 0, freq = 440, amp = 0,
	sawFreq = 100, freqMul = 1, spread = 1|
	var snd = SyncSaw.ar(
		freq / 4 * freqMul * [spread.reciprocal, spread],
		sawFreq
	);
	snd = LeakDC.ar(snd);
	snd = snd * amp * 0.25;
	Out.ar(out, snd);
}).add;

idDict
)