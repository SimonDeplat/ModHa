(
var idDict = (
	name: "MonoIn",
	symbol: \mhMonoIn,
	category: \input,
	type: \input,
	numChannels: 2,

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