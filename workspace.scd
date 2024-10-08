(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");

~gmDef.dumpSynthsByType;
)

(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");

~gmDef.invokeGrid([
    ["Drum Section", \Kick, \CuboSnare],
    ["Note Section", \Rhodes, \Luce],
    ["Effect Section", \Reverb, \Feedback, \Reverb],
]);
)