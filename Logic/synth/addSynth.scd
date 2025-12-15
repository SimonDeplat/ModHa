({ |mh, symbol|
	// This scripts creates a new prototype,
	// assigns its right parent,
	// then simply inits it.
	// See parents implementation for further details.

	var self = (
		synthName: ~mh[\gmDefs][symbol][\name],
		type: ~mh[\gmDefs][symbol][\type],
		tunable: ~mh[\gmDefs][symbol][\tunable],
		name: ~mh[\gmDefs][symbol][\name].asString,
		id: ~mh.getUID,
		data: ~mh[\gmDefs][symbol],
	);

	switch(self[\type])
	{ \discrete } {
		self.parent_(~mh[\discreteSynth]);
	}
	{ \continuous } {
		self.parent_(~mh[\continuousSynth]);
	}
	{ \effect } {
		self.parent_(~mh[\effectSynth]);
	}
	{ \input } {
		self.parent_(~mh[\inputSynth]);
	};

	self.init;
	self
})