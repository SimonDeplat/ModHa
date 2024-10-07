(
var idDict = (
	name: "Bougie",
	symbol: \mhBougie,
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
			pair: \blipHarm,
			axis: \y,
			helpersNumber: 3,
			helperSubdivisions: 1,
			helpersStyle: \dot,
		),

		(
			type: \continuous,
			symbol: \blipHarm,
			default: 3,
			min: 3,
			max: 128,
			scale: \exp,
			text: "blipHarms",
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
			values: [8, 4, 2, 1, 0.5],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2"],
		),
	],
);

SynthDef(\mhBougie, {
	|out = 0, freq = 440, amp = 0, blipHarm = 1, spread = 1, freqMul = 1|
	var snd = Blip.ar(
		(freq / 8) * freqMul * [spread.reciprocal, spread],
		blipHarm, 0.5
	) * amp;
	Out.ar(out, snd);
}).add;

idDict
)