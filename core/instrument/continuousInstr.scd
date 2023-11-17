(
var getContinuousInstr;
var protoContinuousInstr;

protoContinuousInstr = (

);

// This function will expand the instrument
getConstinuousInstr = { |self|

	// This IDict is an extension
	var instr = (
		oscHeader: "Hello World",
	);

	// Inheritance setup
	self.insertParent(protoContinuousInstr);
	// Extend self
	instr.keysValuesDo({ |key, value|
		self.put(key, value);
	});
	instr.clear;
};

// Return the getContinuousInstr function
getContinuousInstr
)