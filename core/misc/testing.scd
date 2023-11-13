// A testing file to check ModHa's commands

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

// Rythm & structure testing
~mh[\conductor].setDumpTime(true);
~mh[\conductor].startClock;
~mh[\conductor].stopClock;
~mh[\conductor].doPause;
~mh[\conductor].doResume;
