// TO DO : ORIGINAL AUTHOR CREDIT

(
var idDict = (
	name: "HenSnare",
	symbol: \mhHenSnare,
	category: \drumkit,
	type: \discrete,
	tunable: false,
	dependencies: nil,
	numChannels: 2,

	params: [
		(
			type: \continuous,
			symbol: \amp,
			default: 0.6,
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
			symbol: \atkTime,
			default: 0.005,
			min: 0.001,
			max: 1,
			scale: \exp,
			text: "atk",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				if(value < 0.1) {
					value = value * 1000;
					value = value.asInteger;
					value = value.asString ++ "ms";
				} {
					value = value.trunc(0.01);
					value = value.asString ++ "s";
				};
				value
			},
		),

		(
			type: \continuous,
			symbol: \relTime,
			default: 0.1,
			min: 0.01,
			max: 1,
			scale: \lin,
			text: "rel",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				if(value < 0.1) {
					value = value * 1000;
					value = value.asInteger;
					value = value.asString ++ "ms";
				} {
					value = value.trunc(0.01);
					value = value.asString ++ "s";
				};
				value
			},
		),

		(
			type: \continuous,
			symbol: \freq,
			default: 7000,
			min: 800,
			max: 12000,
			scale: \exp,
			text: "freq",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),

		(
			type: \continuous,
			symbol: \velocity,
			default: 1,
			min: 0,
			max: 2,
			scale: \lin,
			text: "velocity",
			polarity: \uni,
		),
	],
);

SynthDef(\mhHenSnare, { |out = 0, amp = 0, velocity = 1,
	atkTime = 0.001, relTime = 0.25, freq = 7000|
	var excitation, membrane;
	excitation = LPF.ar(WhiteNoise.ar(1), freq, 1) * (0.1 + velocity);
	membrane = (
		/* Two simple enveloped oscillators represent the loudest resonances of the drum membranes */
		(LFTri.ar(330,0,1) * EnvGen.ar(Env.perc(atkTime, relTime / 4), doneAction: 0) * 0.25)
		+(LFTri.ar(185,0,1) * EnvGen.ar(Env.perc(atkTime, relTime / 4), doneAction: 0) * 0.25)
		/* Filtered white noise represents the snare */
		+(excitation * EnvGen.ar(Env.perc(atkTime, relTime), doneAction: Done.freeSelf) * 0.2)
		+(HPF.ar(excitation, 523, 1) * EnvGen.ar(Env.perc(atkTime, relTime / 2), doneAction: 0) * 0.2)
	);
	membrane = membrane * amp * 2;
	membrane = membrane!2;
	Out.ar(out, membrane);
}).add;

idDict
)