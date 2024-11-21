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
			axis: \y,
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 4,
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
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 2,
			helperSubdivisions: 8,
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