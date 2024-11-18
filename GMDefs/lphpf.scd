(
var idDict = (
	name: "HP&LPF",
	symbol: \mhHPLPF,
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
			symbol: \hpFreq,
			default: 200,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "low Freq",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \lpFreq,
			default: 2000,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "high Freq",
			modSteps: [0.01, 0.001]
		),
	]
);

SynthDef(\mhHPLPF, { |out = 0, inBus, lpFreq = 10000, hpFreq = 5000|
	var snd = In.ar(inBus, 2);
	snd = HPF.ar(snd, hpFreq);
	snd = LPF.ar(snd, lpFreq);
	Out.ar(out, snd);
}).add;

idDict
)