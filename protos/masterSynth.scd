(
SynthDef(\mhMaster, { |out = 0, inBus, amp = 1|
	var snd = In.ar(inBus, 2);
	snd = snd * amp;
	Out.ar(out, snd);
}).add;
)