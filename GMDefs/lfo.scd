(
var idDict = (
	name: "SinLFO",
	symbol: \mhSinLFO,
	category: \misc,
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
			symbol: \amount,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amount",
			modSteps: [0.01, 0.001],
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
			symbol: \rate,
			default: 1,
			min: 0.05,
			max: 100,
			scale: \exp,
			text: "rate",
			modSteps: [0.01, 0.001],
			// DisplayFunc
			displayFunction: { |value|
				if(value >= 100) {
					value = value.asInteger;
				} {
					if(value >= 10) {
						value = value.trunc(0.01);
					} {
						value = value.trunc(0.0001);
					};
				};
				value = value.asString ++ "hz";
				value
			},
		),

	]
);

SynthDef(\mhSinLFO, { |out = 0, inBus, amount = 0, rate = 1|
	var snd = In.ar(inBus, 2);
	var lfo = SinOsc.ar(rate, 0, (amount / 2), (1 - (amount / 2)));
	snd = snd * lfo;
	Out.ar(out, snd);
}).add;

idDict
)