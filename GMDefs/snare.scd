// TO DO : ORIGINAL AUTHOR CREDIT

(
var idDict = (
	name: "Snare",
	symbol: \mhSnare,
	category: \drumKit,
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