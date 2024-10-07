(
var idDict = (
	name: "Luce",
	symbol: \mhLuce,
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
			pair: \resonzFreq,
			axis: \y,
			helpersNumber: 3,
			helperSubdivisions: 1,
			helpersStyle: \dot,
		),

		(
			type: \continuous,
			symbol: \resonzFreq,
			default: 220,
			min: 50,
			max: 20000,
			scale: \exp,
			text: "resonz Freq",
			polarity: \uni,

			pair: \amp,
			axis: \x,
			helpersNumber: 2,
			helperSubdivisions: 7,
			helpersStyle: \dot,
		),

		(
			type: \continuous,
			symbol: \bwr,
			default: 0.25,
			min: 0.1,
			max: 1.0,
			scale: \lin,
			text: "BW Ratio",
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
			values: [4, 2, 1, 0.5, 0.25],
			text: "freq mul.",
			texts: ["x4", "x2", "-", "/2", "/4"],
		),
	],
);

SynthDef(\mhLuce, { |out = 0, freq = 440, amp = 0,
	resonzFreq = 220, freqMul = 1, spread = 1, bwr = 0.25|
	var snd = Resonz.ar(
		Saw.ar(freq * freqMul * [spread.reciprocal, spread]),
		resonzFreq,
		bwr
	);
	snd = snd * amp * 1.333;
	Out.ar(out, snd);
}).add;

idDict
)