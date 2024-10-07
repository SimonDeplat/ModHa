(
var idDict = (
	name: "Pulser",
	symbol: \mhPulser,
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
			max: 16000,
			scale: \exp,
			text: "rlp Freq",
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
			symbol: \rq,
			default: 0.5,
			min: 0.1,
			max: 1.0,
			scale: \lin,
			text: "RQ",
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

SynthDef(\mhPulser, { |out = 0, freq = 110, amp = 0,
	rlpFreq = 40, freqMul = 1, spread = 1, rq = 0.5|
	var snd = RLPF.ar(
		Saw.ar(freq / 2 * freqMul * [spread.reciprocal, spread]),
		rlpFreq,
		rq
	);
	snd = snd * amp * 0.75;
	snd = Limiter.ar(snd);
	Out.ar(out, snd);
}).add;

idDict
)