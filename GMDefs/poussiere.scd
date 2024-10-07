(
var idDict = (
	name: "Poussiere",
	symbol: \mhPoussiere,
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
			pair: \density,
			axis: \y,
			helpersNumber: 3,
			helperSubdivisions: 1,
			helpersStyle: \dot,
		),

		(
			type: \continuous,
			symbol: \density,
			default: 0.5,
			min: 0.5,
			max: 10000,
			scale: \exp,
			text: "density",
			polarity: \uni,

			pair: \amp,
			axis: \x,
			helpersNumber: 3,
			helperSubdivisions: 1,
			helpersStyle: \dot,
		),
	],
);

SynthDef(\mhPoussiere, { |out = 0, freq = 110, amp = 0, density = 0.5|
	var snd = Dust2.ar(density);
	snd = snd * amp;
	snd = snd!2;
	Out.ar(out, snd);
}).add;

idDict
)