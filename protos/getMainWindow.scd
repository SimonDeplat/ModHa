({ |decoder, symbol|
	var self = ();
	self.parent_(decoder[\mainWindowParent]);
	// The real object setup happens within parent prototype
	self.init;
	self
})