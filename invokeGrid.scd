(
this.executeFile(
	thisProcess.nowExecutingPath.dirname
	+/+ "gmDefDecoder.scd");

~gmDef.invokeGrid([
	["DrumKit", \Kick808, \Kick, \CuboSnare, \WhiteEnv, \WhiteEnv],
	["Bass", \BassSaw],
	["Keyboards", \EnvSine, \Pulsar, \TwoModsFM2, \Rhodes],
	["Drones", \Bougie, \Luce, \Lizard],
	["Inputs", \MonoIn],
	["Effects", \Reverb, \Feedback],
]);
)