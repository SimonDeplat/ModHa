(
var idDict = (
	name: "Distort",
	symbol: \mhDistort,
	category: \distortion,
	type: \effect,
	tunable: false,
	dependencies: nil,
	numChannels: 2,

	params: [

		(
			type: \in,
			symbol: \inBus,
			numChannels: 2,
			text: "In",
		),

		(
			type: \continuous,
			symbol: \preAmp,
			default: 1,
			min: 0,
			max: 3,
			scale: \lin,
			text: "preAmp",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \postAmp,
			default: 1,
			min: 0,
			max: 3,
			scale: \lin,
			text: "postAmp",
			modSteps: [0.01, 0.001]
		),

	]
);

SynthDef(\mhDistort, { |out = 0, inBus,
	preAmp = 1, postAmp = 1|
	var snd = In.ar(inBus, 2);
	snd = snd * preAmp;
	snd = snd.distort;
	snd = snd * postAmp;
	Out.ar(out, snd);
}).add;

idDict
)