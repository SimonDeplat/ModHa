(
var getDiscreteInstr;
var protoDiscreteInstr;

protoDiscreteInstr = (

);

// This function will expand the instrument
// dicionary by adding 
getDiscreteInstr = { |self|

	// This IDict is an extension
	var instr = (
		oscHeader: "Hello World",
	);
	"test".postln;
	// Inheritance setup
	self.insertParent(protoDiscreteInstr);
	// Extend self
	instr.keysValuesDo({ |key, value|
		self.put(key, value);
	});
	
	instr.clear;
};

// Return the getDiscreteInst function
getDiscreteInstr
)