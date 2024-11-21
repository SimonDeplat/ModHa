(
var idDict = (
	name: "Percusser",
	symbol: \mhPercusser,
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
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 4,
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
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 2,
			helperSubdivisions: 8,
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 1,
			values: [1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["-", "/2", "/4", "/8"],
		),
	],
);

SynthDef(\mhPercusser, {
	|out = 0, freq = 440, amp = 0, rlpFreq = 200, freqMul = 1|

	var snd = RLPF.ar(
		Pulse.ar([freq / 16, freq / 32] * freqMul,
			0.5,
			amp * 0.5),
		rlpFreq,
		0.05,
		amp * 0.5
	);
	snd = Limiter.ar(snd, amp);
	Out.ar(out, snd);
}).add;

idDict
)