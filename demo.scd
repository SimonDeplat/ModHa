
// Evaluate 'gmDefDecoder.scd' to load the software
(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");
)

// Evaluate this to get a list of available synths,
// sorted by type:
~gmDef.dumpSynthsByType;

// Create a window with a single instrument
// (and its player):
~gmDef.invokeSingleView(\TwoModsFM2);

// Create a window with a player,
// which allows to create/remove instrument windows:
~gmDef.invokeInvoker;

// This will change soon:
~gmDef.invokeGrid([
	["Drum Section", \Kick, \Snare, \WhiteEnv],
	["Note Section", \Rhodes, \TwoModsFM],
	["Drone Section", \Luce, \Bougie],
	["Effects", \Reverb, \Folder],
]);
)