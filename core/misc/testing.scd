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

// Display instrument list
// barely readable tho...
~mh[\orchestra].dumpInstrList