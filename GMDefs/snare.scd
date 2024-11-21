// TO DO : ORIGINAL AUTHOR CREDIT

(
var idDict = (
	name: "Snare",
	symbol: \mhSnare,
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
			min: 0.001,
			max: 1,
			scale: \exp,
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
			symbol: \noiseAmp,
			default: 1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "noiseAmp",
			polarity: \uni,
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
			symbol: \sineSweepAmp,
			default: 0.4,
			min: 0,
			max: 1,
			scale: \lin,
			text: "sweepAmp",
			polarity: \uni,
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
			symbol: \sineSweepFreq,
			default: 200,
			min: 50,
			max: 1000,
			scale: \exp,
			text: "sweepFreq",
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
			symbol: \lpFreq,
			default: 5000,
			min: 200,
			max: 16000,
			scale: \exp,
			text: "lpStartFreq",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),
	]
);

SynthDef(\mhSnare, { |out = 0, amp = 1,
	atkTime = 0.001, relTime = 1.5,
	noiseAmp = 1, sineSweepAmp = 0.25,
	sineSweepFreq = 200, lpFreq = 8000|

	var snd, sweep, env;

	snd = WhiteNoise.ar(1);
	snd = HPF.ar(snd, 100);
	snd = LPF.ar(snd, XLine.kr(lpFreq, 3000, relTime));

	sweep = (
		SinOsc.ar(
			Env([2, 1, 0.75] * sineSweepFreq,
				[atkTime, relTime],
				\exp)
			.ar) * 6.dbamp).tanh;

	snd = snd * noiseAmp;
	sweep = sweep * sineSweepAmp;

	snd = snd + sweep;

	env = EnvGen.kr(
		Env.perc(atkTime, relTime),
		doneAction: Done.freeSelf
	);

	snd = (snd * 1.4).tanh; // Distortion Compression
	snd = snd * env * amp;
	snd = snd!2;

	Out.ar(out, snd);

}).add;

idDict
)