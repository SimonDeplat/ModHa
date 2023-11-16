(
var idDict = (
// General settings
	name: "Luce", // Track name
	category: \drone,

	synthSymbol: \mhLuce, // Synth symbol to trigger
	continuous: true, // Is it a continuons synth or a discrete one?
	tunable: false, // Is it pertinent to change it's frequency according to the scale?
	hasEnv: false, // Has an Enveloppe View ?
	envSize: 0, // Number of enveloppe's segments

	params: [
		(
			type: \duo,
			params: [
				(
					type: \continuous,
					symbol: \resonzFreq,
					default: 24,
					min: 24,
					max: 16000,
					scale: \exp,
					text: "resonz freq",
				),
				
				(
					type: \continuous,
					symbol: \amp,
					default: 0,
					min: 0,
					max: 1,
					scale: \lin,
					text: "amp",
				),
				
			]
		)
	],
);

SynthDef(\mhLuce, {
	|out = 0, freq = 55, amp = 0, resonzFreq = 24|
	var snd = Saw.ar(freq!2);
	snd = Resonz.ar(snd, resonzFreq, 0.2);
	snd = snd * amp;
	Out.ar(out, snd);
}
).add;

idDict
)