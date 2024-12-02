(
var idDict = (
	name: "Echo",
	symbol: \mhEcho,
	category: \misc,
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
			symbol: \amount,
			default: 0.7,
			min: 0.01,
			max: 0.999,
			scale: \log,
			text: "amount",
			modSteps: [0.1, 0.01],
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.trunc(0.1);
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \timeTempo,
			symbol: \delay,
			default: 1,
			text: "delay",
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

SynthDef(\mhEcho, { |out = 0, inBus, amp = 1,
	dryWet = 0.5, amount = 0.5, delay = 1|
	var snd, effect, local;
	snd = In.ar(inBus, 2);
	local = LocalIn.ar(2);
	effect = Mix.ar([snd, local]);
	// Update max if needed
	effect = DelayC.ar(
		effect,
		10,
		(delay - ControlRate.ir.reciprocal)
		.clip((SampleDur.ir * 4), 10)
	);
	LocalOut.ar(effect  * amount);
	snd = snd * (1 - dryWet);
	effect = effect * dryWet;
	snd = snd + effect;
	snd = snd * amp;
	snd = LeakDC.ar(snd);
	Out.ar(out, snd);
}).add;

idDict
)