(
var idDict = (
	name: "Reverb",
	symbol: \mhReverb,
	category: \spatialization,
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
			max: 1,
			scale: \lin,
			text: "amp",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \decay,
			default: 1,
			min: 0.1,
			max: 8,
			scale: \exp,
			text: "decayTime",
			modSteps: [0.1, 0.01]
		),

		(
			type: \continuous,
			symbol: \dryWet,
			default: 0.5,
			min: 0,
			max: 1,
			scale: \lin,
			text: "dryWet",
			modSteps: [0.01, 0.001]
		),
	]
);

SynthDef(\mhReverb, { |out = 0, inBus,
	amp = 1, decay = 1, dryWet = 0.5|

	var snd = In.ar(inBus, 2);
	var effect = snd;
	4.do({
		effect = AllpassC.ar(
			// Update max if needed
			effect,
			0.05,
			{ 0.05.rand }.dup,
			decay
		);
	});

	snd = snd * (1 - dryWet);
	effect = effect * dryWet;
	snd = snd + effect;

	snd = snd * amp;
	Out.ar(out, snd);
}).add;

idDict
)