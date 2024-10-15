(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");
)

(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");

~gmDef.invokeGrid([
    ["Note Section", \Rhodes, \TwoModsFM2],
    ["Drone Section", \Lizard, \Luce],
    ["Effect Section", \Wrapper, \Reverb, \Limiter],
]);
)

(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");

~gmDef.dumpSynthsByType;
)