(
var idDict = (
	name: "CuboSnare",
	symbol: \mhCuboSnare,
	category: \drumkit,
	type: \discrete,
	tunable: false,
	dependencies: nil,
	numChannels: 2,

	params: [
		(
			type: \continuous,
			symbol: \amp,
			default: 0.8,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \freq,
			default: 200,
			min: 100,
			max: 1000,
			scale: \exp,
			text: "freq",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \startFreq,
			default: 800,
			min: 100,
			max: 10000,
			scale: \exp,
			text: "startFreq",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \atk,
			default: 5,
			min: 1,
			max: 50,
			scale: \exp,
			text: "atk",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \transition,
			default: 15,
			min: 1,
			max: 50,
			scale: \exp,
			text: "transition",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \release,
			default: 30,
			min: 1,
			max: 100,
			scale: \exp,
			text: "release",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \fundSpread,
			default: 0.1,
			min: 0,
			max: 0.5,
			scale: \lin,
			text: "fundSpread",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \noiseAmp,
			default: 0.25,
			min: 0,
			max: 1,
			scale: \lin,
			text: "noiseAmp",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \brOffset,
			default: 100,
			min: 0,
			max: 200,
			scale: \lin,
			text: "brOffset",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \dullness,
			default: 0.2,
			min: 0,
			max: 1,
			scale: \lin,
			text: "dullness",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \lpFreq,
			default: 15000,
			min: 100,
			max: 20000,
			scale: \exp,
			text: "lpFreq",
			polarity: \uni,
		),
	]
);

SynthDef(\mhCuboSnare, { |out = 0, amp = 1,
	freq = 250, startFreq = 5000, fundSpread = 0.1,
	atk = 5, transition = 15, release = 30, noiseAmp = 0.25,
	brOffset = 100, lpFreq = 15000, dullness = 0.2|

	var snd;
	var fundSweep, fund, fundEnv;
	var noise, noiseEnv;
	var brRatios = [1, 1.6, 2.4, 3.2];

	// Convert duration values to milliseconds
	atk = atk / 1000;
	transition = transition / 1000;
	release = release / 1000;

	// Convert spread, which will also add stereo
	fundSpread = [1 + fundSpread, 1 - fundSpread];

	// Fundamental frequency sweep
	fundSweep = XLine.ar(
		startFreq * fundSpread,
		freq * fundSpread,
		(atk + transition) / 2
	);

	// Fundamental enveloppe
	fundEnv = EnvGen.kr(
		Env(
			[0, 1, 0],
			[atk, transition],
			[2, 2]
		)
	);

	// Fundamental sound,
	// Sine slightly cubed
	fund = SinOsc.ar(
		XLine.kr(startFreq, freq, (atk + transition) / 2)
	);

	fund =
	(
		SinOsc.ar(fundSweep)
		+ SinOsc.ar(fundSweep * 3, mul: 1/3 * 0.7)
		+ SinOsc.ar(fundSweep * 5, mul: 1/5 * 0.3)
	);

	// Empirical normalisation
	fund = fund * 1.15;

	// Apply env to the fundamental
	fund = fund * fundEnv;

	// Noise enveloppe, crossfading during the transition
	noiseEnv = EnvGen.kr(
		Env(
			[0, 0, 1, 0],
			[atk, transition, release],
			[0, 2, 2]
		),
		doneAction: Done.freeSelf
	);

	// Snare noise, stereo
	noise = [WhiteNoise.ar(noiseAmp * 0.9), WhiteNoise.ar(noiseAmp * 0.9)];


	// Reject frequencies lower than the fundamental from the noise
	noise = HPF.ar(
		HPF.ar(
			noise,
			freq
		),
		freq
	);

	// Add an optionnal LPF to reduce high frequencies
	noise = LPF.ar(
		noise,
		lpFreq
	);

	// Add an optionnal, additionnal LPF that will
	// reduce high frequencies over time to simulate
	// the 'dullness tendency' of the noise over time
	noise = LPF.ar(
		noise,
		EnvGen.kr(
			Env(
				[lpFreq, lpFreq, lpFreq - ((lpFreq - freq) * dullness)],
				[atk, transition + release],
				[0, 0]
			)
		)
	);

	// Reject some frequencies from the noise to get a smoother sound
	brRatios.do({ |ratio|
		noise = BRF.ar(noise, (freq + brOffset) * ratio, 0.5);
	});

	// Apply env to the fundamental
	noise = noise * noiseEnv;

	snd = Mix.ar([fund, noise]);

	// Set overall amplitude
	snd = snd * amp;

	Out.ar(out, snd);

}).add;

idDict
)