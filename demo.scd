(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");

~gmDef.invokeGrid([
	["Drum Section", \Kick, \Snare, \WhiteEnv],
	["Note Section", \Rhodes, \TwoModsFM],
	["Drone Section", \Luce, \Bougie],
	["Effects", \Reverb, \Folder],
]);
)