({ |decoder, symbol|
var self = (
	synthName: decoder[\gmDefs][symbol][\name],
	type: decoder[\gmDefs][symbol][\type],
	tunable: decoder[\gmDefs][symbol][\tunable],
	name: decoder[\gmDefs][symbol][\name].asString,

	// Coding convenience
	data: decoder[\gmDefs][symbol],
);

// Synth object inherits from synthParent,
// then from its subtype :
switch(self[\type])

{ \discrete } {
	self.parent_(decoder[\discreteSynthParent]);
	self[\header] = List(0);
}
{ \continuous }
{ self.parent_(decoder[\continuousSynthParent]) }
{ \effect }
{ self.parent_(decoder[\effectSynthParent]) }
{ \input }
{ self.parent_(decoder[\inputSynthParent]) };

// The real object setup happens within parent prototype
self.init;

self
})