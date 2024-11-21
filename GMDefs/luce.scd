(
var idDict = (
	name: "Luce",
	symbol: \mhLuce,
	category: \drone,
	type: \continuous,
	tunable: true,
	dependencies: nil,
	numChannels: 2,

	params: [
		(

			type: \continuous,
			symbol: \amp,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			polarity: \uni,
			pair: \resonzFreq,
			axis: \y,
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 4,
		),

		(
			type: \continuous,
			symbol: \resonzFreq,
			default: 220,
			min: 50,
			max: 20000,
			scale: \exp,
			text: "resonz Freq",
			polarity: \uni,
			pair: \amp,
			axis: \x,
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 2,
			helperSubdivisions: 8,
		),

		(
			type: \continuous,
			symbol: \bwr,
			default: 0.25,
			min: 0.1,
			max: 1.0,
			scale: \lin,
			text: "BW Ratio",
		),

		(
			type: \continuous,
			symbol: \spread,
			default: 1,
			min: 0.5,
			max: 2,
			scale: \exp,
			text: "spread",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: true,
			helpersRatio: 0.05,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 0,
			// Mod Steps
			modStep: 1.01,
			modStepOperator: \mul,
			modStep2: 1.001,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				var sign = "";
				if(value < 1) {
					value = value.reciprocal;
					sign = "-";
				};
				value = value - 1;
				value = value * 100;
				case
				{ value < 1 } {
					value = value.trunc(0.01);
					if((value%1) == 0)
					{ value = value.asInteger; };
				}
				{ value < 10 } { value = value.trunc(0.1); }
				{ value = value.asInteger };
				value = sign ++ value.asString ++ "%";
				value
			},
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 1,
			values: [4, 2, 1, 0.5, 0.25],
			text: "freq mul.",
			texts: ["x4", "x2", "-", "/2", "/4"],
		),
	],
);

SynthDef(\mhLuce, { |out = 0, freq = 440, amp = 0,
	resonzFreq = 220, freqMul = 1, spread = 1, bwr = 0.25|
	var snd = Resonz.ar(
		Saw.ar(freq * freqMul * [spread.reciprocal, spread]),
		resonzFreq,
		bwr
	);
	snd = snd * amp * 1.333;
	Out.ar(out, snd);
}).add;

idDict
)