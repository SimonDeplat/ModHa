(
// Exploiting polymorphism
// Parent 'class' must have an 'init' function
var getInstance = { |parent|
	var instance = ();
	instance.parent_(~mh[parent]);
	instance.init;
	instance
};

// Load factorized constructors:
[
	[\addPlayer, \player, "player.scd"],
	[\addRemotePlayer, \remotePlayer, "remotePlayer.scd"],
].do({ |array|
	~mh[array[0]] = {
		~mh[array[1]] = this.executeFile(
			~mh[\folder]
			+/+ "Logic"
			+/+ array[2]
		);
		~mh[array[0]] = { getInstance.value(array[1]); };
		getInstance.value(array[1])
	};
});

// Load synth 'classes' and creation function:
[
	[\synth, "synth.scd"],
	[\continuousSynth, "continuousSynth.scd"],
	[\discreteSynth, "discreteSynth.scd"],
	[\effectSynth, "effectSynth.scd"],
	[\inputSynth, "inputSynth.scd"],
	[\addSynth, "addSynth.scd"]
].do({ |pair|
	~mh[pair[0]] =
	this.executeFile(
		~mh[\folder]
		+/+ "Logic/synth"
		+/+ pair[1]
	);
});
)