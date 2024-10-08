(
var idDict = (
	name: "HPF",
	symbol: \mhHPF,
	category: \equalisation,
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
			symbol: \freq,
			default: 5000,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "freq",
			modSteps: [0.01, 0.001]
		),

	]
);

SynthDef(\mhHPF, { |out = 0, inBus, freq = 5000|
	var snd = In.ar(inBus, 2);
	snd = HPF.ar(snd, freq);
	Out.ar(out, snd);
}).add;

idDict
)