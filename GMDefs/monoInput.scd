(
var idDict = (
	name: "MonoIn",
	symbol: \mhMonoIn,
	category: \input,
	type: \input,
	numChannels: 2,
	tunable: false,

	params: [

		(
			type: \soundIn,
			symbol: \inBus,
			numChannels: 1,
			text: "Channel",
		),

		(
			type: \continuous,
			symbol: \amp,
			default: 0,
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

	]
);

SynthDef(\mhMonoIn, { |out = 0, amp = 0, inBus = 0|
	var snd = SoundIn.ar(inBus);
	snd = snd * amp;
	snd = snd!2;
	Out.ar(out, snd);
}).add;

idDict
)