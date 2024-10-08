(
var idDict = (
	name: "Amplifier",
	symbol: \mhAmplifier,
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
			symbol: \amp,
			default: 1,
			min: 0,
			max: 3,
			scale: \lin,
			text: "amp",
			modSteps: [0.01, 0.001]
		),

	]
);

SynthDef(\mhAmplifier, { |out = 0, inBus, amp = 1|
	var snd = In.ar(inBus, 2);
	snd = snd * amp;
	Out.ar(out, snd);
}).add;

idDict
)