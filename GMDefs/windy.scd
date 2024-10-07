(
var idDict = (
	name: "Windy",
	symbol: \mhWindy,
	category: \noiseDrone,
	type: \continuous,
	tunable: false,
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
			pair: \bpFreq,
			axis: \y,
			helpersNumber: 3,
			helperSubdivisions: 1,
			helpersStyle: \dot,
		),

		(
			type: \continuous,
			symbol: \bpFreq,
			default: 100,
			min: 50,
			max: 20000,
			scale: \exp,
			text: "freq",
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
	],
);

SynthDef(\mhWindy, { |out = 0, amp = 0, bpFreq = 100|
	var snd = BPF.ar(
		[WhiteNoise.ar, WhiteNoise.ar],
		bpFreq, 1.0
	);
	snd = snd * amp;
	Out.ar(out, snd);

}).add;

idDict
)