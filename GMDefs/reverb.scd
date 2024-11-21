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
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: false,
			helpersStyle: \line,
			centerHelpers: false,
			helpersRatio: 0.333,
			helpersNumber: 3,
			helperSubdivisions: 4,
			// Mod Steps
			modStep: 0.01,
			modStepOperator: \add,
			modStep2: 1.1,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.round(1);
				value = value.asInteger;
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \continuous,
			symbol: \decay,
			default: 1,
			min: 0.1,
			max: 8,
			scale: \exp,
			text: "decay",
			modSteps: [0.1, 0.01],
			// DisplayFunc
			displayFunction: { |value|
				value = value.trunc(0.1);
				value = value.asString;
				value = value ++ "s";
				value
			},
		),

		(
			type: \continuous,
			symbol: \dryWet,
			default: 0.5,
			min: 0,
			max: 1,
			scale: \lin,
			text: "dryWet",
			modSteps: [0.01, 0.001],
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.round(1);
				value = value.asInteger;
				value = value.asString;
				value = value ++ "%";
				value
			},
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