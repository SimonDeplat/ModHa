(
var idDict = (
	name: "LowVibe",
	symbol: \mhLowvibe,
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
			pair: \sinMul,
			axis: \y,
			helpersNumber: 3,
			helperSubdivisions: 1,
			helpersStyle: \dot,
		),

		(
			type: \continuous,
			symbol: \sinMul,
			default: 1,
			min: 1,
			max: 128,
			scale: \exp,
			text: "sinMul",
			polarity: \uni,

			pair: \amp,
			axis: \x,
			helpersNumber: 2,
			helperSubdivisions: 7,
			helpersStyle: \dot,
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
	],
);

SynthDef( \mhLowvibe, { |out = 0, freq = 440,
	amp = 0, sinMul = 24, spread = 1|
	var snd = SinOsc.ar(
		freq / 4 * [spread.reciprocal, spread],
		0,
		sinMul
	).fold2(1);
	snd = snd * amp * 0.25;
	Out.ar(out, snd);
}).add;

idDict
)