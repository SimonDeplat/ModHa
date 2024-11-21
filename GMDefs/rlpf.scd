(
var idDict = (
	name: "RLPF",
	symbol: \mhRLPF,
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
			max: 16000,
			scale: \exp,
			text: "freq",
			modSteps: [0.01, 0.001],
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),

		// MAX: 2.sqrt
		(
			type: \continuous,
			symbol: \rq,
			default: 1,
			min: 0.05,
			max: 1.414,
			scale: \exp,
			text: "rq",
			modSteps: [0.01, 0.001],
		),

	]
);

SynthDef(\mhRLPF, { |out = 0, inBus, freq = 5000, rq = 1|
	var snd = In.ar(inBus, 2);
	snd = RLPF.ar(snd, freq, rq);
	Out.ar(out, snd);
}).add;

idDict
)