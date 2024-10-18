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

(
var p, w1, w2;

this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");

p = ~gmDef.getPlayer;
w1 = ~gmDef.getMainWindow;
w2 = ~gmDef.getMainWindow;
w1.setPlayer(p);
w2.setPlayer(p);
w1.doFront;
w2.doFront;
)