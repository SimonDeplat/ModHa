(
var idDict = (
	name: "Limiter",
	symbol: \mhLimiter,
	category: \dynamics,
	type: \effect,
	tunable: false,
	dependencies: nil,
	numChannels: 2,

	params: [

		(
			type: \in,
			symbol: \inBus,
			numChannels: 2,
			text: "In",
		),

		(
			type: \continuous,
			symbol: \amp,
			default: 1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			modSteps: [0.01, 0.001]
		),

	]
);

SynthDef(\mhLimiter, { |out = 0, inBus, amp = 0|
	var snd = In.ar(inBus, 2);
	snd = Limiter.ar(snd, amp);
	Out.ar(out, snd);
}).add;

idDict
)