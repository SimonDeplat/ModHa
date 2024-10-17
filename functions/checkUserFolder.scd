// This will construct user's data folder automatically
(
if(File.exists(~gmDef[\userFolder]).not)
{ File.mkdir(~gmDef[\userFolder]); };

[
	"presets/", "presets/players/", "presets/synths/"
].do({ |folder|
	if(File.exists(~gmDef[\userFolder] ++ folder).not)
	{ File.mkdir(~gmDef[\userFolder] ++ folder); };
});
)