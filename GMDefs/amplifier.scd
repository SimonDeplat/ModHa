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

	]
);

SynthDef(\mhAmplifier, { |out = 0, inBus, amp = 1|
	var snd = In.ar(inBus, 2);
	snd = snd * amp;
	Out.ar(out, snd);
}).add;

idDict
)