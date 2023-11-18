// A testing file to check ModHa's commands

// Conductor related

// Frequency & Scale testing
// Tonal setup
~mh[\conductor].setNote("B")
~mh[\conductor].setDiapason(442);
~mh[\conductor].setNote("F#");
// Non tonal setup
~mh[\conductor].setModal(false);
~mh[\conductor].setFreq(400);
// Testing feedback
~mh[\conductor][\freq].postln;

(// Obtaining full audible scale
~mh[\conductor].getAudibleScale.do({ |freq|
	freq.postln;
});
)

~mh[\conductor].midiToNote(59);
~mh[\conductor].noteToMidi("Bb");
~mh[\conductor].chordToMidi("A", "");

~mh[\conductor].chordToTunedFreqs("A", "-7b5");

// Convert midi to frequency, tuned accordingly
~mh[\conductor].midiToTunedFreq(69).postln;

// Rythm & structure testing
~mh[\conductor].setDumpTime(true);
~mh[\conductor].setBPM(120);
~mh[\conductor].startClock;
~mh[\conductor].stopClock;
~mh[\conductor].doPause;
~mh[\conductor].doResume;

// Set / get rythm specs
~mh[\conductor].setMaxSub(6);
~mh[\conductor].getMaxSub.postln;

// Orchestra related

// Display all instrument datas
// barely readable tho...
~mh[\orchestra].dumpInstrDatas;

// Access a synth data directly
~mh[\orchestra][\instrDatas][\PercSine].postln;
// Correct way to dump synth data
~mh[\orchestra].dumpInstrData("PercSine");

// Instrument creation
~instr = ~mh[\orchestra].createInstr("PercSine");
~instr = ~mh[\orchestra].createInstr("Luce");

~instr.getName.postln;
~instr.getSymbol.postln;
~instr.getType.postln;
// Dump keys
~instr.keysValuesDo({ |key, value| key.postln; });

~instr = ~mh[\orchestra].createInstr("PercSine");
~instr.getOscScore.postln;
~instr.getScoreAt(3).postln;

// Changing score by setting params
// At a particular beat :
~instr.setParamAt(1, \amp, 0.33);
// For very beat (time param == -1) :
~instr.setParamAt(-1, \amp, 0.33);
// Setting param using a list of values
// sizes does not have to match (but will yield a warning)
// Current score size is always kept
~instr.setParamList(\amp, ((15..0)/15));
// Amp & freq shorcuts
~instr.setAmpAt(0, 0.5);
~instr.setAmps((15..0)/15);
~instr.setFreqAt(0, 220);
~instr.setFreqs(List.fill(16, { [220, 330, 440].choose; } ));

~instr.getOscScore.do({ |score| score[\amp].postln; });
~instr.getOscScore.do({ |score| score[\freq].postln; });
~instr.getOscScore.do({ |score| score.postln; });