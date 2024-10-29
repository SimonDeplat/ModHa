({ |decoder, symbol|
var self = (
	synthName: ~gmDef[\gmDefs][symbol][\name],
	type: ~gmDef[\gmDefs][symbol][\type],
	tunable: ~gmDef[\gmDefs][symbol][\tunable],
	name: ~gmDef[\gmDefs][symbol][\name].asString,
	id: ~gmDef.getUid,
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