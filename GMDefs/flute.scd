// I'm not the original author. If you are, you can contact me at s.deplat[a]ik.me
// Original : Wilson, Cottle and Collins
// http://ecmc.rochester.edu/ecmc/docs/supercollider/scbook/Ch21_Interface_Investigations/ixi%20SC%20tutorial/ixi_SC_tutorial_10.html
// See also : Bruno Ruviaro
// https://github.com/brunoruviaro/SynthDefs-for-Patterns/blob/master/flute.scd

(
var idDict = (
	name: "Flute",
	symbol: \mhFlute,
	category: \lead,
	type: \discrete,
	tunable: true,
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
			symbol: \dur,
			default: 0.5,
			min: 0.05,
			max: 8,
			scale: \exp,
			text: "dur",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \spread,
			default: 1,
			min: 1,
			max: 2,
			scale: 8,
			text: "spread",
			polarity: \uni,
			displayFunction: { |value|
				value = value - 1;
				value = value * 100;
				case
				{ value < 1 } { value = value.trunc(0.01); }
				{ value < 10 } { value = value.trunc(0.1); }
				{ value = value.asInteger };
				value = value.asString ++ "%";
				value
			},
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 0.5,
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),
	]
);

SynthDef(\mhFlute, { |out = 0, amp = 0.4, freq = 440, freqMul = 1,
	scl = 0.2, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4,
	dur = 1, gate = 1, spread = 1|

	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;

	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;

	ifqc = freq * freqMul * [spread.reciprocal, spread];
	amp = amp * 0.5;

	// noise envelope
	kenv1 = EnvGen.kr(
		Env.new(
		[0.0, 1.1 * ipress, ipress, ipress, 0.0],
			[0.06, 0.2, max(0.01, dur - 0.46), 0.2],
			'linear')
	);
	// overall envelope
	kenv2 = EnvGen.kr(
		Env.new(
		[0.0, amp, amp, 0.0],
			[0.1, max(0.01, dur - 0.02), 0.1],
			'linear'
		), doneAction: Done.freeSelf
	);
	// vibrato envelope
	kenvibr = EnvGen.kr(
		Env.new(
			[0.0, 0.0, 1, 1, 0.0],
			[0.5, 0.5, max(0.01, dur - 1.5), 0.5],
			'linear'));

	// create air flow and vibrato
	aflow1 = LFClipNoise.ar(sr, kenv1);
	kvibr = SinOsc.ar(5, 0, 0.1 * kenvibr);

	asum1 = (ibreath * aflow1) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - (asum1/20000) - (9/sr) + (ifqc/12000000) - block;

	fdbckArray = LocalIn.ar(1);

	aflute1 = fdbckArray;
	asum2 = asum1 + (aflute1 * ifeedbk1);

	//ax = DelayL.ar(asum2, ifqc.reciprocal * 0.5, afqc * 0.5);
	ax = DelayC.ar(asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - (asum1/ifqc/cr) + 0.001);

	apoly = ax - (ax.cubed);
	asum3 = apoly + (aflute1 * ifeedbk2);
	avalue = LPF.ar(asum3, 2000);

	aflute1 = DelayC.ar(avalue, ifqc.reciprocal - block, afqc);

	fdbckArray = [aflute1];

	LocalOut.ar(fdbckArray);

	signalOut = avalue;

	Out.ar(out, [signalOut * kenv2, signalOut * kenv2]);
}).add;

idDict
)