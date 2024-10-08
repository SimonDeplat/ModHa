(
var idDict = (
	name: "DCompander",
	symbol: \mhDCompander,
	category: \dynamics,
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
			symbol: \threshold,
			default: 1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "threshold",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \ratio,
			default: 1,
			min: 1,
			max: 16,
			scale: \exp,
			text: "ratio",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \atk,
			default: 0.01,
			min: 0.001,
			max: 1,
			scale: \exp,
			text: "atk",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \rel,
			default: 0.1,
			min: 0.01,
			max: 2,
			scale: \exp,
			text: "rel",
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

SynthDef(\mhDCompander, { |out = 0, inBus,
	threshold = 1, ratio = 1, atk = 0.01, rel = 0.1, postAmp = 1|
	var snd = In.ar(inBus, 2);
	snd = Compander.ar(
		snd,
		snd,
		threshold,
		1.0,
		1 / ratio,
		atk,
		rel
	);
	snd = snd * postAmp;
	Out.ar(out, snd);
}).add;

idDict
)