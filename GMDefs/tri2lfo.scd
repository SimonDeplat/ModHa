(
var idDict = (
	name: "Tri²LFO",
	symbol: \mhTri2LFO,
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
			type: \timeTempo,
			symbol: \rate,
			default: 1,
			text: "rate",
		),

		(
			type: \continuous,
			symbol: \power,
			default: 1,
			min: 16.reciprocal,
			max: 16,
			scale: \exp,
			text: "power",
		),

		// LFTri's iphase isn't 0 -> 2pi,
		// it is 0 -> 4
		(
			type: \continuous,
			symbol: \phase,
			default: 0,
			min: 0,
			max: 4,
			scale: \lin,
			text: "phase",
			// DisplayFunc
			displayFunction: { |value|
				value = value.linlin(0, 4, 0, 360);
				value = value.round;
				value = value.asInteger;
				value = value.asString;
				value = value ++ "°";
				value
			},
		),
	]
);

SynthDef(\mhTri2LFO, { |out = 0, inBus, amount = 0,
	rate = 1, phase = 0, power = 1|
	var snd, lfo;
	snd = In.ar(inBus, 2);
	lfo = LFTri.kr(rate.reciprocal / 2, phase);
	lfo = lfo.abs;
	lfo = lfo.pow(power);
	lfo = lfo * amount;
	lfo = lfo + (1 - amount);
	snd = snd * lfo;
	Out.ar(out, snd);
}).add;

idDict
)