// I'm not the original author. If you are, you can contact me at s.deplat[a]ik.me
// Original : nicolaariutti
// Edited by : Zé Craum
// http://sccode.org/1-5ay#c835

(
var idDict = (
	name: "Bell",
	symbol: \mhBellTubular,
	category: \perc,
	type: \discrete,
	tunable: true,
	dependencies: nil,
	numChannels: 2,

	params: [
		(
			type: \continuous,
			symbol: \amp,
			default: 0.75,
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
			symbol: \t60,
			default: 9,
			min: 0.25,
			max: 16,
			scale: \exp,
			text: "ringTime",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				value = value.trunc(0.01);
				value = value.asString ++ "s";
				value
			},
		),

		(
			type: \continuous,
			symbol: \spread,
			default: 1,
			min: 1,
			max: 2,
			scale: 8,
			text: "spread",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: true,
			helpersRatio: 0.05,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 1,
			// Mod Steps
			modStep: 1.01,
			modStepOperator: \mul,
			modStep2: 1.001,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				value = value - 1;
				value = value * 100;
				if(value < 10) {
					value = value.trunc(0.01);
				} {
					value = value.asInteger;
				};
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 0.5,
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),
	]
);

SynthDef(\mhBellTubular, { |out = 0, amp = 0.5, freq = 440, freqMul = 1,
	t60 = 9, gate = 1, spread = 1|

	var sig, exciter;

	exciter = WhiteNoise.ar() * EnvGen.ar(
		Env.perc(0.001, 0.05), gate) * 0.25;
	sig = DynKlank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421], // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047] * t60  // ring times
		],
		exciter,
		freqscale: freq * freqMul * [spread.reciprocal, spread]);

	DetectSilence.ar(sig, 0.001, 0.5, doneAction: Done.freeSelf);

	sig = sig * amp * 0.15;
	sig = Limiter.ar(sig);

	Out.ar(out, sig);
}).add;

idDict
)