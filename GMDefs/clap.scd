// I'm not the original author. If you are, you can contact me at s.deplat[a]ik.me
// Original : Nathan Ho aka Snappizz
// http://sccode.org/1-523

(
var idDict = (
	name: "Clap",
	symbol: \mhClapElectro,
	category: \perc,
	type: \discrete,
	tunable: false,
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
		),
	]
);

SynthDef(\mhClapElectro, {
	|out = 0, amp = 0.5, pan = 0, dur = 1|
	var env1, env2, snd, noise1, noise2;

	// noise 1 - 4 short repeats
	env1 = EnvGen.ar(
		Env.new(
			[0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
			[0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
			[0, -3, 0, -3, 0, -3, 0, -4]
		)
	);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
	noise1 = BPF.ar(noise1, 1620, 3);

	// noise 2 - 1 longer single
	env2 = EnvGen.ar(
		Env.new(
			[0, 1, 0],
			[0.02, 0.18],
			[0, -4]),
		doneAction: Done.freeSelf);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = LPF.ar(noise2, 7600);
	noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

	snd = noise1 + noise2;
	snd = snd * 2;
	snd = snd.softclip;
	snd = snd!2;

	Out.ar(out, snd);
}).add;

idDict
)