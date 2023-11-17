(
var idDict = (
	name: "PercSine", // Track name
	category: \electro,

	synthSymbol: \mhPercSine, // Synth symbol to trigger
	continuous: false, // Is it a continuons synth or a discrete one?
	tunable: true, // Is it pertinent to change it's frequency according to the scale?
	hasEnv: false, // Has an Enveloppe ?
	envSize: 0, // Number of enveloppe's segments

	params: [
		(
			type: \continuous,
			symbol: \amp,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
		),

		(
			type: \continuous,
			symbol: \spread,
			default: 0,
			min: 0,
			max: 0.8,
			scale: \lin,
			text: "spread",
		),

		(
			type: \continuous,
			symbol: \atk,
			default: 0.05,
			min: 0,
			max: 1,
			scale: \lin,
			text: "atk",
		),

		(
			type: \continuous,
			symbol: \rel,
			default: 0.5,
			min: 64.reciprocal,
			max: 4,
			scale: \exp,
			text: "rel",
		),
		
		(
			type: \discrete,
			symbol: \freqMul,
			default: 1,
			values: [0.125, 0.25, 0.5, 1, 2, 4, 8],
			text: "freq mul.",
			texts: ["/8", "/4", "/2", "-", "x2", "x4", "x8"],
		),
		
	]
);

SynthDef(\mhPercSine, {
	|out = 0, amp = 0.25,
	freq = 440, freqMul = 1, spread = 0,
	atk = 0.05, rel = 0.5|

	var snd;

	snd = SinOsc.ar(
		[freq * (1 - spread), freq * (1 + spread)] * freqMul,
		mul: amp
	);

	snd = snd * EnvGen.kr(
		Env.perc(atk, rel, amp),
		doneAction: Done.freeSelf
	);

	Out.ar(out, snd);
}).add;

idDict
)