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
    ["Note Section", \Rhodes, \TwoModsFM2],
    ["Drone Section", \Lizard, \Luce],
    ["Effect Section", \SinLFO],
]);
)